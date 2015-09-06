@contributor{René Bulsing - UvA MSc 2015}
module graph::call::CallGraph

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import extractors::Project;
import graph::DataStructures;


private CallVertex getVertex(loc location) {
	return CallVertex(location, location.parent.file, location.file, "<location.parent.file>:<location.file>");
}

public CallGraph createCG(M3 projectModel, loc projectLocation) {
	Graph[CallVertex] callGraph = {};
	set[loc] projectMethods = getM3Methods(projectModel);
	
	map[MethodName, FileName] methodFileMapping = ();
	map[FileName, set[MethodName]] fileMethodsMapping = ();
	
	map[CallVertex, set[CallVertex]] methodCalls = ();
	map[MethodName, set[CallVertex]] locations = ();
	
	for(methodLocation <- projectMethods) {
		CallVertex callVertex = getVertex(methodLocation);
		
		methodCalls[callVertex] = {};
		
		if(callVertex.identifier in locations) {
			locations[callVertex.identifier ] += { callVertex };
		} else {
			locations[callVertex.identifier] = { callVertex };
		}
		
		if(callVertex.file in fileMethodsMapping) {
			fileMethodsMapping[callVertex.file] += { callVertex.method };
		} else {
			fileMethodsMapping[callVertex.file] = { callVertex.method };
		}
		
		methodFileMapping[callVertex.identifier] = callVertex.file;
	}
	
	for(<caller, callee> <- projectModel@methodInvocation, caller in projectMethods, callee in projectMethods) {
		CallVertex methodVertex = getVertex(caller);
		CallVertex calledVertex = getVertex(callee);
			
		callGraph += { <methodVertex, calledVertex> };
		methodCalls[methodVertex] += { calledVertex };
	}
	
	return CallGraph(callGraph, locations, methodCalls, methodFileMapping, fileMethodsMapping);
}