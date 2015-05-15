module \test::TestCDG

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import framework::RTest;
import extractors::Project;
import graph::DataStructures;
import graph::control::PDT;
import graph::control::flow::CFG;
import graph::control::dependence::CDG;

private M3 projectModel;

private loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

private Graph[int] getMethodCDG(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(cast(#Declaration, methodAST));
	PostDominator postDominator = createPDT(generatedData.methodData, generatedData.controlFlow);
	ControlDependence controlDependence = createCDG(generatedData.methodData, generatedData.controlFlow, postDominator);
	
	return controlDependence.graph;
}

test bool testIf() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testIf1", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> },
		getMethodLocation("testIf1Alternate", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> },
		getMethodLocation("testIf2", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <ENTRYNODE, 4> },
		getMethodLocation("testIf2Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <ENTRYNODE, 4> },
		getMethodLocation("testIf3", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <ENTRYNODE, 5> },
		getMethodLocation("testIf3Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <ENTRYNODE, 5> },
		getMethodLocation("testIf4", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <3,5>, <ENTRYNODE, 6> },
		getMethodLocation("testIf4Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <3,5>, <ENTRYNODE, 6> },
		getMethodLocation("testIf5", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <4,7>, <4,8>, <ENTRYNODE, 9> }
	);
	
	return RTestFunction("TestIf", getMethodCDG, assertions);
}

test bool testFor() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testFor1", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> },
		getMethodLocation("testFor1Alternate", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> },
		getMethodLocation("testFor2", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> },
		getMethodLocation("testFor2Alternate", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	);
	
	return RTestFunction("TestFor", getMethodCDG, assertions);
}

test bool testWhile() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testWhile1", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> },
		getMethodLocation("testWhile1Alternate", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> },
		getMethodLocation("testWhile2", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> },
		getMethodLocation("testWhile2Alternate", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> },
		getMethodLocation("testDoWhile1", projectModel):
			{ <ENTRYNODE, 0>, <1, 2>, <ENTRYNODE, 1> },
		getMethodLocation("testDoWhile2", projectModel): 
			{ <ENTRYNODE, 0>, <1, 2>, <ENTRYNODE, 1>, <ENTRYNODE, 3> }
	);
	
	return RTestFunction("TestFor", getMethodCDG, assertions);
}

test bool testReturn() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testReturn1", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3> },
		getMethodLocation("testReturn1Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3> },
		getMethodLocation("testReturn2", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5> },
		getMethodLocation("testReturn2Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5> }
	);
	
	return RTestFunction("TestReturn", getMethodCDG, assertions);
}

test bool testSwitch() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testSwitch1", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <ENTRYNODE,6>, <ENTRYNODE,7> },
		getMethodLocation("testSwitch2", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <ENTRYNODE,6>, <ENTRYNODE,7>, <ENTRYNODE, 8> },
		getMethodLocation("testSwitch3", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9>, <1,10> },
		getMethodLocation("testSwitch4", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9>, <1,10>, <ENTRYNODE, 11> },
	  	getMethodLocation("testSwitch5", projectModel):
	  		{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9> },
	 	getMethodLocation("testSwitch6", projectModel):
	 		{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9>, <ENTRYNODE, 10> },
	  	getMethodLocation("testSwitch7", projectModel):
	  		{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7> },
	  	getMethodLocation("testSwitch8", projectModel):
	  	 	{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <ENTRYNODE, 8> }
	);
	
	return RTestFunction("TestSwitch", getMethodCDG, assertions);
}

test bool testTry() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testTry1", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4> },
		getMethodLocation("testTry2", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <ENTRYNODE, 5> },
		getMethodLocation("testTry3", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <ENTRYNODE, 5> },
		getMethodLocation("testTry4", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <ENTRYNODE, 5>, <ENTRYNODE, 6> },
		getMethodLocation("testTry5", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <2,5>, <2,6>, <ENTRYNODE, 7> },
		getMethodLocation("testTry6", projectModel):
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <2,5>, <2,6>, <ENTRYNODE, 7>, <ENTRYNODE, 8> }
	);
	
	return RTestFunction("TestTry", getMethodCDG, assertions);
}

test bool testThrow() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testThrow1", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3> },
		getMethodLocation("testThrow1Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3> },
		getMethodLocation("testThrow2", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5> },
		getMethodLocation("testThrow2Alternate", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5> },
		getMethodLocation("testThrow3", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <1,7> },
		getMethodLocation("testThrow4", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <4,7>, <4,8> },
		getMethodLocation("testThrow5", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <1,6>, <1,7>, <1,8> }
	);
	
	return RTestFunction("TestThrow", getMethodCDG, assertions);
}

test bool testBreak() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testBreak1", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <2,4> },
		getMethodLocation("testBreak2", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <2,4>, <ENTRYNODE, 5> },
		getMethodLocation("testBreak3", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,6>, <2,3>, <3,4>, <3,5> },
		getMethodLocation("testBreak4", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,6>, <2,3>, <3,4>, <3,5>, <ENTRYNODE, 7> }
	);
	
	return RTestFunction("TestBreak", getMethodCDG, assertions);
}

test bool testContinue() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testContinue1", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <2,4> },
		getMethodLocation("testContinue2", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <2,4>, <ENTRYNODE, 5> },
		getMethodLocation("testContinue3", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <3,4>, <3,5>, <1,6> },
		getMethodLocation("testContinue4", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <3,4>, <3,5>, <1,6>, <ENTRYNODE, 7> }
	);
	
	return RTestFunction("TestContinue", getMethodCDG, assertions);
}

test bool testCompound() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testCompound1", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <1,4>, <1,5>, <5,6>, <5,7>, <ENTRYNODE, 8> },
		getMethodLocation("testCompound2", projectModel): 
			{ <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <4,5>, <5,6>, <4,7>, <7,8>, <4,9>, <9,10>,
	  			<2,11>, <2,12>, <12,13>, <2,14>, <2,15>, <2,16>, <16,17>, <ENTRYNODE,18> }
	);
	
	return RTestFunction("TestCompound", getMethodCDG, assertions);
}