package com.marklogic.sparql2xquery.translator;

import java.util.Collection;

import com.hp.hpl.jena.sparql.expr.Expr;
import com.hp.hpl.jena.sparql.expr.ExprVar;

public class S2XFilter {
	Expr expr;
	Collection<ExprVar> vars;

	public S2XFilter(Expr e, Collection<ExprVar> v){
		expr =e;
		vars =v;
		
	}
}
