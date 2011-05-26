package com.marklogic.sparql2xquery.translator;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.TreeSet;

import org.apache.log4j.Logger;

import sw4j.util.Sw4jException;
import sw4j.util.ToolIO;
import sw4j.util.ToolSafe;

import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.query.Syntax;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.RDFNode;
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

	private static String getNodeStringForXquery(RDFNode node){
		if (node.isAnon()){
			String temp = node.asResource().toString();
			temp = String.format("http://ex.org/bnode_"+temp.replaceAll(":","_"));
			return temp;
		}else if (node.isLiteral()){
			String temp = node.asLiteral().getString();
			return normalizeString(temp);
		}else{
			String temp = node.toString();
			return normalizeString(temp);
		}
	}
	
	public static String normalizeString(String str){
		str= str.replaceAll("&", "&amp;");
		str= str.replaceAll("'", "''");
		return str;		
	}
	
	public static String translateRdfDataToNQuads(Model m, String szNamedGraph){
		log("-------Generate NQuads ---------");
		
		TreeSet<String> inserts = new TreeSet<String>();
		
		{
			//prepare content
			StringWriter sw = new StringWriter();
			PrintWriter out = new PrintWriter(sw);
			m.write(out, "N-TRIPLE");
			
			if ( !ToolSafe.isEmpty(szNamedGraph)){
				//append graph uri at the end
				BufferedReader in;
				try {
					in = new BufferedReader( ToolIO.pipeStringToReader(sw.toString()));
					String line =null;
					while (null!=(line=in.readLine())){
						int pos = line.lastIndexOf(".");
						inserts.add( line.substring(0,pos) + " <"+szNamedGraph+"> ." );
					}
				} catch (Sw4jException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
		
		{	
			//prepare output
			StringWriter sw = new StringWriter();
			PrintWriter out = new PrintWriter(sw);
			
			for (String line : inserts){
				out.println(line);
			}
			
			return sw.toString();					
		}
	}
	
	public static String translateRdfDataToMarkLogicInsert(Model m, String szNamedGraph){
		log("-------Generate MarkLogic Insert---------");
		
		//generate code
		//note some triples will be merged as properties has been discarded.
		TreeSet<String> inserts = new TreeSet<String>();
		
		for (Statement stmt: m.listStatements().toList()){
			if ( !ToolSafe.isEmpty(szNamedGraph))
				inserts.add(String.format("sem:tuple-insert('%s', '%s', '%s',  '%s'),",
						getNodeStringForXquery( stmt.getSubject() ),
						getNodeStringForXquery( stmt.getPredicate() ),
						getNodeStringForXquery( stmt.getObject() ),						
						normalizeString(szNamedGraph)));
			else
				inserts.add(String.format("sem:tuple-insert('%s',  '%s', '%s', ()),",
						getNodeStringForXquery( stmt.getSubject() ),
						getNodeStringForXquery( stmt.getPredicate() ),
						getNodeStringForXquery( stmt.getObject() )
				));
		}		
		
		//output

		StringWriter sw = new StringWriter();
		PrintWriter out = new PrintWriter(sw);
		
		out.println(String.format("(: Instruction - copy and paste this code in CQ web interface, select content-source, execute it, expect %d documents after insertion :)", m.size()));
		out.println("(: MarkLogic XQuery HERE :)");
		out.println("import module namespace sem=\"http://marklogic.com/semantic\" at \"semantic.xqy\";");

		for (String line : inserts){
			out.println(line);
		}
		
		if (m.listStatements().hasNext()){
			out.println("()");
		}

		if (debug){
			log("------translated XQUEY query---------");
			log(sw.toString());
		}
		return sw.toString();		

	}

	public static String translateSparqlQuery(String szSparql){
		if (debug){
			log("------original SPARQL query---------");
			log(szSparql);
		}
		
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
