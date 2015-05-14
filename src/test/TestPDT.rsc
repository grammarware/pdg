module \test::TestPDT

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import framework::RTest;
import extractors::Project;
import graph::DataStructures;
import graph::control::PDT;
import graph::control::flow::CFG;

private M3 projectModel;

private loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

private Graph[int] getMethodPDT(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(cast(#Declaration, methodAST));
	PostDominator postDominator = createPDT(generatedData.methodData, generatedData.controlFlow);
	
	return postDominator.tree;
}

private Graph[int] getMethodCFG(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(cast(#Declaration, methodAST));
	
	return generatedData.controlFlow.graph;
}

private ControlFlow getMethodCF(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	return createCFG(cast(#Declaration, methodAST)).controlFlow;
}

test bool testIf() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testIf1", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,2>, <3,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf1Alternate", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,2>, <3,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf2", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <4,2>, <4,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf2Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <4,2>, <4,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf3", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <5,3>, <5,2>, <5,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf3Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <5,3>, <5,2>, <5,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf4", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <6,4>, <6,3>, <6,2>, <6,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf4Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <6,4>, <6,3>, <6,2>, <6,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testIf5", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 9>, <9,8>, <9,6>, <9,4>, <9,3>, <9,1>, <8,7>, <6,5>, <3,2>, <1,0>, <0, STARTNODE> }
	);
	
	return RTestFunction("TestIf", getMethodPDT, assertions);
}

test bool testFor() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testFor1", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testFor1Alternate", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testFor2", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testFor2Alternate", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> }
	);
	
	return RTestFunction("TestFor", getMethodPDT, assertions);
}

test bool testWhile() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testWhile1", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testWhile1Alternate", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testWhile2", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testWhile2Alternate", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testDoWhile1", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <2,0>, <0, STARTNODE> },
		getMethodLocation("testDoWhile2", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <2,0>, <0, STARTNODE> }
	);
	
	return RTestFunction("TestFor", getMethodPDT, assertions);
}

test bool testReturn() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testReturn1", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testReturn1Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testReturn2", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testReturn2Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	);
	
	return RTestFunction("TestReturn", getMethodPDT, assertions);
}

test bool testSwitch() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testSwitch1", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE,7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <6,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testSwitch2", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE,8>, <8,7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <6,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testSwitch3", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE,10>, <10,9>, <9,8>, <EXITNODE,7>, <7,6>, <6,5>, <EXITNODE,4>, 
				<4,3>, <3,2>, <EXITNODE,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testSwitch4", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE,11>, <11,10>, <11,7>, <11,4>, <11,1>, <10,9>, <9,8>, 
	  			<7,6>, <6,5>, <4,3>, <3,2>, <1,0>, <0,STARTNODE> },
	  	getMethodLocation("testSwitch5", projectModel):
	  		{ <EXITNODE, ENTRYNODE>, <EXITNODE,9>, <9,8>, <8,7>, <7,6>, <6,5>, <4,3>, <3,2>, 
	 			<1,0>, <EXITNODE,4>, <EXITNODE,1>,<0,STARTNODE> },
	 	getMethodLocation("testSwitch6", projectModel):
	 		{ <EXITNODE, ENTRYNODE>, <EXITNODE,10>, <10,9>, <9,8>, <8,7>, <7,6>, <6,5>, <4,3>, <3,2>, 
	  			<1,0>, <10,4>, <10,1>, <0,STARTNODE> },
	  	getMethodLocation("testSwitch7", projectModel):
	  		{ <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <EXITNODE,1>,
	 			<1,0>, <0,STARTNODE> },
	  	getMethodLocation("testSwitch8", projectModel):
	  	 	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <8,1>,
	 			<1,0>, <0,STARTNODE> }
	);
	
	return RTestFunction("TestSwitch", getMethodPDT, assertions);
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