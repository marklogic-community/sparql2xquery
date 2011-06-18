/**
 * Copyright (c)2009-2010 Mark Logic Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * The use of the Apache License does not indicate that this project is
 * affiliated with the Apache Software Foundation.
 */
package com.marklogic.sparql2xquery.translator.v4;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import org.apache.log4j.Logger;


import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.graph.Node_Literal;
import com.hp.hpl.jena.graph.Node_URI;
import com.hp.hpl.jena.sparql.core.TriplePath;
import com.hp.hpl.jena.sparql.core.Var;
import com.hp.hpl.jena.sparql.expr.Expr;
import com.hp.hpl.jena.sparql.expr.ExprVar;
import com.hp.hpl.jena.vocabulary.RDF;
import com.marklogic.sparql2xquery.translator.S2XQuadBlock;
import com.marklogic.sparql2xquery.translator.S2XQuadPath;
import sw4j.util.DataPVHMap;

public class S2XQueryBuilder {
	boolean debug=false;
	boolean bInf_sub_c_p= true; //true;
	boolean bInf_inv=false; //true;
	
	private void log(Object obj){
		Logger.getLogger(this.getClass()).info(obj);
	}
	
	// the actual data
	HashSet<S2XQuadPath> m_data_bgps_and = new HashSet<S2XQuadPath>();
	protected DataPVHMap<Expr,ExprVar> m_filter_and_varible = new DataPVHMap<Expr,ExprVar>();
	HashSet<String> m_vars = new HashSet<String>();

	// index
	DataPVHMap<Node, S2XQuadPath > m_index_var_bgp = new DataPVHMap<Node, S2XQuadPath >();
	
	//working memory
	DataPVHMap<HashSet<Node>, S2XQuadPath > m_grouped_bgps = new DataPVHMap<HashSet<Node>, S2XQuadPath >();
	ArrayList<HashSet<Node>> m_sorted_vars = new ArrayList<HashSet<Node>>();
	HashSet<Node> m_graph_vars = new HashSet<Node>();	// vars used to refer to graph name

	
	
	public void addBgps(S2XQuadBlock block){
		for (TriplePath tp: block.pb.getPattern().getList()){
			S2XQuadPath qp = new S2XQuadPath(tp, block.graph);
			m_data_bgps_and.add(qp);
			for (Node var: qp.listVariables()){
				m_index_var_bgp.add(var, qp);
				m_vars.add(convertVarName(var));
			}
		}		
	}
	
	public void addFilter(DataPVHMap<Expr,ExprVar> data){
		m_filter_and_varible.add(data);
		// vars mentioned in filter should be a subset of those in BGPs
		/*for (Set<ExprVar> vars: data.values()){
			for (ExprVar var: vars){
				m_vars.add(var.getVarName());				
			}
		}
		*/
	}
	
	public Collection<S2XQuadPath> getBgps(Node var){
		return m_index_var_bgp.getValues(var);
	}
	
	private HashSet<S2XQuadPath>  getBgpsTerminal(Node var, Collection<Node> tvar){
		HashSet<S2XQuadPath>  ret = new HashSet<S2XQuadPath>();
		for (S2XQuadPath qp: getBgps(var)){
			Collection<Node>  vars = new ArrayList<Node>(qp.listVariables());
			vars.removeAll(tvar);
			vars.remove(var);
			if (vars.size()==0){
				ret.add(qp);
			}
		}
		return ret;
	}
	
	
	public List<String> translate(List<String> resultsVars){
		ArrayList<String> ret = new ArrayList<String>();
		ArrayList<Node> var_visited = new ArrayList<Node> ();

		groupBgps();

		identifyGraphVars();
		
		//init with marklogic import
		
		//add FOR clause: append triple pattern (BGPs) here 
		int cnt_bgp=0;
		for (HashSet<Node> var_set: this.m_sorted_vars){
			if (var_set.size()==1){
				// single bounded variable
				cnt_bgp+= m_grouped_bgps.getValuesCount(var_set);
				ret.add( translateBgps1(var_set, var_visited));
				var_visited.addAll(var_set);
			}else{
				//multiple variable
				ret.add( translateBgpsN(var_set, var_visited));				
			}
		}
		
		//add WHERE clause:  append graph var here 
		boolean isWhereEmpty = true;
		for (HashSet<Node> var_set: this.m_sorted_vars){
			for (Node var : var_set){
				if (this.m_graph_vars.contains(var)){
					if (!isWhereEmpty){
						ret.add("and");
					}else{
						ret.add("where");
					}
					isWhereEmpty =false;
					
					// add clause
					ret.add(renderExpression(String.format("%s !=''", var)));
				}
			}			
		}
		
		//add WHERE clause:  append filters here 
		//TODO, this can be optimized by putting filters ahead
		for (Expr e : m_filter_and_varible.keySet()){
			if (!isWhereEmpty){
				ret.add("and");
			}else{
				ret.add("where");
			}
			isWhereEmpty =false;
			
			ret.add(renderExpression(e));
		}
		
		
		

		//add RETURN clause:
		List<String> vars_ret= new ArrayList<String>();
		vars_ret.addAll(resultsVars);
		vars_ret.retainAll(m_vars);
		
		ret.add("return");
		ret.add("element result {");
		boolean hasComma=false ;
		for (String var: vars_ret){
			String temp = String.format("element binding { attribute name {\"%s\"}, $%s } ", var, var);
			if (hasComma)
				temp = "," + temp;
			else
				hasComma = true;
			ret.add( temp );
			
		}
		ret.add("}");
		
		if (debug)
			log("#var="+var_visited.size()+ ", #bgps="+cnt_bgp+ ", #filters="+m_filter_and_varible.keySet().size());

		return ret;
	}
	

	private String renderExpression(Expr e){
		return renderExpression(e.toString());
	}

	private String renderExpression(String e){
		String ret = "";
		ret = e;
		ret = ret.replaceAll("\\?\\?","\\$bnode_");
		ret = ret.replaceAll("\\?","\\$");
		
		return ret;
	}
	
	private String translateBgpsN(HashSet<Node> var_set, ArrayList<Node> var_visited){
		Collection<S2XQuadPath> bgps =m_grouped_bgps.getValues(var_set);
		// there is only one bgp here
		S2XQuadPath qp = bgps.iterator().next();
		String ret ="";
		
		String query= buildQuery(null, "", qp, var_visited);
		String pattern = String.format("sem:evT( %s )", query);

		String t_name = "$t"; 
		for (Node var: var_set){
			String var_name = convertVarName(var);
			t_name += "_"+var_name;
		}
		
		String sub_queries = ""; 
		for (String position: qp.getMapPositionNode().keySet()){
			Node var = qp.getMapPositionNode().get(position);
			if (!var_set.contains(var))
				continue;
			
			sub_queries += String.format(", $%s in %s/%s/text()", convertVarName(var), t_name, position);
		}
		ret +=String.format("for %s in %s %s", t_name, pattern, sub_queries );

		var_visited.addAll(var_set);
		return ret;
	}	
	
	private String buildQuery(Node var, String pattern, S2XQuadPath qp,  ArrayList<Node> var_visited){
		HashMap<String, Node> map_position_node = qp.getMapPositionNode();
		
		String query= "";
		for (String position : map_position_node.keySet()){
			Node node = map_position_node.get(position);

			String temp;
			temp = getNodeMatchString(
					var, 
					pattern, 
					node,
					position, 
					qp.getPredicate().isURI()&&RDF.type.getURI().equals(qp.getPredicate().getURI()),
					true,
					var_visited);
			if (query.length()>0 && temp.length()>0)
				query += ",";
			query += temp;
		}
		query = String.format("\n ( %s ) ", query) ;

		return query;
	}
	
	private String translateBgps1(HashSet<Node> var_set, ArrayList<Node> var_visited){
		Node var = var_set.iterator().next();
		Collection<S2XQuadPath> bgps =m_grouped_bgps.getValues(var_set);
		String pattern ="";
		for (S2XQuadPath qp: bgps){
			String query= buildQuery(var, pattern, qp, var_visited);
			
			if (qp.getSubject().equals(var)){
				pattern = String.format("\n sem:ev1( $sem:QN-S,  %s ) ", query) ;							
			}else if (qp.getObject().equals(var)){
				pattern = String.format("\n sem:ev1( $sem:QN-O,  %s ) ", query) ;							
			}else if (qp.getPredicate().equals(var)){
				pattern = String.format("\n sem:ev1( $sem:QN-P,  %s ) ", query) ;							
			}else if (var.equals(qp.getNamedGraph())){
				pattern = String.format("\n sem:ev1( $sem:QN-C,  %s ) ", query) ;							
			}
		}
		return String.format("for $%s in %s",convertVarName(var), pattern);
	}
	
	private static String convertVarName(Node var){
		String ret = var.getName();
		if (ret.startsWith("?"))
			ret = "bnode_"+ ret.substring(1);
		//ret = "$"+ret;
		return ret;
	}
	
	private String getNodeMatchString(Node var, String subquery, Node node, String position, boolean isClass, boolean bInverse, ArrayList<Node> var_visited){
		String ret ="";
		
		String str_func_query = String.format("sem:query-%s",position);
		
		String str_query_param ="";
		if (node instanceof Node_URI){
			Node_URI temp = (Node_URI) node;
			str_query_param = String.format("'%s'",temp.getURI());
		}else if (node instanceof Var){
			Var temp = (Var) node;
			if (var_visited.contains(temp)){
				str_query_param = String.format("$%s", convertVarName(temp));
			}else{
				if (node.equals(var) && subquery.length()>0){
					str_query_param= subquery;	
				}
			}
		}else {
			Node_Literal temp = (Node_Literal) node;
			str_query_param = String.format("'%s'",temp.getLiteralLexicalForm());
			/*
			log(node.getClass());
			log(node);
			System.exit(-1);
			*/
		}

		//rewrite query params with inference options
		if (bInf_sub_c_p && str_query_param.length()>0 ){
			if ("p".equals(position) && !isClass){				
				//str_query_param = String.format("sem:list-direct-subproperties(%s)",str_query_param);				
				if (bInverse && bInf_inv){
					str_query_param = String.format("sem:owl-inverse(%s)",str_query_param);
				}
				
			}else if ( "o".equals(position) && isClass){
				str_query_param = String.format("sem:list-direct-subclasses(%s)",str_query_param);				
			}
		}
		
		//return result
		if (str_query_param.length()>0)
			ret = (String.format("%s( %s )",str_func_query, str_query_param));

		return ret;
	}				
	
	private void identifyGraphVars(){
		for (S2XQuadPath qp: m_data_bgps_and){
			for (Node var: qp.listVariables()){
				if (var.equals(qp.getNamedGraph())){
					this.m_graph_vars.add(var);
				}
			}
		}
	}
	
	/**
	 * sort variables by their restrictions
	 * identify vars related to graph
	 * 
	 * @return
	 */
	private void groupBgps(){
		HashSet<S2XQuadPath> visited = new HashSet<S2XQuadPath>();
		HashSet<Node> visited_vars = new HashSet<Node>();

		int loop =1000;
		while (loop-- >0){
			ArrayList<Node> todo = new ArrayList<Node>();
			todo.addAll(m_index_var_bgp.keySet());
			todo.removeAll(visited_vars);
			
			if (todo.size()==0){
				return ;
			}
			
			Node bestVar =null;
			HashSet<S2XQuadPath> bestTBgps = null;
			for (Node var: todo ){
				HashSet<S2XQuadPath> tbgps = this.getBgpsTerminal(var, visited_vars);
				if (tbgps.size()==0)
					continue;
				
				if (null== bestVar){
					bestVar = var;
					bestTBgps = tbgps;
				}else{
					if (bestTBgps.size()<tbgps.size()){					
						bestVar = var;
						bestTBgps = tbgps;
					}
				}
			}			

			if (null!=bestVar){
				HashSet<Node> var_set = new HashSet<Node>();
				var_set.add(bestVar);
				
				visited_vars.add(bestVar);				
				bestTBgps.removeAll(visited);
				visited.addAll(bestTBgps);
				
				if (!this.m_grouped_bgps.keySet().contains(var_set)){
					this.m_sorted_vars.add(var_set);
				}
				this.m_grouped_bgps.add(var_set, bestTBgps);
			}else{
				//if there are multiple variables
				// select one quadpath
				int cntVarsBestQuadPath = -1;
				S2XQuadPath bestQuadPath = null;
				for (S2XQuadPath qp: m_data_bgps_and){
					if (visited.contains(qp))
						continue;
					int cntVars = qp.listVariables().size();
					if (null== bestQuadPath || cntVars< cntVarsBestQuadPath){
						bestQuadPath = qp;
						cntVarsBestQuadPath = cntVars;
					}
				}
				HashSet<Node> var_set = new HashSet<Node>();
				var_set.addAll(bestQuadPath.listVariables());
				var_set.removeAll(visited_vars);
				visited_vars.addAll(var_set);				
				
				if (!this.m_grouped_bgps.keySet().contains(var_set)){
					this.m_sorted_vars.add(var_set);
				}
				this.m_grouped_bgps.add(var_set, bestQuadPath);				
			}
		}		
	}

	


}
