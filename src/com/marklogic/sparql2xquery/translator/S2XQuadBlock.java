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
