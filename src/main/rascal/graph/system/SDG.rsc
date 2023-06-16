@contributor{René Bulsing - UvA MSc 2015}
module graph::system::SDG

import Prelude;
import lang::java::m3::AST;
import analysis::graphs::Graph;
import lang::java::jdt::m3::Core;

import extractors::Project;
import graph::DataStructures;
import graph::\data::GlobalData;


map[Vertex, node] encodedNodeEnvironment = ();
			
public Vertex encodeVertex(MethodData method, int vertex)
	= Vertex(method.abstractTree@src.file, method.name, vertex);

private Vertex encodeVertex(Expression methodCall, int vertex)
	= Vertex("<methodCall@decl.parent.file>.java", methodCall@decl.file, vertex);

private Vertex encodeVertex(Statement constructorCall, int vertex)
	= Vertex("<constructorCall@decl.parent.file>.java", constructorCall@decl.file, vertex);

private map[str, set[Vertex]] encodeDefinitionMap(map[str, set[Vertex]] definitions, MethodData method, DataDependence dataDependence)
{
	for(key <- dataDependence.defs, variableDef <- dataDependence.defs[key])
		if(key in definitions)
			definitions[key] += { encodeVertex(method, variableDef.origin) };
		else
			definitions[key] = { encodeVertex(method, variableDef.origin) };
	return definitions;
}

private Graph[Vertex] encodeGraph(MethodData method, Graph[int] graph) {
	Graph[Vertex] encodedGraph = {};
	
	for(<from, to> <- graph) {
		Vertex encodedFrom = encodeVertex(method, from);
		Vertex encodedTo = encodeVertex(method, to);
		
		encodedNodeEnvironment[encodedFrom] = resolveIdentifier(method, from);
		encodedNodeEnvironment[encodedTo] = resolveIdentifier(method, to);
		
		encodedGraph += { <encodedFrom, encodedTo> };
	}
	
	return encodedGraph;
}

private bool isParameterVariable(str variable)
	= /\$.*/ := variable;

private Graph[Vertex] getGlobalEdges(M3 projectModel) {
	map[loc, rel[MethodData, int]] globalLinks = getGlobalLinks();
	Graph[Vertex] globalEdges = {};
	
	for(location <- globalLinks) {
		Vertex globalVertex = Vertex(location.file, "Global", -1);
		node globalNode = \simpleName(location.file);
		
		try {
			globalNode@src = resolveLocation(location, projectModel);
		} catch: {
			globalNode@src = location(0, 0, <0, 0>, <0, 0>);
		}
		
		globalNode@nodeType = Global();
		
		encodedNodeEnvironment[globalVertex] = globalNode;
		
		for(<method, vertex> <- globalLinks[location]) {
			globalEdges += { <globalVertex, encodeVertex(method, vertex)> };
		}
	}
	
	return globalEdges;
}

public SystemDependence createSDG(M3 projectModel, ControlDependences controlDependences, DataDependences dataDependences) {
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
			, Expression call := resolveIdentifier(method, key)
			|| Statement call := resolveIdentifier(method, key)) {
			iControlDependenceGraph += { <encodeVertex(method, key), encodeVertex(call, ENTRYNODE)> };
		}
	}
	
	SystemDependence systemDependence = SystemDependence((), {}, {}, {}, {}, {});
	
	systemDependence.controlDependence = controlDependenceGraph;
	systemDependence.iControlDependence = iControlDependenceGraph;
	systemDependence.dataDependence = dataDependenceGraph;
	systemDependence.globalDataDependence = getGlobalEdges(projectModel);
	systemDependence.iDataDependence = iDataDependenceGraph;
	systemDependence.nodeEnvironment = encodedNodeEnvironment;
	
	return systemDependence;
}