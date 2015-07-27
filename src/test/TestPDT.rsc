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

private M3 projectModel = createM3(|project://JavaTest|);

public bool testPDT(str name, expected)
{	
	input = getOneFrom([method | method <- getM3Methods(projectModel), /<name>\(/ := method.file]);
	output = getMethodPDT(input);
	if(output != expected)
		println("[<name>]: <input> FAILED.
				'\tGot <output>.
				'\tExpected <expected>.");
	return output == expected;
}

private Graph[int] getMethodPDT(loc methodLocation)
{
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	GeneratedData generatedData = createCFG(projectModel, cast(#Declaration, methodAST));
	PostDominator postDominator = createPDT(generatedData.methodData, generatedData.controlFlow);
	return postDominator.tree;
}

test bool testIf1() = testPDT("testIf1", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,2>, <3,1>, <1,0>, <0, STARTNODE> });

test bool testIf1Alternate() = testPDT("testIf1Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,2>, <3,1>, <1,0>, <0, STARTNODE> });

test bool testIf2() = testPDT("testIf2", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <4,2>, <4,1>, <1,0>, <0, STARTNODE> });

test bool testIf2Alternate() = testPDT("testIf2Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <4,2>, <4,1>, <1,0>, <0, STARTNODE> });

test bool testIf3() = testPDT("testIf3", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <5,3>, <5,2>, <5,1>, <1,0>, <0, STARTNODE> });

test bool testIf3Alternate() = testPDT("testIf3Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <5,3>, <5,2>, <5,1>, <1,0>, <0, STARTNODE> });

test bool testIf4() = testPDT("testIf4", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <6,4>, <6,3>, <6,2>, <6,1>, <1,0>, <0, STARTNODE> });

test bool testIf4Alternate() = testPDT("testIf4Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <6,4>, <6,3>, <6,2>, <6,1>, <1,0>, <0, STARTNODE> });

test bool testIf5() = testPDT("testIf5", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 9>, <9,8>, <9,6>, <9,4>, <9,3>, <9,1>, <8,7>, <6,5>, <3,2>, <1,0>, <0, STARTNODE> });

test bool testFor1() = testPDT("testFor1", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testFor1Alternate() = testPDT("testFor1Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testFor2() = testPDT("testFor2", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testFor2Alternate() = testPDT("testFor2Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testWhile1() = testPDT("testWhile1", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testWhile1Alternate() = testPDT("testWhile1Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testWhile2() = testPDT("testWhile2", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testWhile2Alternate() = testPDT("testWhile2Alternate", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <1,0>, <0, STARTNODE> });

test bool testDoWhile1() = testPDT("testDoWhile1", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 1>, <1,2>, <2,0>, <0, STARTNODE> });

test bool testDoWhile2() = testPDT("testDoWhile2", 
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <3,1>, <1,2>, <2,0>, <0, STARTNODE> });

test bool testReturn1() = testPDT("testReturn1",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testReturn1Alternate() = testPDT("testReturn1Alternate",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testReturn2() = testPDT("testReturn2",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testReturn2Alternate() = testPDT("testReturn2Alternate",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testSwitch1() = testPDT("testSwitch1",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE,7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <6,1>, <1,0>, <0,STARTNODE> });

test bool testSwitch2() = testPDT("testSwitch2",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE,8>, <8,7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <6,1>, <1,0>, <0,STARTNODE> });

test bool testSwitch3() = testPDT("testSwitch3",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE,10>, <10,9>, <9,8>, <EXITNODE,7>, <7,6>, <6,5>, <EXITNODE,4>, <4,3>, <3,2>,
	<EXITNODE,1>, <1,0>, <0,STARTNODE> });

test bool testSwitch4() = testPDT("testSwitch4",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE,11>, <11,10>, <11,7>, <11,4>, <11,1>, <10,9>, <9,8>, <7,6>, <6,5>, <4,3>,
	<3,2>, <1,0>, <0,STARTNODE> });

test bool testSwitch5() = testPDT("testSwitch5",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE,9>, <9,8>, <8,7>, <7,6>, <6,5>, <4,3>, <3,2>, <1,0>, <EXITNODE,4>,
	<EXITNODE,1>,<0,STARTNODE> });

test bool testSwitch6() = testPDT("testSwitch6",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE,10>, <10,9>, <9,8>, <8,7>, <7,6>, <6,5>, <4,3>, <3,2>, <1,0>, <10,4>,
	<10,1>, <0,STARTNODE> });

test bool testSwitch7() = testPDT("testSwitch7",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <EXITNODE,1>, <1,0>, <0,STARTNODE> });

test bool testSwitch8() = testPDT("testSwitch8",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <5,4>, <4,3>, <3,2>, <8,1>, <1,0>, <0,STARTNODE> });

test bool testTry1() = testPDT("testTry1",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <EXITNODE, 2>, <2,1>, <1,0>, <0,STARTNODE> });

test bool testTry2() = testPDT("testTry2",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> });

test bool testTry3() = testPDT("testTry3",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> });

test bool testTry4() = testPDT("testTry4",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> });

test bool testTry5() = testPDT("testTry5",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <7,4>, <4,3>, <7,2>, <2,1>, <1,0>, <0,STARTNODE> });

test bool testTry6() = testPDT("testTry6",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <7,4>, <4,3>, <7,2>, <2,1>, <1,0>, <0,STARTNODE> });

test bool testThrow1() = testPDT("testThrow1",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testThrow1Alternate() = testPDT("testThrow1Alternate",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testThrow2() = testPDT("testThrow2",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testThrow2Alternate() = testPDT("testThrow2Alternate",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testThrow3() = testPDT("testThrow3",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <7,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testThrow4() = testPDT("testThrow4",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <EXITNODE, 7>, <7,6>, <6,5>, <EXITNODE, 4>, <4,3>, <EXITNODE,2>,
	<EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testThrow5() = testPDT("testThrow5",
	{ <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <6,4>, <4,3>, <EXITNODE,2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> });

test bool testBreak1() = testPDT("testBreak1",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE, 1>, <1,4>, <1,0>, <0,STARTNODE>, <EXITNODE, 3>, <EXITNODE, 2> });

test bool testBreak2() = testPDT("testBreak2",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE, 5>, <5,3>, <5,2>, <5,1>, <1,4>, <1,0>, <0, STARTNODE> });

test bool testBreak3() = testPDT("testBreak3",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE, 1>, <6,2>, <6,3>, <6,4>, <2,5>, <1,6>, <1,0>, <0, STARTNODE> });

test bool testBreak4() = testPDT("testBreak4",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE, 7>, <7,1>, <6,2>, <6,3>, <6,4>, <2,5>, <1,6>, <1,0>, <0, STARTNODE> });

test bool testContinue1() = testPDT("testContinue1",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE,1>, <1,4>, <1,3>, <1,2>, <1,0>, <0,STARTNODE> });

test bool testContinue2() = testPDT("testContinue2",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE,5>, <5,1>, <1,4>, <1,3>, <1,2>, <1,0>, <0,STARTNODE> });

test bool testContinue3() = testPDT("testContinue3",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE,1>, <2,5>, <2,4>, <2,3>, <6,2>, <1,6>, <1,0>, <0,STARTNODE> });

test bool testContinue4() = testPDT("testContinue4",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE,7>, <7,1>, <6,2>, <2,5>, <2,4>, <2,3>, <1,6>, <1,0>, <0,STARTNODE> });

test bool testCompound1() = testPDT("testCompound1",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE,8>, <8,5>, <8,4>, <8,1>, <7,6>, <5,7>, <4,2>, <2,3>, <1,0>, <0,STARTNODE> });

test bool testCompound2() = testPDT("testCompound2",
	{ <EXITNODE,ENTRYNODE>, <EXITNODE,18>, <18,17>, <17,16>, <16,15>, <15,14>, <18,13>, <13,12>, <12,11>, <18,10>,
	<10,9>, <9,8>, <8,7>, <18,6>, <6,5>, <18,4>, <4,3>, <18,2>, <1,0>, <2,1>, <0,STARTNODE> });
