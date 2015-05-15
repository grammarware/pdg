module \test::TestDDG

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import framework::RTest;
import extractors::Project;
import graph::DataStructures;
import graph::\data::DDG;
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

private Graph[int] getMethodDDG(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(cast(#Declaration, methodAST));
	DataDependence dataDependence = createDDG(generatedData.methodData, generatedData.controlFlow);
	
	return dataDependence.graph;
}

test bool testIf() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testIf1", projectModel):
			{ <0,1> },
		getMethodLocation("testIf1Alternate", projectModel):
			{ <0,1> },
		getMethodLocation("testIf2", projectModel): 
			{ <0,1> },
		getMethodLocation("testIf2Alternate", projectModel): 
			{ <0,1> },
		getMethodLocation("testIf3", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testIf3Alternate", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testIf4", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testIf4Alternate", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testIf5", projectModel): 
			{ <0,1>, <0,4> }
	);
	
	return RTestFunction("TestIf", getMethodDDG, assertions);
}

test bool testFor() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testFor1", projectModel):
			{ <2,2>, <0,2>, <1,1> },
		getMethodLocation("testFor1Alternate", projectModel):
			{ <2,2>, <0,2>, <1,1> },
		getMethodLocation("testFor2", projectModel):
			{ <2,1>, <0,1>, <1,1> },
		getMethodLocation("testFor2Alternate", projectModel):
			{ <2,1>, <0,1>, <1,1> }
	);
	
	return RTestFunction("TestFor", getMethodDDG, assertions);
}

test bool testWhile() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testWhile1", projectModel):
			{ <0,1>, <0,2>, <2,1>, <2,2> },
		getMethodLocation("testWhile1Alternate", projectModel):
			{ <0,1>, <0,2>, <2,1>, <2,2> },
		getMethodLocation("testWhile2", projectModel):
			{ <0,1>, <0,2>, <2,1>, <2,2> },
		getMethodLocation("testWhile2Alternate", projectModel):
			{ <0,1>, <0,2>, <2,1>, <2,2> },
		getMethodLocation("testDoWhile1", projectModel):
			{ <0,2>, <2,1>, <2,2> },
		getMethodLocation("testDoWhile2", projectModel): 
			{ <0,2>, <2,1>, <2,2> }
	);
	
	return RTestFunction("TestFor", getMethodDDG, assertions);
}

test bool testReturn() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testReturn1", projectModel): 
			{ <0,1> },
		getMethodLocation("testReturn1Alternate", projectModel): 
			{ <0,1> },
		getMethodLocation("testReturn2", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testReturn2Alternate", projectModel): 
			{ <0,1>, <0,3> }
	);
	
	return RTestFunction("TestReturn", getMethodDDG, assertions);
}

test bool testSwitch() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testSwitch1", projectModel):
			{ <0,1> },
		getMethodLocation("testSwitch2", projectModel):
			{ <0,1> },
		getMethodLocation("testSwitch3", projectModel):
			{ <0,1> },
		getMethodLocation("testSwitch4", projectModel):
			{ <0,1> },
	  	getMethodLocation("testSwitch5", projectModel):
	  		{ <0,1> },
	 	getMethodLocation("testSwitch6", projectModel):
	 		{ <0,1> },
	  	getMethodLocation("testSwitch7", projectModel):
	  		{ <0,1> },
	  	getMethodLocation("testSwitch8", projectModel):
	  	 	{ <0,1> }
	);
	
	return RTestFunction("TestSwitch", getMethodDDG, assertions);
}

test bool testTry() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testTry1", projectModel):
			{ <0,2> },
		getMethodLocation("testTry2", projectModel):
			{ <0,2>, <2,5>, <4,5> },
		getMethodLocation("testTry3", projectModel):
			{ <0,2>, <2,5>, <4,5> },
		getMethodLocation("testTry4", projectModel):
			{ <0,2>, <2,5>, <4,5>, <5,6> },
		getMethodLocation("testTry5", projectModel):
			{ <0,2>, <2,4>, <2,6>, <4,7>, <6,7>, <2,7> },
		getMethodLocation("testTry6", projectModel):
			{ <0,2>, <2,4>, <2,6>, <4,7>, <6,7>, <2,7>, <7,8> }
	);
	
	return RTestFunction("TestTry", getMethodDDG, assertions);
}

test bool testThrow() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testThrow1", projectModel): 
			{ <0,1> },
		getMethodLocation("testThrow1Alternate", projectModel): 
			{ <0,1> },
		getMethodLocation("testThrow2", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testThrow2Alternate", projectModel): 
			{ <0,1>, <0,3> },
		getMethodLocation("testThrow3", projectModel): 
			{ <0,1>, <0,4> },
		getMethodLocation("testThrow4", projectModel): 
			{ <0,1>, <0,4> },
		getMethodLocation("testThrow5", projectModel): 
			{ <0,1>, <0,4> }
	);
	
	return RTestFunction("TestThrow", getMethodDDG, assertions);
}

test bool testBreak() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testBreak1", projectModel): 
			{ <0,1>, <0,2>, <4,1>, <4,2> },
		getMethodLocation("testBreak2", projectModel): 
			{ <0,1>, <0,2>, <4,1>, <4,2>, <0,5>, <4,5> },
		getMethodLocation("testBreak3", projectModel): 
			{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3> },
		getMethodLocation("testBreak4", projectModel): 
			{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3>, <6,7>, <0,7> }
	);
	
	return RTestFunction("TestBreak", getMethodDDG, assertions);
}

test bool testContinue() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testContinue1", projectModel): 
			{ <0,1>, <0,2>, <4,1>, <4,2> },
		getMethodLocation("testContinue2", projectModel): 
			{ <0,1>, <0,2>, <4,1>, <4,2>, <0,5>, <4,5> },
		getMethodLocation("testContinue3", projectModel): 
			{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3> },
		getMethodLocation("testContinue4", projectModel): 
			{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3>, <6,7>, <0,7> }
	);
	
	return RTestFunction("TestContinue", getMethodDDG, assertions);
}

test bool testCompound() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testCompound1", projectModel): 
			{ <0,1>, <0,2>, <0,3>, <0,4>, <0,5>, <0,6>, <2,2> , <3,2>, <3,3>, <3,4>, <6,7>, <7,5>, <7,6> },
		getMethodLocation("testCompound2", projectModel): 
			{ <0,2>, <1,4>, <0,15>, <6,18>, <10,18>, <13,18>, <17,18> }
	);
	
	return RTestFunction("TestCompound", getMethodDDG, assertions);
}

test bool testUse() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testUse1", projectModel): 
			{ <0,1>, <1,2>, <2,2>, <0,4>, <1,4>, <2,4> },
		getMethodLocation("testUse2", projectModel): 
			{ <0,2>, <1,2>, <0,3>, <1,3>, <3,2>, <3,3>, <0,5>, <5,5>, <5,7>, <5,2>, <5,3>, <0,7>, <1,7>, <3,7>, <7,8> },
		getMethodLocation("testUse3", projectModel):
			{ <0,1>, <1,5>, <2,6>, <3,5>, <3,6>, <4,5>, <4,6>, <5,6>, <1,6> },
		getMethodLocation("testUse4", projectModel):
			{ <0,1>, <0,2>, <0,3>, <1,2> }
	);
	
	return RTestFunction("TestUse", getMethodDDG, assertions);
}

test bool testDef() {
	projectModel = createM3(|project://JavaTest|);
	
	map[loc, Graph[int]] assertions = (
		getMethodLocation("testDef", projectModel): 
			{ <1,2>, <1,6>, <1,2>, <1,3>, <2,4>, <4,5>, <6,6>, <6,8>, <5,8> }
	);
	
	return RTestFunction("TestDef", getMethodDDG, assertions);
}