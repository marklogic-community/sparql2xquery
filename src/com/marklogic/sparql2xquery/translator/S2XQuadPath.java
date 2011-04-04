package com.marklogic.sparql2xquery.translator;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;

import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.sparql.core.TriplePath;

public class S2XQuadPath {
	public TriplePath tp = null;
	public Node graph = null;
	
	public S2XQuadPath(TriplePath t, Node g){
		this.tp  = t;
		this.graph = g;
	}
	
	public boolean isForDefaultGraph(){
		return null==graph;
	}
	
	public Node getSubject(){
		return tp.getSubject();
	}
	
	public Node getPredicate(){
		return tp.getPredicate();
	}

	public Node getObject(){
		return tp.getObject();
	}
	
	public Node getNamedGraph(){
		return graph;
	}

	public String toString(){
		return String.format("%s [graph] %s",this.tp, this.graph);
	}
	
	private ArrayList<Node> m_vars = null; 
	public Collection<Node> listVariables(){
		if (null != m_vars)
			return m_vars;
		
		m_vars = new ArrayList<Node>();

		Node node = graph; 
		if (null!=node && node.isVariable()){
			m_vars.add(node);
		}
		
		node = tp.getSubject();
		if (node.isVariable()){
			m_vars.add(node);
		}
		
		node = tp.getPredicate();
		if (node.isVariable()){
			m_vars.add(node);
		}

		node = tp.getObject();
		if (node.isVariable()){
			m_vars.add(node);
		}
		
		return m_vars;
	}
	
	private HashMap<String,Node> m_map_position_node= null; 
	
	public HashMap<String, Node> getMapPositionNode(){
		if (null != m_map_position_node)
			return m_map_position_node;

		m_map_position_node = new HashMap<String,Node>();		
		m_map_position_node.put("s", this.getSubject());
		m_map_position_node.put("o", this.getObject());
		m_map_position_node.put("p", this.getPredicate());
		if (!this.isForDefaultGraph())
			m_map_position_node.put("c", this.getNamedGraph());
		
		return m_map_position_node;
	}
	
	 

}
