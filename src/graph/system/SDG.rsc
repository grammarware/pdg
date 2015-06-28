module graph::system::SDG

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;
import analysis::graphs::Graph;

import graph::DataStructures;
import graph::\data::GlobalData;


map[Vertex, node] encodedNodeEnvironment = ();
			
public Vertex encodeVertex(MethodData method, int vertex) {
	return Vertex(method.abstractTree@src.file, method.name, vertex);
}

private Vertex encodeVertex(Expression methodCall, int vertex) {
	return Vertex("<methodCall@decl.parent.file>.java", methodCall@decl.file, vertex);
}

private map[str, set[Vertex]] encodeDefinitionMap(map[str, set[Vertex]] definitions, MethodData method, DataDependence dataDependence) {
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

private Graph[Vertex] encodeGraph(MethodData method, Graph[int] graph) {
	Graph[Vertex] encodedGraph = {};
	
	for(<from, to> <- graph) {
		Vertex encodedFrom = encodeVertex(method, from);
		Vertex encodedTo = encodeVertex(method, to);
		
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

private Graph[Vertex] getGlobalEdges() {
	map[loc, rel[MethodData, int]] globalLinks = getGlobalLinks();
	Graph[Vertex] globalEdges = {};
	
	for(location <- globalLinks) {
		Vertex globalVertex = Vertex(location.file, "Global", -1);
		node globalNode = \simpleName(location.file);
			
		globalNode@src = location(0,0,<0,0>,<0,0>);
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
	map[str, set[Vertex]] allDefinitions = ();
	
	for(method <- controlDependences) {
		allDefinitions = encodeDefinitionMap(allDefinitions, method, dataDependences[method]);
	}
	
	Graph[Vertex] dataDependenceGraph = ({}
		| it + encodeGraph(method, dataDependences[method].graph)
		| method <- controlDependences
		);
	Graph[Vertex] controlDependenceGraph = ({}
		| it + encodeGraph(method, controlDependences[method].graph)
		| method <- controlDependences
		);
	
	Graph[Vertex] iDataDependenceGraph = {};
	Graph[Vertex] iControlDependenceGraph = {};
	
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