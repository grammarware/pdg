module graph::system::SDG

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import graph::DataStructures;

			
public str encodeVertex(MethodData method, int vertex) {
	return "<method.abstractTree@src.file>:<method.abstractTree@src.offset>:<method.name>:<vertex>";
}

private str encodeVertex(Expression methodCall, int vertex) {
	loc resolvedCall = resolveM3(methodCall@decl);
	
	return "<resolvedCall.file>:<resolvedCall.offset>:<methodCall.name>:<vertex>";
}

private map[str, set[str]] encodeDefinitionMap(map[str, set[str]] definitions, MethodData method, DataDependence dataDependence) {
	for(key <- dataDependence.defs) {
		for(variableDef <- dataDependence.defs[key]) {
			if(key in definitions) {
				definitions[key] += { encodeVertex(method, variableDef.origin) };
			} else {
				definitions[key] = { encodeVertex(method, variableDef.origin) };
			}
		}
	}
	
	return definitions;
}

private Graph[str] encodeGraph(MethodData method, Graph[int] graph) {
	Graph[str] encodedGraph = {};
	
	for(<from, to> <- graph) {
		encodedGraph += { <encodeVertex(method, from), encodeVertex(method, to)> };
	}
	
	return encodedGraph;
}

private bool isParameterVariable(str variable) {
	return /\$.*/ := variable;
}

public SystemDependence createSDG(ControlDependences controlDependences, DataDependences dataDependences) {
	map[str, set[str]] allDefinitions = ();
	
	for(method <- controlDependences) {
		allDefinitions = encodeDefinitionMap(allDefinitions, method, dataDependences[method]);
	}
	
	Graph[str] dataDependenceGraph = ({}
		| it + encodeGraph(method, dataDependences[method].graph)
		| method <- controlDependences
		);
	Graph[str] controlDependenceGraph = ({}
		| it + encodeGraph(method, controlDependences[method].graph)
		| method <- controlDependences
		);
	
	Graph[str] iDataDependenceGraph = {};
	Graph[str] iControlDependenceGraph = {};
	
	for(method <- controlDependences) {
		for(key <- domain(method.parameterNodes)
			, key >= 0
			, key in dataDependences[method].uses) {
			for(usedVariable <- dataDependences[method].uses[key]
				, isParameterVariable(usedVariable)
				, usedVariable in allDefinitions) {
				iDataDependenceGraph += { <definition, encodeVertex(method, key)> | definition <- allDefinitions[usedVariable] };
			}
		}
		
		for(key <- method.callSites
			, key >= 0
			, Expression expression := resolveIdentifier(method,key)) {
			iControlDependenceGraph += { <encodeVertex(method,key), encodeVertex(expression, ENTRYNODE)> };
		}
	}
	
	SystemDependence systemDependence = SystemDependence({}, {}, {}, {});
	
	systemDependence.controlDependence = controlDependenceGraph;
	systemDependence.iControlDependence = iControlDependenceGraph;
	systemDependence.dataDependence = dataDependenceGraph;
	systemDependence.iDataDependence = iDataDependenceGraph;
	
	return systemDependence;
}