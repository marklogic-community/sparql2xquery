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
