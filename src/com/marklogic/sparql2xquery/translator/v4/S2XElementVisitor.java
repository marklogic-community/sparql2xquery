package com.marklogic.sparql2xquery.translator.v4;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;


import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.sparql.expr.Expr;
import com.hp.hpl.jena.sparql.expr.ExprVar;
import com.hp.hpl.jena.sparql.syntax.Element;
import com.hp.hpl.jena.sparql.syntax.ElementAssign;
import com.hp.hpl.jena.sparql.syntax.ElementDataset;
import com.hp.hpl.jena.sparql.syntax.ElementExists;
import com.hp.hpl.jena.sparql.syntax.ElementFetch;
import com.hp.hpl.jena.sparql.syntax.ElementFilter;
import com.hp.hpl.jena.sparql.syntax.ElementGroup;
import com.hp.hpl.jena.sparql.syntax.ElementMinus;
import com.hp.hpl.jena.sparql.syntax.ElementNamedGraph;
import com.hp.hpl.jena.sparql.syntax.ElementNotExists;
import com.hp.hpl.jena.sparql.syntax.ElementOptional;
import com.hp.hpl.jena.sparql.syntax.ElementPathBlock;
import com.hp.hpl.jena.sparql.syntax.ElementService;
import com.hp.hpl.jena.sparql.syntax.ElementSubQuery;
import com.hp.hpl.jena.sparql.syntax.ElementTriplesBlock;
import com.hp.hpl.jena.sparql.syntax.ElementUnion;
import com.marklogic.sparql2xquery.translator.S2XAbstractElementVisitor;
import com.marklogic.sparql2xquery.translator.S2XQuadBlock;

import sw4j.util.DataPVHMap;

public class S2XElementVisitor implements S2XAbstractElementVisitor{
	public boolean debug = true;
	public final static String VERSION= "revision 2011-05-26";

	private void log(Object obj){
		Logger.getLogger(this.getClass()).info(obj);
	}
	
	// the current named graph
	protected Node m_current_graph = null;

	// bgps (conjunctive, connected by "AND") found in this block
	protected ArrayList<S2XQuadBlock> m_bgps_and = new ArrayList<S2XQuadBlock>();
	
	// filters (conjunctive, connected by "AND") found in this block, and their touched variables
	protected DataPVHMap<Expr,ExprVar> m_filter_and_varible = new DataPVHMap<Expr,ExprVar>();
	
	// branches from this block (exclusive-alternative, connected by "XOR" )
	protected ArrayList<ArrayList<S2XElementVisitor>> m_branchs = new ArrayList<ArrayList<S2XElementVisitor>>();
	protected ArrayList<S2XElementVisitor> createBranch(){
		ArrayList<S2XElementVisitor> branch = new ArrayList<S2XElementVisitor> ();
		m_branchs.add(branch);
		return branch;
	}

	@Override
	public void visit(ElementTriplesBlock el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}		
	}
	

	@Override
	public void visit(ElementPathBlock el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
				
		S2XQuadBlock b = new S2XQuadBlock(el, this.m_current_graph); 
		this.m_bgps_and.add(b);
	}


	@Override
	public void visit(ElementFilter el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}

		S2XExprVisitor visitor = new S2XExprVisitor();
		visitor.debug=this.debug;
		el.getExpr().visit(visitor);
		this.m_filter_and_varible.add(visitor.m_index_expr_variable);
	}
	

	@Override
	public void visit(ElementAssign el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);	
		}
	}
	

	@Override
	public void visit(ElementUnion el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
		//TODO
		
	}

	@Override
	public void visit(ElementOptional el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}

	@Override
	public void visit(ElementGroup el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);			
		}

		boolean isUnionGroup =false;
		List<Element> children = el.getElements();
		if (children.size()>1){
			isUnionGroup =true;
			for (int i=1; i<children.size(); i++){
				if (!( children.get(i) instanceof ElementUnion)){
					isUnionGroup =false;
					break;
				}
			}
		}
		
		if (isUnionGroup){
			ArrayList<S2XElementVisitor> branch = createBranch(); 
			for (Element e:  el.getElements()){
				S2XElementVisitor visitor  = new S2XElementVisitor();
				if (e instanceof ElementUnion)
					e= ((ElementUnion)e).getElements().get(0);
				
				// copy context
				visitor.debug = this.debug;
				visitor.m_current_graph = this.m_current_graph;

				branch.add(visitor);
				e.visit(visitor);
			}

		}else{
			for (Element e :  el.getElements()){
				e.visit(this);
			}			
		}
	}

	@Override
	public void visit(ElementDataset el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);			
		}
	}

	@Override
	public void visit(ElementNamedGraph el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);

			log(el.getGraphNameNode());
		}
		this.m_current_graph = el.getGraphNameNode();
		el.getElement().visit(this);	
		this.m_current_graph = null;
	}

	@Override
	public void visit(ElementExists el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}

	@Override
	public void visit(ElementNotExists el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}

	@Override
	public void visit(ElementMinus el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}

	@Override
	public void visit(ElementService el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}

	@Override
	public void visit(ElementFetch el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}

	@Override
	public void visit(ElementSubQuery el) {
		if (debug){
			log("---------------------");
			log(el.getClass());
			log(el);
		}
	}



	@Override
	public String getFinalResults(List<String> resultsVars) {
		// use recursion to enumerate all possible queries caused by union
		ArrayList<String> ret = new ArrayList<String>();
		ArrayList<ArrayList<S2XElementVisitor>> paths = getPaths();
		
		if (debug){
		
			log("==================");
			log(String.format("\n #total paths = %d ",paths.size()));
	
			int path_id=0;
			for (ArrayList<S2XElementVisitor> path: getPaths()){
				path_id++;
				log("\n-----------------");
				log(String.format("\n #path id [%d] ",path_id));
				log("\n #result ((bgps, filters)+)");
				for (S2XElementVisitor member: path){
					for (S2XQuadBlock q: member.m_bgps_and){
						log( q.toString());
					}
					for (Expr q: member.m_filter_and_varible.keySet()){
						log( q.toString()+"\t" + member.m_filter_and_varible.getValues(q) );
					}
				}
			}
		}
		
		{
			ret.add( String.format("(: #sparql2xquery translator version: %s :)", VERSION));
			ret.add( String.format("(: #total paths = %d :)",paths.size()));
			ret.add( "import module namespace sem=\"http://marklogic.com/semantic\" at \"semantic.xqy\";" );
			ret.add("");
			
			int path_id=0;
			for (ArrayList<S2XElementVisitor> path: getPaths()){
				path_id++;
				String szFunctionName = String.format("local:uf_%d",path_id);
				
				ret.add(String.format("(: #path id [%d] :)",path_id));
				
				S2XQueryBuilder queryBuilder = new S2XQueryBuilder();
				
				for (S2XElementVisitor member: path){
					for (S2XQuadBlock q: member.m_bgps_and){
						queryBuilder.addBgps(q);
					}
					//for (Expr e: member.m_filter_and_varible.keySet()){
						queryBuilder.addFilter(member.m_filter_and_varible);
					//}
				}
				
				ret.add(String.format("declare function %s() {",szFunctionName));
				ret.addAll(queryBuilder.translate(resultsVars));
				ret.add("};\n");
			}			

			// path_id indicate max number of paths
			{
				ret.add("sem:setop-distinct-element (");
			}

			ret.add("(");
			for (int i=1; i<=path_id; i++){
				String szFunctionName = String.format("local:uf_%d",i);
				if (i>1){
					ret.add(",");					
				}
				ret.add(szFunctionName+"()");
			}
			ret.add(")");

			{
				ret.add(")");
			}
			
		}
		
		String content ="";
		for (String text :ret){
			content +="\n"+text;
		}
		
		return content;
	}

	 
	/**
	 * enumerate all possible paths staring from this block
	 * 
	 * @return
	 */
	public ArrayList<ArrayList<S2XElementVisitor>> getPaths(){
		ArrayList<S2XElementVisitor> path = new ArrayList<S2XElementVisitor>();
		path.add(this);
		
		ArrayList<ArrayList<S2XElementVisitor>> paths_me = new ArrayList<ArrayList<S2XElementVisitor>>();
		paths_me.add(path);

			
		for (ArrayList<S2XElementVisitor> branch: this.m_branchs){
			ArrayList<ArrayList<S2XElementVisitor>> paths_me_new = new ArrayList<ArrayList<S2XElementVisitor>>();
			for (S2XElementVisitor child: branch){
				//get permutation of current paths and child's paths
				ArrayList<ArrayList<S2XElementVisitor>> paths_child = child.getPaths();

				for (ArrayList<S2XElementVisitor> p_child: paths_child){
					for (ArrayList<S2XElementVisitor> p_me: paths_me){
						ArrayList<S2XElementVisitor> path_me_new = new ArrayList<S2XElementVisitor>();
						path_me_new.addAll(p_me);
						path_me_new.addAll(p_child);
						paths_me_new.add(path_me_new);
					}
				}
				
			}
			paths_me = paths_me_new;
		}
		
		return paths_me;		
	}

}
