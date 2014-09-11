module Tests::TestControlFlow
import ControlDependence::ControlFlow;
import PDG;
import ADT;
import ListRelation;
import Utils::ListRelation;
import Utils::List;

test bool testBasicCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Basic.java|)[0]);
	lrel[int, int] expectedFlow = [<0, 1>, <1, 2>, <2, 3>];
	return equals(cf.cflow, expectedFlow);
}

test bool testBasicLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Basic.java|)[0]);
	list[int] expectedLast = [3];
	return equals(cf.lastStatements, expectedLast);
}

test bool testIfCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/If.java|)[0]);
	lrel[int, int] expectedFlow = [<0,1>,
								<1,2>,
								<2,3>,
								<1,4>,
								<4,5>,
								<4,6>,
								<3,7>,
								<5,7>,
								<6,7>];
	return equals(cf.cflow, expectedFlow);
}

test bool testIfLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/If.java|)[1]);
	list[int] expectedLast = [3, 5, 6];
	return equals(cf.lastStatements, expectedLast);
}

test bool testForCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/For.java|)[0]);
	lrel[int, int] expectedFlow = [<0,1>,
								<1,2>,
								<2,3>,
								<3,4>,
								<4,2>,
								<2,5>];
	return equals(cf.cflow, expectedFlow);
}

test bool testForLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/For.java|)[1]);
	list[int] expectedLast = [2];
	return equals(cf.lastStatements, expectedLast);
}

test bool testWhileCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/While.java|)[0]);
	lrel[int, int] expectedFlow = [<0,1>,
					    			<1,2>,
					    			<2,3>,
					    			<3,1>,
					    			<1,4>];
	return equals(cf.cflow, expectedFlow);
}

test bool testWhileLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/While.java|)[1]);
	list[int] expectedLast = [1];
	return equals(cf.lastStatements, expectedLast);
}

test bool testSwitchCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Switch.java|)[2]);
	lrel[int, int] expectedFlow =  [<0,1>,
								 <1,2>,
							     <1,3>,
							     <1,4>,
					 	         <3,4>,
							     <1,5>];
	return equals(cf.cflow, expectedFlow);
}

test bool testSwitchLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Switch.java|)[2]);
	list[int] expectedLast = [2, 4, 5];
	return equals(cf.lastStatements, expectedLast);
}

test bool testReturnCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Return.java|)[0]);
	lrel[int, int] expectedFlow = [<0,1>, <1,2>, <1,3>];
	return equals(cf.cflow, expectedFlow);
}

test bool testReturnLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Return.java|)[0]);
	list[int] expectedLast = [2,3];
	return equals(cf.lastStatements, expectedLast);
}

test bool testReturnCF2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Return.java|)[1]);
	lrel[int, int] expectedFlow = [<0,1>,
								    <1,2>,
								    <2,3>,
								    <2,4>,
								    <4,5>,
								    <5,6>,
								    <6,7>,
								    <4,7>,
								    <7,8>,
								    <8,1>];
	return equals(cf.cflow, expectedFlow);
}

test bool testReturnLast2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Return.java|)[1]);
	list[int] expectedLast = [1, 3];
	return equals(cf.lastStatements, expectedLast);
}

test bool testBreakCF1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[0]);
	lrel[int, int] expectedFlow = [<0,1>, <1,2>, <1,6>, <2,3>,
								    <2,4>, <3,6>, <4,5>, <5,1>];
	return equals(cf.cflow, expectedFlow);
}

test bool testBreakLast1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[0]);
	list[int] expectedLast = [6];
	return equals(cf.lastStatements, expectedLast);
}
 
test bool testContinueCF1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[1]);
	lrel[int, int] expectedFlow = [<0,1>, <1,2>, <1,6>, <2,3>,
								    <2,4>, <3,5>, <4,5>, <5,1>];
	return equals(cf.cflow, expectedFlow);
}

test bool testContinueLast1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[1]);
	list[int] expectedLast = [6];
	return equals(cf.lastStatements, expectedLast);
}

test bool testBreakContinueCF1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[2]);
	lrel[int, int] expectedFlow = [<0,1>,
								    <1,2>,
								    <1,6>,
								    <2,3>,
								    <2,4>,
								    <3,1>,
								    <4,5>,
								    <4,6>,
								    <5,1>];
	return equals(cf.cflow, expectedFlow);
}

test bool testBreakContinueLast1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[2]);
	list[int] expectedLast = [6];
	return equals(cf.lastStatements, expectedLast);
}

test bool testBreakContinueCF2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[3]);
	lrel[int, int] expectedFlow = [<0,1>,
								    <1,2>,
								    <2,3>,
								    <3,4>,
								    <3,6>,
								    <4,5>,
								    <4,6>,
								    <5,3>,
								    <6,7>,
								    <6,8>,
								    <7,10>,
								    <8,9>,
								    <9,10>,
								    <10,1>];
	return equals(cf.cflow, expectedFlow);
}

test bool testBreakContinueLast2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/BreakContinue.java|)[3]);
	list[int] expectedLast = [1, 8];
	return equals(cf.lastStatements, expectedLast);
}

test bool testComStatCF(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/ComStatements.java|)[0]);
	lrel[int, int] expectedFlow = [<0,1>, <1,2>, <2,3>, <3,4>, <4,5>, <5,3>,
					    			<3,6>, <1,7>, <7,8>, <8,9>, <9,7>, <6,10>, <7,10>];
	return equals(cf.cflow, expectedFlow);
}

test bool testComStatLast(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/ComStatements.java|)[0]);
	list[int] expectedLast = [10];
	return equals(cf.lastStatements, expectedLast);
}

test bool testComStatCF2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/ComStatements.java|)[1]);
	lrel[int, int] expectedFlow = [<0,1>, <1,2>, <2,3>, <2,7>, <3,4>,
    								<3,5>, <5,6>, <2,8>, <8,9>];
	return equals(cf.cflow, expectedFlow);
}

test bool testComStatLast2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/ComStatements.java|)[1]);
	list[int] expectedLast = [4,6,7,9];
	return equals(cf.lastStatements, expectedLast);
}