@contributor{Lulu Zhang - UvA MSc 2014}
@contributor{René Bulsing - UvA MSc 2015}
@contributor{Vadim Zaytsev - UvA - http://grammarware.net}
module \test::TestDDG

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import analysis::graphs::Graph;

import framework::RTest;
import extractors::Project;
import graph::DataStructures;
import graph::\data::DDG;
import graph::control::flow::CFG;

private M3 projectModel = createM3(|project://JavaTest|);

private Graph[int] getMethodDDG(loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	GeneratedData generatedData = createCFG(projectModel, cast(#Declaration, methodAST));
	DataDependence dataDependence = createDDG(generatedData.methodData, generatedData.controlFlow);
	
	return dataDependence.graph;
}

public bool testDDG(str name, expected)
{	
	input = getOneFrom([method | method <- getM3Methods(projectModel), /<name>\(/ := method.file]);
	output = getMethodDDG(input);
	if(output != expected)
		println("[<name>]: <input> FAILED.
				'\tGot <output>.
				'\tExpected <expected>.");
	return output == expected;
}

test bool testIf1() = testDDG("testIf1",
	{ <0,1> });
test bool testIf1Alternate() = testDDG("testIf1Alternate",
	{ <0,1> });
test bool testIf2() = testDDG("testIf2",
	{ <0,1> });
test bool testIf2Alternate() = testDDG("testIf2Alternate",
	{ <0,1> });
test bool testIf3() = testDDG("testIf3",
	{ <0,1>, <0,3> });
test bool testIf3Alternate() = testDDG("testIf3Alternate",
	{ <0,1>, <0,3> });
test bool testIf4() = testDDG("testIf4",
	{ <0,1>, <0,3> });
test bool testIf4Alternate() = testDDG("testIf4Alternate",
	{ <0,1>, <0,3> });
test bool testIf5() = testDDG("testIf5",
	{ <0,1>, <0,4> });

test bool testFor1() = testDDG("testFor1",
	{ <2,2>, <0,2>, <1,1> });
test bool testFor1Alternate() = testDDG("testFor1Alternate",
	{ <2,2>, <0,2>, <1,1> });
test bool testFor2() = testDDG("testFor2",
	{ <2,1>, <0,1>, <1,1> });
test bool testFor2Alternate() = testDDG("testFor2Alternate",
	{ <2,1>, <0,1>, <1,1> });

test bool testWhile1() = testDDG("testWhile1",
	{ <0,1>, <0,2>, <2,1>, <2,2> });
test bool testWhile1Alternate() = testDDG("testWhile1Alternate",
	{ <0,1>, <0,2>, <2,1>, <2,2> });
test bool testWhile2() = testDDG("testWhile2",
	{ <0,1>, <0,2>, <2,1>, <2,2> });
test bool testWhile2Alternate() = testDDG("testWhile2Alternate",
	{ <0,1>, <0,2>, <2,1>, <2,2> });
test bool testDoWhile1() = testDDG("testDoWhile1",
	{ <0,2>, <2,1>, <2,2> });
test bool testDoWhile2() = testDDG("testDoWhile2",
	{ <0,2>, <2,1>, <2,2> });

test bool testReturn1() = testDDG("testReturn1",
	{ <0,1> });
test bool testReturn1Alternate() = testDDG("testReturn1Alternate",
	{ <0,1> });
test bool testReturn2() = testDDG("testReturn2",
	{ <0,1>, <0,3> });
test bool testReturn2Alternate() = testDDG("testReturn2Alternate",
	{ <0,1>, <0,3> });

test bool testSwitch1() = testDDG("testSwitch1",
	{ <0,1> });
test bool testSwitch2() = testDDG("testSwitch2",
	{ <0,1> });
test bool testSwitch3() = testDDG("testSwitch3",
	{ <0,1> });
test bool testSwitch4() = testDDG("testSwitch4",
	{ <0,1> });
test bool testSwitch5() = testDDG("testSwitch5",
	{ <0,1> });
test bool testSwitch6() = testDDG("testSwitch6",
	{ <0,1> });
test bool testSwitch7() = testDDG("testSwitch7",
	{ <0,1> });
test bool testSwitch8() = testDDG("testSwitch8",
	{ <0,1> });

test bool testTry1() = testDDG("testTry1",
	{ <0,2> });
test bool testTry2() = testDDG("testTry2",
	{ <0,2>, <2,5>, <4,5> });
test bool testTry3() = testDDG("testTry3",
	{ <0,2>, <2,5>, <4,5> });
test bool testTry4() = testDDG("testTry4",
	{ <0,2>, <2,5>, <4,5>, <5,6> });
test bool testTry5() = testDDG("testTry5",
	{ <0,2>, <2,4>, <2,6>, <4,7>, <6,7>, <2,7> });
test bool testTry6() = testDDG("testTry6",
	{ <0,2>, <2,4>, <2,6>, <4,7>, <6,7>, <2,7>, <7,8> });

test bool testThrow1() = testDDG("testThrow1",
	{ <0,1> });
test bool testThrow1Alternate() = testDDG("testThrow1Alternate",
	{ <0,1> });
test bool testThrow2() = testDDG("testThrow2",
	{ <0,1>, <0,3> });
test bool testThrow2Alternate() = testDDG("testThrow2Alternate",
	{ <0,1>, <0,3> });
test bool testThrow3() = testDDG("testThrow3",
	{ <0,1>, <0,4> });
test bool testThrow4() = testDDG("testThrow4",
	{ <0,1>, <0,4> });
test bool testThrow5() = testDDG("testThrow5",
	{ <0,1>, <0,4> });

test bool testBreak1() = testDDG("testBreak1",
	{ <0,1>, <0,2>, <4,1>, <4,2> });
test bool testBreak2() = testDDG("testBreak2",
	{ <0,1>, <0,2>, <4,1>, <4,2>, <0,5>, <4,5> });
test bool testBreak3() = testDDG("testBreak3",
	{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3> });
test bool testBreak4() = testDDG("testBreak4",
	{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3>, <6,7>, <0,7> });

test bool testContinue1() = testDDG("testContinue1",
	{ <0,1>, <0,2>, <4,1>, <4,2> });
test bool testContinue2() = testDDG("testContinue2",
	{ <0,1>, <0,2>, <4,1>, <4,2>, <0,5>, <4,5> });
test bool testContinue3() = testDDG("testContinue3",
	{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3> });
test bool testContinue4() = testDDG("testContinue4",
	{ <0,1>, <0,2>, <0,3>, <5,2>, <5,3>, <6,1>, <6,2>, <6,3>, <6,7>, <0,7> });

test bool testCompound1() = testDDG("testCompound1",
	{ <0,1>, <0,2>, <0,3>, <0,4>, <0,5>, <0,6>, <2,2> , <3,2>, <3,3>, <3,4>, <6,7>, <7,5>, <7,6> });
test bool testCompound2() = testDDG("testCompound2",
	{ <0,2>, <1,4>, <0,15>, <6,18>, <10,18>, <13,18>, <17,18> });

test bool testUse1() = testDDG("testUse1",
	{ <0,1>, <1,2>, <2,2>, <0,4>, <1,4>, <2,4> });
test bool testUse2() = testDDG("testUse2",
	{ <0,2>, <1,2>, <0,3>, <1,3>, <3,2>, <3,3>, <0,5>, <5,5>, <5,7>, <5,2>, <5,3>, <0,7>, <1,7>, <3,7>, <7,8> });
test bool testUse3() = testDDG("testUse3",
	{ <0,1>, <1,5>, <2,6>, <3,5>, <3,6>, <4,5>, <4,6>, <5,6>, <1,6> });
test bool testUse4() = testDDG("testUse4",
	{ <0,1>, <0,2>, <0,3>, <1,2> });

test bool testDef() = testDDG("testDef",
	{ <1,2>, <1,6>, <1,2>, <1,3>, <2,4>, <4,5>, <6,6>, <6,8>, <5,8> });
