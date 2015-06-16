module \test::TestCFG

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import framework::RTest;
import extractors::Project;
import graph::DataStructures;
import graph::control::flow::CFG;

private M3 projectModel;

public loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

public Graph[int] getMethodCFG(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(projectModel, cast(#Declaration, methodAST));
	
	return generatedData.controlFlow.graph;
}

private ControlFlow getMethodCF(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	return createCFG(projectModel, cast(#Declaration, methodAST)).controlFlow;
}

test bool testIf() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testIf1", projectModel): { <0,1>, <1,2>, <1,3>, <2,3> },
		getMethodLocation("testIf1Alternate", projectModel): { <0,1>, <1,2>, <1,3>, <2,3> },
		getMethodLocation("testIf2", projectModel): { <0,1>, <1,2>, <1,3>, <2,4>, <3,4> },
		getMethodLocation("testIf2Alternate", projectModel): { <0,1>, <1,2>, <1,3>, <2,4>, <3,4> },
		getMethodLocation("testIf3", projectModel): { <0,1>, <1,2>, <2,5>, <1,3>, <3,4>, <4,5>, <3,5> },
		getMethodLocation("testIf3Alternate", projectModel): { <0,1>, <1,2>, <2,5>, <1,3>, <3,4>, <4,5>, <3,5> },
		getMethodLocation("testIf4", projectModel): { <0,1>, <1,2>, <2,6>, <1,3>, <3,4>, <4,6>, <3,5>, <5,6> },
		getMethodLocation("testIf4Alternate", projectModel): { <0,1>, <1,2>, <2,6>, <1,3>, <3,4>, <4,6>, <3,5>, <5,6> },
		getMethodLocation("testIf5", projectModel): { <0,1>, <1,2>, <2,3>, <3,9>, <1,4>, <4,5>, <5,6>, <6,9>, <4,7>, <7,8>, <8,9> }
	);
	
	return RTestFunction("TestIf", getMethodCFG, assertions);
}

test bool testFor() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testFor1", projectModel): { <0,1>, <1,2>, <2,1> },
		getMethodLocation("testFor1Alternate", projectModel): { <0,1>, <1,2>, <2,1> },
		getMethodLocation("testFor2", projectModel): { <0,1>, <1,2>, <2,1>, <1,3> },
		getMethodLocation("testFor2Alternate", projectModel): { <0,1>, <1,2>, <2,1>, <1,3> }
	);
	
	return RTestFunction("TestFor", getMethodCFG, assertions);
}

test bool testWhile() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testWhile1", projectModel): { <0,1>, <1,2>, <2,1> },
		getMethodLocation("testWhile1Alternate", projectModel): { <0,1>, <1,2>, <2,1> },
		getMethodLocation("testWhile2", projectModel): { <0,1>, <1,2>, <2,1>, <1,3> },
		getMethodLocation("testWhile2Alternate", projectModel): { <0,1>, <1,2>, <2,1>, <1,3> },
		getMethodLocation("testDoWhile1", projectModel): { <0,2>, <2,1>, <1,2> },
		getMethodLocation("testDoWhile2", projectModel): { <0,2>, <2,1>, <1,2>, <1,3> }
	);
	
	return RTestFunction("TestFor", getMethodCFG, assertions);
}

test bool testReturn() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testReturn1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}),
		getMethodLocation("testReturn1Alternate", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}),
		getMethodLocation("testReturn2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}),
		getMethodLocation("testReturn2Alternate", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5})
	);
	
	return RTestFunction("TestReturn", getMethodCF, assertions);
}

test bool testSwitch() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testSwitch1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6> }, 0, {7}),
		getMethodLocation("testSwitch2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6>, <7,8> }, 0, {8}),
		getMethodLocation("testSwitch3", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,8>, <8,9>, <9,10> }, 0, {4, 7, 10}),
		getMethodLocation("testSwitch4", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,8>, <8,9>, <9,10>, <4,11>, <7,11>, <10,11> }, 0, {11}),
		getMethodLocation("testSwitch5", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,7>, <7,8>, <8,9> }, 0, {4, 9}),
		getMethodLocation("testSwitch6", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,7>, <7,8>, <8,9>, <4, 10>, <9, 10> }, 0, {10}),
		getMethodLocation("testSwitch7", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6> }, 0, {1, 7}),
		getMethodLocation("testSwitch8", projectModel): 
			ControlFlow({ <0,1>, <1,8>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6>, <7,8> }, 0, {8})
	);
	
	return RTestFunction("TestSwitch", getMethodCF, assertions);
}

test bool testTry() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testTry1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4> }, 0, {2, 4}),
		getMethodLocation("testTry2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,5>, <2,3>, <3,4>, <4,5> }, 0, {5}),
		getMethodLocation("testTry3", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,5>, <2,3>, <3,4>, <4,5> }, 0, {5}),
		getMethodLocation("testTry4", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,5>, <2,3>, <3,4>, <4,5>, <5,6> }, 0, {6}),
		getMethodLocation("testTry5", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <2,5>, <2,7>, <3,4>, <4,7>, <5,6>, <6,7> }, 0, {7}),
		getMethodLocation("testTry6", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <2,5>, <2,7>, <3,4>, <4,7>, <5,6>, <6,7>, <7,8> }, 0, {8})
	);
	
	return RTestFunction("TestTry", getMethodCF, assertions);
}

test bool testThrow() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testThrow1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}),
		getMethodLocation("testThrow1Alternate", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}),
		getMethodLocation("testThrow2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}),
		getMethodLocation("testThrow2Alternate", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}),
		getMethodLocation("testThrow3", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,7>, <4,5>, <5,6>, <6,7> }, 0, {2, 7}),
		getMethodLocation("testThrow4", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,8>, <4,5>, <5,6>, <6,7> }, 0, {2, 7, 8}),
		getMethodLocation("testThrow5", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5>, <4,6>, <5,6>, <6,7>, <7,8> }, 0, {2, 8})
	);
	
	return RTestFunction("TestThrow", getMethodCF, assertions);
}

test bool testBreak() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testBreak1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <2,4>, <4,1> }, 0, {1, 3}),
		getMethodLocation("testBreak2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <2,4>, <4,1>, <1,5>, <3,5> }, 0, {5}),
		getMethodLocation("testBreak3", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <3,5>, <4,6>, <5,2>, <2,6>, <6,1> }, 0, {1}),
		getMethodLocation("testBreak4", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <3,5>, <4,6>, <5,2>, <2,6>, <6,1>, <1,7> }, 0, {7})
	);
	
	return RTestFunction("TestBreak", getMethodCF, assertions);
}

test bool testContinue() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testContinue1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,1>, <2,4>, <4,1> }, 0, {1}),
		getMethodLocation("testContinue2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,1>, <2,4>, <4,1>, <1,5> }, 0, {5}),
		getMethodLocation("testContinue3", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,2>, <3,5>, <5,2>, <2,6>, <6,1> }, 0, {1}),
		getMethodLocation("testContinue4", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,2>, <3,5>, <5,2>, <2,6>, <6,1>, <1,7> }, 0, {7})
	);
	
	return RTestFunction("TestContinue", getMethodCF, assertions);
}

test bool testCompound() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, ControlFlow] assertions = (
		getMethodLocation("testCompound1", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,2>, <2,4>, <4,8>, <1,5>, <5,6>, <6,7>, <7,5>, <5,8> }, 0, {8}),
		getMethodLocation("testCompound2", projectModel): 
			ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <4,7>, <7,8>, <8,9>, <9,10>, 
							<2,11>, <11,12>, <12,13>, <2,14>, <14,15>, <15,16>, <16,17>, <6,18>, <10,18>, <13,18>, <17,18> }, 0, {18})
	);
	
	return RTestFunction("TestCompound", getMethodCF, assertions);
}