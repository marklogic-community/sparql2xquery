package com.marklogic.sparql2xquery.translator;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.apache.log4j.Logger;

import sw4j.util.ToolSafe;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.Statement;
import com.hp.hpl.jena.sparql.algebra.Algebra;
import com.hp.hpl.jena.sparql.algebra.Op;
import com.marklogic.sparql2xquery.translator.v4.S2XElementVisitor;

public class S2XTranslator {

	static boolean debug = false;
	private static void log(String szMessage){
		Logger.getLogger(S2XTranslator.class).info(szMessage);
	}

	private static void printQueryInfo(Query query){
        System.out.println("------debug start---------");
        System.out.println(query) ;
        System.out.println(query.getQueryPattern()) ;
        System.out.println(query.getQueryPattern().getClass()) ;

        System.out.println("-- variable begin--");
        System.out.println( query.getQueryPattern().varsMentioned());
        System.out.println("-- mentioned (mentioned), returned(below) --");
        System.out.println( query.getResultVars());
    	System.out.println("-- variable end--");

        System.out.println("-----params----------");
        System.out.println(query.getSyntax());
        System.out.println(query.getAggregators());
        System.out.println(query.getLimit());
        System.out.println(query.getOffset());
        System.out.println(query.getQueryType());
        System.out.println(query.getConstructTemplate());
        System.out.println(query.getGroupBy());
        System.out.println(query.getOrderBy());
        
        // Generate algebra
        System.out.println("-----algbra----------");
        Op op = Algebra.compile(query.getQueryPattern()) ;
       	System.out.println(op) ;
        op = Algebra.optimize(op) ;
       	System.out.println(op) ;

       	op = Algebra.toQuadForm(op);
    	System.out.println(op) ;
    	
        System.out.println("------debug end---------");		
	}

	public static String translateRdfDataToMarkLogicInsert(Model m, String szNamedGraph){
		log("-------ML Insert---------");
		StringWriter sw = new StringWriter();
		PrintWriter out = new PrintWriter(sw);
		
		out.println(String.format("(: Instruction - copy and paste this code in CQ web interface, select content-source, execute it, expect %d documents after insertion :)", m.size()));
		out.println("(: MarkLogic XQuery HERE :)");
		out.println("import module namespace sem=\"http://marklogic.com/semantic\" at \"semantic.xqy\";");
		
		for (Statement stmt: m.listStatements().toList()){
			if ( !ToolSafe.isEmpty(szNamedGraph))
				out.println(String.format("sem:tuple-insert('%s', '%s', '%s',  '%s'),",
						stmt.getSubject().toString(),
						stmt.getPredicate().toString(),
						stmt.getObject().isLiteral()? stmt.getObject().asLiteral().getString(): stmt.getObject().toString(),
						szNamedGraph));
			else
				out.println(String.format("sem:tuple-insert('%s',  '%s', '%s', ()),",
						stmt.getSubject().toString(),
						stmt.getPredicate().toString(),
						stmt.getObject().isLiteral()? stmt.getObject().asLiteral().getString(): stmt.getObject().toString()
				));
		}		
		
		if (m.listStatements().hasNext()){
			out.println("()");
		}
		return sw.toString();		

	}

	public static String translateSparqlQuery(String szSparql){
		log("------original SPARQL query---------");
		log(szSparql);
    	
        // Parse Query
        Query query = QueryFactory.create(szSparql, Syntax.syntaxSPARQL_11) ;
        if (debug){
        	printQueryInfo(query);
        }
        
        //Translate SPARQL Query
    	S2XElementVisitor translator = new com.marklogic.sparql2xquery.translator.v4.S2XElementVisitor();
    	translator.debug=false;
        log("------------ translated using "+translator.getClass().getName()+" ------ ");
        query.getQueryPattern().visit(translator);      
        return translator.getFinalResults(query.getResultVars());            
	}
}
