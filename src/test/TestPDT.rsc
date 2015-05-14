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
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testTry1", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <EXITNODE, 2>, <2,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testTry2", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testTry3", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testTry4", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testTry5", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <7,4>, <4,3>, <7,2>, <2,1>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testTry6", projectModel):
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <7,4>, <4,3>, <7,2>, <2,1>, <1,0>, <0,STARTNODE> }
	);
	
	return RTestFunction("TestTry", getMethodPDT, assertions);
}

test bool testThrow() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testThrow1", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testThrow1Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testThrow2", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testThrow2Alternate", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testThrow3", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <7,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testThrow4", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <EXITNODE, 7>, <7,6>, <6,5>, <EXITNODE, 4>, <4,3>, <EXITNODE,2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testThrow5", projectModel): 
			{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <6,4>, <4,3>, <EXITNODE,2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	);
	
	return RTestFunction("TestThrow", getMethodPDT, assertions);
}

test bool testBreak() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testBreak1", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE, 1>, <1,4>, <1,0>, <0,STARTNODE>, <EXITNODE, 3>, <EXITNODE, 2> },
		getMethodLocation("testBreak2", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE, 5>, <5,3>, <5,2>, <5,1>, <1,4>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testBreak3", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE, 1>, <6,2>, <6,3>, <6,4>, <2,5>, <1,6>, <1,0>, <0, STARTNODE> },
		getMethodLocation("testBreak4", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE, 7>, <7,1>, <6,2>, <6,3>, <6,4>, <2,5>, <1,6>, <1,0>, <0, STARTNODE> }
	);
	
	return RTestFunction("TestBreak", getMethodPDT, assertions);
}

test bool testContinue() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testContinue1", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE,1>, <1,4>, <1,3>, <1,2>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testContinue2", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE,5>, <5,1>, <1,4>, <1,3>, <1,2>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testContinue3", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE,1>, <2,5>, <2,4>, <2,3>, <6,2>, <1,6>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testContinue4", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE,7>, <7,1>, <6,2>, <2,5>, <2,4>, <2,3>, <1,6>, <1,0>, <0,STARTNODE> }
	);
	
	return RTestFunction("TestContinue", getMethodPDT, assertions);
}

test bool testCompound() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testCompound1", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE,8>, <8,5>, <8,4>, <8,1>, <7,6>, <5,7>, <4,2>, <2,3>, <1,0>, <0,STARTNODE> },
		getMethodLocation("testCompound2", projectModel): 
			{ <EXITNODE,ENTRYNODE>, <EXITNODE,18>, <18,17>, <17,16>, <16,15>, <15,14>, <18,13>, <13,12>, <12,11>, <18,10>, <10,9>, <9,8>, 
				<8,7>, <18,6>, <6,5>, <18,4>, <4,3>, <18,2>, <1,0>, <2,1>, <0,STARTNODE> }
	);
	
	return RTestFunction("TestCompound", getMethodPDT, assertions);
}