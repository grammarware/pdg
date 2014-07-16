module Tests::TestControlFlow
import PDG;
import ADT;
import ListRelation;

test bool testBasicCF(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[0]);
	return cf.cflow == [<0, 1>, <1, 2>, <2, 3>];
}

test bool testBasicLast(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[0]);
	return cf.lastStatements == [3];
}

test bool testIfCF(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[1]);
	return cf.cflow ==   [
							<0,1>,
							<1,2>,
							<2,3>,
							<1,4>,
							<4,5>,
							<4,6>,
							<3,7>,
							<5,7>,
							<6,7>];
}

test bool testIfLast(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[2]);
	return cf.lastStatements == [3, 5, 6];
}

test bool testForCF(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[3]);
	return cf.cflow == [
					    <0,1>,
					    <1,2>,
					    <2,3>,
					    <3,4>,
					    <4,2>,
					    <2,5>];
}

test bool testForLast(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[4]);
	return cf.lastStatements == [2];
}

test bool testWhileCF(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[5]);
	return cf.cflow == [
					    <0,1>,
					    <1,2>,
					    <2,3>,
					    <3,1>,
					    <1,4>];
}

test bool testWhileLast(){
	CF cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[6]);
	return cf.lastStatements == [1];
}
