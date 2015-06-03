module graph::system::SDG

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import graph::DataStructures;
import graph::\data::GlobalData;


map[str, node] encodedNodeEnvironment = ();
			
public str encodeVertex(MethodData method, int vertex) {
	return "<method.abstractTree@src.file>:<method.name>:<vertex>";
}

private str encodeVertex(Expression methodCall, int vertex) {
	return "<methodCall@decl.parent.file>.java:<methodCall@decl.file>:<vertex>";
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
		str encodedFrom = encodeVertex(method, from);
		str encodedTo = encodeVertex(method, to);
		
		if(from >= 0) {
			encodedNodeEnvironment[encodedFrom] = resolveIdentifier(method, from);
		}
		
		if(to >= 0) {
			encodedNodeEnvironment[encodedTo] = resolveIdentifier(method, to);
		}
		
		encodedGraph += { <encodedFrom, encodedTo> };
	}
	
	return encodedGraph;
}

private bool isParameterVariable(str variable) {
	return /\$.*/ := variable;
}

private Graph[str] getGlobalEdges() {
	map[loc, rel[MethodData, int]] globalLinks = getGlobalLinks();
	Graph[str] globalEdges = {};
	
	for(location <- globalLinks) {
		loc resolvedLocation;
		str globalVertex;
		node globalNode;
			
		try {
			resolvedLocation = resolveM3(location);
			
			globalVertex = "<resolvedLocation.file>:<resolvedLocation.offset>";
			globalNode = \simpleName(location.file);
			globalNode@src = resolvedLocation;
		} catch: {
			globalVertex = "<location.file>:Global";
			globalNode = \simpleName(location.file);
			
			globalNode@src = location(0,0,<0,0>,<0,0>);
		}
		globalNode@nodeType = Global();
		
		encodedNodeEnvironment[globalVertex] = globalNode;
		
		for(<method, vertex> <- globalLinks[location]) {
			globalEdges += { <globalVertex, encodeVertex(method, vertex)> };
		}
	}
	
	return globalEdges;
}

public SystemDependence createSDG(ControlDependences controlDependences, DataDependences dataDependences) {
	encodedNodeEnvironment = ();
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
	
	SystemDependence systemDependence = SystemDependence((), {}, {}, {}, {}, {});
	
	systemDependence.controlDependence = controlDependenceGraph;
	systemDependence.iControlDependence = iControlDependenceGraph;
	systemDependence.dataDependence = dataDependenceGraph;
	systemDependence.globalDataDependence = getGlobalEdges();
	systemDependence.iDataDependence = iDataDependenceGraph;
	systemDependence.nodeEnvironment = encodedNodeEnvironment;
	
	return systemDependence;
}