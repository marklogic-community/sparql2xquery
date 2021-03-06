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
/*
 * Copyright (c) 2003-2011 MarkLogic Corporation. All rights reserved.
 */
package com.marklogic.sparql2xquery.example;

import java.net.URI;

import com.marklogic.xcc.AdhocQuery;
import com.marklogic.xcc.ContentSource;
import com.marklogic.xcc.ContentSourceFactory;
import com.marklogic.xcc.Request;
import com.marklogic.xcc.RequestOptions;
import com.marklogic.xcc.ResultItem;
import com.marklogic.xcc.ResultSequence;
import com.marklogic.xcc.Session;
import com.marklogic.xcc.exceptions.RequestException;
import com.marklogic.xcc.exceptions.XccConfigException;

/**
 * <p>
 * This is a very simple class that will submit an XQuery string to the server and return the
 * result.
 * </p>
 * <p>
 * Click here for the <a href="doc-files/SimpleQueryRunner.java.txt"> source code for this class</a>
 * </p>
 * <p>
 * The main() method looks for two command-line args, a URL for the server (
 * {@link ContentSourceFactory#newContentSource(java.net.URI)}) and a filename to read a query from.
 * It loads the file, submits its contents to the server for evaluation and then prints the result
 * sequence to stdout, one item per line.
 * </p>
 * <p>
 * The class has methods the could be used to set request options and to obtain the results as an
 * array of Strings or as a real {@link ResultSequence}.
 * </p>
 * <p>
 * If you want to set external variables for a request, you can call {@link #getRequest()} to obtain
 * a reference to the internal {@link Request} object and set the variable values on it before
 * invoking {@link #execute(String)}.
 * </p>
 */
public class ToolMarkLogicQueryRunner {
    private final Session session;
    private final AdhocQuery request;
    private RequestOptions options;

    /**
     * Construct an instance that will submit query requests to the server represented by the given
     * URI. Note that the URI will not be validated at this time.
     * 
     * @param serverUri
     *            A URI that specifies a server per (
     *            {@link ContentSourceFactory#newContentSource(java.net.URI)}).
     * @throws XccConfigException
     *             If the URI is not a valid XCC server URL.
     */
    public ToolMarkLogicQueryRunner(URI serverUri) throws XccConfigException {
        ContentSource cs = ContentSourceFactory.newContentSource(serverUri);

        session = cs.newSession();
        request = session.newAdhocQuery(null);
    }

    /**
     * Submit the given query string and return a {@link ResultSequence} object.
     * 
     * @param query
     *            XQuery code as a String, to be evaluated by the server.
     * @return An instance {@link ResultSequence}, possibly with size zero.
     * @throws RequestException
     *             If an unrecoverable error occurs when submitting or evaluating the request.
     */
    public ResultSequence execute(String query) throws RequestException {
        request.setQuery(query);
        request.setOptions(options);

        return session.submitRequest(request);
    }

    /**
     * Submit the given query string and return an array of Strings, possibly of length zero, which
     * contains the String value of each {@link ResultItem} (see
     * {@link com.marklogic.xcc.ResultItem#asString()})
     * 
     * @param query
     *            XQuery code as a String, to be evaluated by the server.
     * @return An array of Strings, one per item in the {@link ResultSequence}.
     * @throws RequestException
     *             If an unrecoverable error occurs when submitting or evaluating the request.
     */
    public String[] executeToStringArray(String query) throws RequestException {
        ResultSequence rs = execute(query);

        return rs.asStrings();
    }

    /**
     * Submit the given query string and return a single String which is the concatenation of all
     * the {@link ResultItem}s, separated by the given separator string.
     * 
     * @param query
     *            XQuery code as a String, to be evaluated by the server.
     * @param separator
     *            A String value which will be inserted in the final string between each item of the
     *            sequence. A value of null is equivalent to the empty string.
     * @return A String consisting of the {@link com.marklogic.xcc.ResultItem#asString()} value of
     *         each item with the separator string inserted between each instance.
     * @throws RequestException
     *             If an unrecoverable error occurs when submitting or evaluating the request.
     */
    public String executeToSingleString(String query, String separator) throws RequestException {
        ResultSequence rs = execute(query);
        String str = rs.asString(separator);

        rs.close();

        return str;
    }

    /**
     * Returns the {@link Request} object used internally to submit requests. This object can be
     * used to set external variables that will be bound to the query when submitted. You should not
     * set your own {@link RequestOptions} object, use
     * {@link #setRequestOptions(com.marklogic.xcc.RequestOptions)} instead.
     * 
     * @return An instance of {@link Request}.
     */
    public Request getRequest() {
        return request;
    }

    /**
     * Set (or clear) the {@link RequestOptions} instance to associate with submitted queries.
     * 
     * @param options
     *            An instance of {@link RequestOptions} or null.
     */
    public void setRequestOptions(RequestOptions options) {
        this.options = options;
    }

}
