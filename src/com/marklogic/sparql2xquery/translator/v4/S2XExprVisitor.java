package com.marklogic.sparql2xquery.translator.v4;

import java.util.LinkedList;

import org.apache.log4j.Logger;


import com.hp.hpl.jena.sparql.expr.Expr;
import com.hp.hpl.jena.sparql.expr.ExprFunction;
import com.hp.hpl.jena.sparql.expr.ExprFunctionOp;
import com.hp.hpl.jena.sparql.expr.ExprVar;
import com.hp.hpl.jena.sparql.expr.ExprVisitor;
import com.hp.hpl.jena.sparql.expr.NodeValue;

import sw4j.util.DataPVHMap;

public class S2XExprVisitor implements ExprVisitor{
	private void log(Object obj){
		Logger.getLogger(this.getClass()).info(obj);
	}
	
	protected LinkedList<Expr> m_expr_and = new LinkedList<Expr>();
	protected DataPVHMap<Expr,ExprVar> m_index_expr_variable = new DataPVHMap<Expr,ExprVar> ();
	
	public LinkedList<Expr> getExprs(){
		return m_expr_and;
	}

	@Override
	public void finishVisit() {
	}

	@Override
	public void startVisit() {
		// TODO Auto-generated method stub
		
	}

	public boolean debug = true;
	
/*	
	@Override
	public void visit(ExprFunction0 arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		
		if (debug){
			System.out.println("---  ---   ---   ---");
			System.out.println(arg0.getClass());
			System.out.println(arg0);

			System.out.println(arg0.getFunctionSymbol());
		}		
		for (Expr arg: arg0.getArgs()){
			arg.visit(this);
		}
	}
	
	@Override
	public void visit(ExprFunction1 arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);

			log(arg0.getFunctionSymbol());
		}		
		for (Expr arg: arg0.getArgs()){
			arg.visit(this);
		}
	}

	@Override
	public void visit(ExprFunction2 arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);

			log(arg0.getFunctionSymbol());
		}
		
		boolean canDecompose = false;
		if (arg0 instanceof E_LogicalAnd){
			canDecompose = m_expr_and.remove(arg0);		
		}
		
		for (Expr arg: arg0.getArgs()){
			if (canDecompose){
				this.m_expr_and.add(arg);
			}
			arg.visit(this);
		}
	}

	@Override
	public void visit(ExprFunction3 arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);

			log(arg0.getFunctionSymbol());
		}		
		for (Expr arg: arg0.getArgs()){
			arg.visit(this);
		}
	}

	@Override
	public void visit(ExprFunctionN arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);
			
			log(arg0.getFunctionSymbol());
		}
		for (Expr arg: arg0.getArgs()){
			arg.visit(this);
		}
	}
	
	@Override
	public void visit(ExprAggregator arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);
		}
	}

	
*/

	@Override
	public void visit(ExprFunctionOp arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);

			log(arg0.getOpName());
		}
		for (Expr arg: arg0.getArgs()){
			arg.visit(this);
		}
	}

	@Override
	public void visit(NodeValue arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);
		}
	}

	@Override
	public void visit(ExprVar arg0) {
		if (m_expr_and.isEmpty()){
			m_expr_and.add(arg0);
		}
		if (debug){
			log("---  ---   ---   ---");
			log(arg0.getClass());
			log(arg0);
		}
		m_index_expr_variable.add(this.m_expr_and.getLast(), arg0);
	}


	@Override
	public void visit(ExprFunction arg0) {
		// TODO Auto-generated method stub
		
	}

}
