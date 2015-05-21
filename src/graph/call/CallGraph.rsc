module graph::call::CallGraph

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import extractors::Project;
import graph::DataStructures;


public str getVertexName(loc location) {
	loc resolvedLocation = resolveM3(location);
	
	return "<resolvedLocation.file>:<location.file>";
}

public CallGraph createCG(M3 projectModel, loc projectLocation) {
	Graph[str] callGraph = {};
	map[str, set[str]] methodCalls = ();
	map[str, loc] locations = ();
	set[loc] projectMethods = getM3Methods(projectModel);
	
	for(method <- projectMethods) {
		try node methodAST = getMethodASTEclipse(method, model = projectModel);
		catch: continue;
		
		str methodVertex = getVertexName(method);
		
		try locations[methodVertex] = methodAST@decl;
		catch: println(methodAST);
		
		methodCalls[methodVertex] = {};
		
		visit(methodAST) {
			case methodCall: \methodCall(isSuper, name, arguments): {
				if(methodCall@decl in projectMethods) {
					str calledVertex = getVertexName(methodCall@decl);
					
					callGraph += { <methodVertex, calledVertex> };
					methodCalls[methodVertex] += { calledVertex };
				}
			}
	    	case methodCall: \methodCall(isSuper, receiver, name, arguments): {
	    		if(methodCall@decl in projectMethods) {
					str calledVertex = getVertexName(methodCall@decl);
					
					callGraph += { <methodVertex, calledVertex> };
					methodCalls[methodVertex] += { calledVertex };
				}
	    	}
		}		
	}
	
	return CallGraph(callGraph, locations, methodCalls);
}