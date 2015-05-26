module fancy::Seeder

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::Registry;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;

import fancy::Matcher;
import fancy::DataStructures;
import extractors::Project;
import graph::DataStructures;
import graph::call::CallGraph;
import graph::factory::GraphFactory;

data InternalSeed = InternalSeed(MethodData methodData, ProgramDependence programDependence, int identifier);

public list[LineDecoration] getLineDecorations(set[int] lineNumbers) {
	return [ highlight(lineNumber, "Clone") | lineNumber <- lineNumbers ];
}

public Figures createBoxes(map[loc, set[int]] clones) {	
	return [ box(text(clone.file), id(clone.uri), 
						size(50), fillColor("lime"), 
						onMouseDown(
							goToSource(
								clone, getLineDecorations(clones[clone])
							)
						)
				) | clone <- clones ];
}

public bool(int button, map[KeyModifier,bool] modifiers) goToSource(loc location, list[LineDecoration] decorations) =
	bool(int button, map[KeyModifier,bool] modifiers)
	{ 
	    if(button == 1) {
	        edit(location, decorations);
	        return true;
	    }
	    return false;
	};

public InitialSeeds generateSeeds(str firstProject, str secondProject) {
	loc firstProjectLoc = |project://<firstProject>|;
	M3 firstModel = createM3(firstProjectLoc);
	CallGraph firstCallGraph = createCG(firstModel, firstProjectLoc);
	
	loc secondProjectLoc = |project://<secondProject>|;
	M3 secondModel = createM3(secondProjectLoc);
	CallGraph secondCallGraph = createCG(secondModel, secondProjectLoc);
	
	InitialSeeds seeds = generateInitialSeeds(firstCallGraph, secondCallGraph);
	MethodSeeds methodSeeds = {};
	
	for(<first, second> <- seeds) {
		unregisterProject(firstProjectLoc);
		unregisterProject(secondProjectLoc);
	
		registerProject(firstProjectLoc, firstModel);
		SystemDependence firstGraph = getSystemDependence(firstModel, first);
		unregisterProject(firstProjectLoc);
		
		registerProject(secondProjectLoc, secondModel);
		SystemDependence secondGraph = getSystemDependence(secondModel, second);
		unregisterProject(secondProjectLoc);
		
		methodSeeds += { <firstGraph, secondGraph> };
	}
	
	map[loc, set[int]] clones = magic(methodSeeds, firstProjectLoc, firstModel, secondProjectLoc, secondModel);
	
	unregisterProject(firstProjectLoc);
	unregisterProject(secondProjectLoc);
	
	render(graph(createBoxes(clones), [], hint("layered"), gap(50)));
	
	return seeds;
}

public InitialSeeds generateInitialSeeds(CallGraph firstCallGraph, CallGraph secondCallGraph) {
	InitialSeeds seeds = {};
	
	int seedAmount = 1;
	
	for(method <- firstCallGraph.methodCalls) {
		if(method notin secondCallGraph.methodCalls) {
			continue;
		}
		
		loc firstLoc = firstCallGraph.locations[method];
		
		if(/^\$/ := firstLoc.parent.file) {
			continue;
		}
		
		loc secondLoc = secondCallGraph.locations[method];
		
		set[str] firstCalls = firstCallGraph.methodCalls[method];
		set[str] secondCalls = secondCallGraph.methodCalls[method];
		
		if(firstCalls != secondCalls) {
			seeds += <firstLoc, secondLoc>;
			seedAmount += 1;
		}
	}
	
	return seeds;
}

public SystemDependence getSystemDependence(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	return createSystemDependence(methodLocation, methodAST, projectModel, File());
}