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
		
	ControlFlows controlFlows = createControlFlows(methodLocation, methodAST, projectModel);
	PostDominators postDominators = ( method : createPDT(method, controlFlows[method]) | method <- controlFlows );
	ControlDependences controlDependences = 
		( 
			method : createCDG(method, controlFlows[method], postDominators[method]) 
			| method <- postDominators 
		);
	DataDependences dataDependences = ( method : createDDG(method, controlFlows[method]) | method <- controlFlows );
	
	list[Edge] edges = [];
	list[Figure] boxes = [];
	
	map[str, set[str]] totalDefs = ();
	
	for(method <- controlFlows) {
		edges += createEdges(method.name, controlDependences[method].graph, "solid", "blue");
		edges += createEdges(method.name, dataDependences[method].graph, "dash", "green");
		
		boxes += createBoxes(method);
		boxes += box(text("ENTRY <method.name>"), id("<method.name>:<ENTRYNODE>"), size(50), fillColor("lightblue"));
		
		for(key <- dataDependences[method].defs) {
			for(\value <- dataDependences[method].defs[key]) {
				if(key in totalDefs) {
					totalDefs[key] += { "<method.name>:<\value>" };
				} else {
					totalDefs[key] = { "<method.name>:<\value>" };
				}
			}
		}
	}
	
	for(method <- controlFlows) {
		println("===== <method.name> =====");
		
		for(key <- domain(method.parameterNodes), key >= 0) {
			if(key in dataDependences[method].uses) {
				println("Key[<method.name>:<key>] uses: <dataDependences[method].uses[key]>");
				
				for(usedVariable <- dataDependences[method].uses[key]) {
					if(/\$.*/ := usedVariable && usedVariable in totalDefs) {
						println("Key[<method.name>:<key>] defs: <totalDefs[usedVariable]>");
						
						for(definition <- totalDefs[usedVariable]) {
							edges += edge("<definition>", "<method.name>:<key>", 
										lineStyle("dash"), lineColor("lime"), toArrow(box(size(10), 
										fillColor("lime"))));
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
					lineStyle("dash"), lineColor("deepskyblue"), toArrow(box(size(10), 
					fillColor("deepskyblue"))));
			}
		}
	}
	
	render(graph(boxes, edges, hint("layered"), gap(50)));
}