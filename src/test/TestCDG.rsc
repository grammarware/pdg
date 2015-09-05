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

private M3 projectModel = createM3(|project://JavaTest|);

private Graph[int] getMethodCDG(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(projectModel, cast(#Declaration, methodAST));
	PostDominator postDominator = createPDT(generatedData.methodData, generatedData.controlFlow);
	ControlDependence controlDependence = createCDG(generatedData.methodData, generatedData.controlFlow, postDominator);
	
	return controlDependence.graph;
}

public bool testCDG(str name, expected)
{	
	input = getOneFrom([method | method <- getM3Methods(projectModel), /<name>\(/ := method.file]);
	output = getMethodCDG(input);
	if(output != expected)
		println("[<name>]: <input> FAILED.
				'\tGot <output>.
				'\tExpected <expected>.");
	return output == expected;
}

test bool testIf1() = testCDG("testIf1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <ENTRYNODE,3> });
test bool testIf1Alternate() = testCDG("testIf1Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <ENTRYNODE,3> });
test bool testIf2() = testCDG("testIf2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <ENTRYNODE,4> });
test bool testIf2Alternate() = testCDG("testIf2Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <ENTRYNODE,4> });
test bool testIf3() = testCDG("testIf3",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <3,4>, <ENTRYNODE,5> });
test bool testIf3Alternate() = testCDG("testIf3Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <3,4>, <ENTRYNODE,5> });
test bool testIf4() = testCDG("testIf4",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <3,4>, <3,5>, <ENTRYNODE,6> });
test bool testIf4Alternate() = testCDG("testIf4Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <3,4>, <3,5>, <ENTRYNODE,6> });
test bool testIf5() = testCDG("testIf5",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <4,7>, <4,8>, <ENTRYNODE,9> });

test bool testFor1() = testCDG("testFor1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2> });
test bool testFor1Alternate() = testCDG("testFor1Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2> });
test bool testFor2() = testCDG("testFor2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <ENTRYNODE,3> });
test bool testFor2Alternate() = testCDG("testFor2Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <ENTRYNODE,3> });
	
test bool testWhile1() = testCDG("testWhile1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2> });
test bool testWhile1Alternate() = testCDG("testWhile1Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2> });
test bool testWhile2() = testCDG("testWhile2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <ENTRYNODE,3> });
test bool testWhile2Alternate() = testCDG("testWhile2Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <ENTRYNODE,3> });

test bool testDoWhile1() = testCDG("testDoWhile1",
	{ <ENTRYNODE,0>, <1,2>, <ENTRYNODE,1> });
test bool testDoWhile2() = testCDG("testDoWhile2",
	{ <ENTRYNODE,0>, <1,2>, <ENTRYNODE,1>, <ENTRYNODE,3> });

test bool testReturn1() = testCDG("testReturn1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3> });
test bool testReturn1Alternate() = testCDG("testReturn1Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3> });
test bool testReturn2() = testCDG("testReturn2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5> });
test bool testReturn2Alternate() = testCDG("testReturn2Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5> });

test bool testSwitch1() = testCDG("testSwitch1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <ENTRYNODE,6>, <ENTRYNODE,7> });
test bool testSwitch2() = testCDG("testSwitch2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <ENTRYNODE,6>, <ENTRYNODE,7>, <ENTRYNODE,8> });
test bool testSwitch3() = testCDG("testSwitch3",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9>, <1,10> });
test bool testSwitch4() = testCDG("testSwitch4",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9>, <1,10>, <ENTRYNODE,11> });
test bool testSwitch5() = testCDG("testSwitch5",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9> });
test bool testSwitch6() = testCDG("testSwitch6",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <1,8>, <1,9>, <ENTRYNODE,10> });
test bool testSwitch7() = testCDG("testSwitch7",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7> });
test bool testSwitch8() = testCDG("testSwitch8",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5>, <1,6>, <1,7>, <ENTRYNODE,8> });

test bool testTry1() = testCDG("testTry1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4> });
test bool testTry2() = testCDG("testTry2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4>, <ENTRYNODE,5> });
test bool testTry3() = testCDG("testTry3",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4>, <ENTRYNODE,5> });
test bool testTry4() = testCDG("testTry4",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4>, <ENTRYNODE,5>, <ENTRYNODE,6> });
test bool testTry5() = testCDG("testTry5",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4>, <2,5>, <2,6>, <ENTRYNODE,7> });
test bool testTry6() = testCDG("testTry6",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4>, <2,5>, <2,6>, <ENTRYNODE,7>, <ENTRYNODE,8> });

test bool testThrow1() = testCDG("testThrow1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3> });
test bool testThrow1Alternate() = testCDG("testThrow1Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3> });
test bool testThrow2() = testCDG("testThrow2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5> });
test bool testThrow2Alternate() = testCDG("testThrow2Alternate",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <1,5> });
test bool testThrow3() = testCDG("testThrow3",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <1,7> });
test bool testThrow4() = testCDG("testThrow4",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <4,7>, <4,8> });
test bool testThrow5() = testCDG("testThrow5",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,3>, <1,4>, <4,5>, <1,6>, <1,7>, <1,8> });

test bool testBreak1() = testCDG("testBreak1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <2,4> });
test bool testBreak2() = testCDG("testBreak2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <2,4>, <ENTRYNODE,5> });
test bool testBreak3() = testCDG("testBreak3",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,6>, <2,3>, <3,4>, <3,5> });
test bool testBreak4() = testCDG("testBreak4",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <1,6>, <2,3>, <3,4>, <3,5>, <ENTRYNODE,7> });

test bool testContinue1() = testCDG("testContinue1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <2,4> });
test bool testContinue2() = testCDG("testContinue2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <2,4>, <ENTRYNODE,5> });
test bool testContinue3() = testCDG("testContinue3",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <3,4>, <3,5>, <1,6> });
test bool testContinue4() = testCDG("testContinue4",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <3,4>, <3,5>, <1,6>, <ENTRYNODE,7> });
test bool testCompound1() = testCDG("testCompound1",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <1,2>, <2,3>, <1,4>, <1,5>, <5,6>, <5,7>, <ENTRYNODE,8> });
test bool testCompound2() = testCDG("testCompound2",
	{ <ENTRYNODE,0>, <ENTRYNODE,1>, <ENTRYNODE,2>, <2,3>, <2,4>, <4,5>, <5,6>, <4,7>, <7,8>, <4,9>, <9,10>, <2,11>, <2,12>, <12,13>, <2,14>, <2,15>, <2,16>, <16,17>, <ENTRYNODE,18> });
