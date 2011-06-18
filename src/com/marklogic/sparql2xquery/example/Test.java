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
package com.marklogic.sparql2xquery.example;

import java.net.URI;
import java.net.URISyntaxException;

import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.XccConfigException;

// Test server: http://ec2-184-73-4-47.compute-1.amazonaws.com:8001/

public class Test {
    public static void main(String [] args){
      
      // This allows you to specify a different connection uri by running java -DMLURI="..."
      String connectionUri = System.getProperty("MLURI", "xcc://admin:admin@localhost:8006/bakesale-test");

    	ToolMarkLogicQueryRunner cq;
		try {
			cq = new ToolMarkLogicQueryRunner(new URI(connectionUri));
	    	String ret = cq.executeToSingleString("count(/t)","\n");
	    	System.out.println(ret);
		} catch (XccConfigException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (RequestException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
}
