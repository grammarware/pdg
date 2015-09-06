@contributor{Lulu Zhang - UvA MSc 2014}
@contributor{René Bulsing - UvA MSc 2015}
@contributor{Vadim Zaytsev - UvA - http://grammarware.net}
module \test::TestCFG

import Prelude;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;

import framework::RTest;
import extractors::Project;
import graph::DataStructures;
import graph::control::flow::CFG;

private M3 projectModel = createM3(|project://JavaTest|);

public bool testCFG(str name, expected)
{	
	input = getOneFrom([method | method <- getM3Methods(projectModel), /<name>\(/ := method.file]);
	output = createCFG(projectModel, cast(#Declaration, getMethodASTEclipse(input, model=projectModel))).controlFlow.graph;
	if(output != expected)
		println("[<name>]: <input> FAILED.
				'\tGot <output>.
				'\tExpected <expected>.");
	return output == expected;
}

public bool testCF(str name, expected)
{	
	input = getOneFrom([method | method <- getM3Methods(projectModel), /<name>\(/ := method.file]);
	output = createCFG(projectModel, cast(#Declaration, getMethodASTEclipse(input, model=projectModel))).controlFlow;
	if(output != expected)
		println("[<name>]: <input> FAILED.
				'\tGot <output>.
				'\tExpected <expected>.");
	return output == expected;
}

test bool testIf1() = testCFG("testIf1",
	{ <0,1>, <1,2>, <1,3>, <2,3> });
test bool testIf1Alternate() = testCFG("testIf1Alternate",
	{ <0,1>, <1,2>, <1,3>, <2,3> });
test bool testIf2() = testCFG("testIf2",
	{ <0,1>, <1,2>, <1,3>, <2,4>, <3,4> });
test bool testIf2Alternate() = testCFG("testIf2Alternate",
	{ <0,1>, <1,2>, <1,3>, <2,4>, <3,4> });
test bool testIf3() = testCFG("testIf3",
	{ <0,1>, <1,2>, <2,5>, <1,3>, <3,4>, <4,5>, <3,5> });
test bool testIf3Alternate() = testCFG("testIf3Alternate",
	{ <0,1>, <1,2>, <2,5>, <1,3>, <3,4>, <4,5>, <3,5> });
test bool testIf4() = testCFG("testIf4",
	{ <0,1>, <1,2>, <2,6>, <1,3>, <3,4>, <4,6>, <3,5>, <5,6> });
test bool testIf4Alternate() = testCFG("testIf4Alternate",
	{ <0,1>, <1,2>, <2,6>, <1,3>, <3,4>, <4,6>, <3,5>, <5,6> });
test bool testIf5() = testCFG("testIf5",
	{ <0,1>, <1,2>, <2,3>, <3,9>, <1,4>, <4,5>, <5,6>, <6,9>, <4,7>, <7,8>, <8,9> });

test bool testFor1() = testCFG("testFor1",
	{ <0,1>, <1,2>, <2,1> });
test bool testFor1Alternate() = testCFG("testFor1Alternate",
	{ <0,1>, <1,2>, <2,1> });
test bool testFor2() = testCFG("testFor2",
	{ <0,1>, <1,2>, <2,1>, <1,3> });
test bool testFor2Alternate() = testCFG("testFor2Alternate",
	{ <0,1>, <1,2>, <2,1>, <1,3> });

test bool testWhile1() = testCFG("testWhile1",
	{ <0,1>, <1,2>, <2,1> });
test bool testWhile1Alternate() = testCFG("testWhile1Alternate",
	{ <0,1>, <1,2>, <2,1> });
test bool testWhile2() = testCFG("testWhile2",
	{ <0,1>, <1,2>, <2,1>, <1,3> });
test bool testWhile2Alternate() = testCFG("testWhile2Alternate",
	{ <0,1>, <1,2>, <2,1>, <1,3> });
test bool testDoWhile1() = testCFG("testDoWhile1",
	{ <0,2>, <2,1>, <1,2> });
test bool testDoWhile2() = testCFG("testDoWhile2",
	{ <0,2>, <2,1>, <1,2>, <1,3> });

test bool testReturn1() = testCF("testReturn1",
	ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}));
test bool testReturn1Alternate() = testCF("testReturn1Alternate",
	ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}));
test bool testReturn2() = testCF("testReturn2",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}));
test bool testReturn2Alternate() = testCF("testReturn2Alternate",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}));

test bool testSwitch1() = testCF("testSwitch1",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6> }, 0, {7}));
test bool testSwitch2() = testCF("testSwitch2",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6>, <7,8> }, 0, {8}));
test bool testSwitch3() = testCF("testSwitch3",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,8>, <8,9>, <9,10> }, 0, {4, 7, 10}));
test bool testSwitch4() = testCF("testSwitch4",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,8>, <8,9>, <9,10>, <4,11>, <7,11>, <10,11> }, 0, {11}));
test bool testSwitch5() = testCF("testSwitch5",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,7>, <7,8>, <8,9> }, 0, {4, 9}));
test bool testSwitch6() = testCF("testSwitch6",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <1,5>, <5,6>, <6,7>, <1,7>, <7,8>, <8,9>, <4, 10>, <9, 10> }, 0, {10}));
test bool testSwitch7() = testCF("testSwitch7",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6> }, 0, {1, 7}));
test bool testSwitch8() = testCF("testSwitch8",
	ControlFlow({ <0,1>, <1,8>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <6,7>, <1,4>, <1,6>, <7,8> }, 0, {8}));

test bool testTry1() = testCF("testTry1",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4> }, 0, {2, 4}));
test bool testTry2() = testCF("testTry2",
	ControlFlow({ <0,1>, <1,2>, <2,5>, <2,3>, <3,4>, <4,5> }, 0, {5}));
test bool testTry3() = testCF("testTry3",
	ControlFlow({ <0,1>, <1,2>, <2,5>, <2,3>, <3,4>, <4,5> }, 0, {5}));
test bool testTry4() = testCF("testTry4",
	ControlFlow({ <0,1>, <1,2>, <2,5>, <2,3>, <3,4>, <4,5>, <5,6> }, 0, {6}));
test bool testTry5() = testCF("testTry5",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <2,5>, <2,7>, <3,4>, <4,7>, <5,6>, <6,7> }, 0, {7}));
test bool testTry6() = testCF("testTry6",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <2,5>, <2,7>, <3,4>, <4,7>, <5,6>, <6,7>, <7,8> }, 0, {8}));

test bool testThrow1() = testCF("testThrow1",
	ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}));
test bool testThrow1Alternate() = testCF("testThrow1Alternate",
	ControlFlow({ <0,1>, <1,2>, <1,3> }, 0, {2, 3}));
test bool testThrow2() = testCF("testThrow2",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}));
test bool testThrow2Alternate() = testCF("testThrow2Alternate",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5> }, 0, {2, 5}));
test bool testThrow3() = testCF("testThrow3",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,7>, <4,5>, <5,6>, <6,7> }, 0, {2, 7}));
test bool testThrow4() = testCF("testThrow4",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,8>, <4,5>, <5,6>, <6,7> }, 0, {2, 7, 8}));
test bool testThrow5() = testCF("testThrow5",
	ControlFlow({ <0,1>, <1,2>, <1,3>, <3,4>, <4,5>, <4,6>, <5,6>, <6,7>, <7,8> }, 0, {2, 8}));

test bool testBreak1() = testCF("testBreak1",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <2,4>, <4,1> }, 0, {1, 3}));
test bool testBreak2() = testCF("testBreak2",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <2,4>, <4,1>, <1,5>, <3,5> }, 0, {5}));
test bool testBreak3() = testCF("testBreak3",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <3,5>, <4,6>, <5,2>, <2,6>, <6,1> }, 0, {1}));
test bool testBreak4() = testCF("testBreak4",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <3,5>, <4,6>, <5,2>, <2,6>, <6,1>, <1,7> }, 0, {7}));

test bool testContinue1() = testCF("testContinue1",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,1>, <2,4>, <4,1> }, 0, {1}));
test bool testContinue2() = testCF("testContinue2",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,1>, <2,4>, <4,1>, <1,5> }, 0, {5}));
test bool testContinue3() = testCF("testContinue3",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,2>, <3,5>, <5,2>, <2,6>, <6,1> }, 0, {1}));
test bool testContinue4() = testCF("testContinue4",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,2>, <3,5>, <5,2>, <2,6>, <6,1>, <1,7> }, 0, {7}));

test bool testCompound1() = testCF("testCompound1",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,2>, <2,4>, <4,8>, <1,5>, <5,6>, <6,7>, <7,5>, <5,8> }, 0, {8}));
test bool testCompound2() = testCF("testCompound2",
	ControlFlow({ <0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,6>, <4,7>, <7,8>, <8,9>, <9,10>, <2,11>,
		<11,12>, <12,13>, <2,14>, <14,15>, <15,16>, <16,17>, <6,18>, <10,18>, <13,18>, <17,18> }, 0, {18}));