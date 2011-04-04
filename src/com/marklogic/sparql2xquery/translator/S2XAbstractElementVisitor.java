package com.marklogic.sparql2xquery.translator;


import java.util.List;

import com.hp.hpl.jena.sparql.syntax.ElementVisitor;

public interface S2XAbstractElementVisitor extends ElementVisitor {

	public String getFinalResults(List<String> resultsVars);

}
