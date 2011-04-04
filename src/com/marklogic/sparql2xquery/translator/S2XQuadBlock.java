package com.marklogic.sparql2xquery.translator;

import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.sparql.syntax.ElementPathBlock;

public class S2XQuadBlock {
	public ElementPathBlock pb = null;
	public Node graph = null;
	
	public S2XQuadBlock(ElementPathBlock t, Node g){
		this.pb  = t;
		this.graph = g;
	}
	
	boolean isForDefaultGraph(){
		return null==graph;
	}
	
	public String toString(){
		return String.format("\n[graph] %s\n %s \n", this.graph, this.pb);
	}
}
