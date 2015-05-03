module screen::SystemDependenceScreen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::java::m3::AST;

import screen::Screen;
import extractors::Project;

import creator::CFGCreator;
import graph::DataStructures;
import graph::\data::DDG;
import graph::control::PDT;
import graph::control::dependence::CDG;

@doc {
	To run a test:
		displaySystemDependenceGraph(|project://JavaTest|, "main");
}
public void displaySystemDependenceGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
		
	MethodData methodData = emptyMethodData();
	methodData.name = methodName;
	methodData.abstractTree = methodAST;
	
	list[MethodData] methodCollection = createControlFlows(methodLocation, methodData, projectModel);
	methodCollection = [ createPDT(method) | method <- methodCollection ];
	methodCollection = [ createCDG(method) | method <- methodCollection ];
	methodCollection = [ createDDG(method) | method <- methodCollection ];
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	map[str, set[str]] totalDefs = ();
	
	for(method <- methodCollection) {
		edges += createEdges(method.name, method.controlDependence.graph, "solid", "blue");
		edges += createEdges(method.name, method.dataDependence.graph, "dash", "green");
		
		boxes += createBoxes(method);
		boxes += box(text("ENTRY <method.name>"), id("<method.name>:<ENTRYNODE>"), size(50), fillColor("lightblue"));
		
		for(key <- method.dataDependence.defs) {
			for(\value <- method.dataDependence.defs[key]) {
				if(key in totalDefs) {
					totalDefs[key] += { "<method.name>:<\value>" };
				} else {
					totalDefs[key] = { "<method.name>:<\value>" };
				}
			}
		}
	}
	
	for(method <- methodCollection) {
		println("===== <method.name> =====");
		
		for(key <- domain(method.parameterNodes), key >= 0) {
			if(key in method.dataDependence.uses) {
				println("Key[<method.name><key>] uses: <method.dataDependence.uses[key]>");
				
				for(usedVariable <- method.dataDependence.uses[key]) {
					if(/\$.*/ := usedVariable && usedVariable in totalDefs) {
						for(definition <- totalDefs[usedVariable]) {
							edges += edge("<definition>", "<method.name>:<key>", 
										lineStyle("dash"), lineColor("lightgreen"), toArrow(box(size(10), 
										fillColor("lightgreen"))));
						}
					}
				}
			}
			
			int \value = method.parameterNodes[key];
			
			if(\value < 0) {
				continue;
			}
			if(Expression expression := resolveIdentifier(method, \value)){
				edges += edge("<method.name>:<\value>", "<expression.name>:<ENTRYNODE>", 
					lineStyle("dash"), lineColor("blue"), toArrow(box(size(10), 
					fillColor("blue"))));
			}
		}
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}