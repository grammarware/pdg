module Tests

import Types;
import ControlDependence;
import ControlFlow;
import DominatorTree;
import DataDependence;
import IO;
import List;
import ListRelation;
import Map;
import PDG;
import Prelude;
import Set;
import Utils::List;
import Utils::ListRelation;
import lang::java::m3::AST;
import vis::Figure;
import vis::KeySym;
import vis::Render;

public void displaceTestCDG(){
	flow = [<1, 2>, <1, 3>, <2, 4>, <2, 5>, <3, 5>, <3, 7>, <4, 6>, <5, 6>, <6, 7>];
	CF cf = controlFlow(flow, 1, [7]);
	nodes = [1..8];
	tuple[map[int, rel[int, str]] dependences, int regionNum] controlDependences = buildDependence(cf, nodes);
	render(buildCDG(controlDependences.dependences, nodes, controlDependences.regionNum));
}

private Figure buildCDG(map[int, rel[int, str]] dependences, list[int] nodes, int regionNum){
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(dependences);
	list[Figure] nodes = buildNodes(nodes, regionNum) + labelEdges.labelNodes;
	return graph(nodes, labelEdges.edges, hint("layered"), vgap(20), hgap(30));
}

private list[Figure] buildNodes(list[int] nodes, int regionNum){
	list[Figure] nodes = [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- nodes];
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	list[Figure] regionNodes = [box(text("R<(n*(-1))-4>"), id("<n>"), size(10), fillColor("green"), gap(10)) | n <- [regionNum..-3]];
	
	return [entryNode] + nodes + regionNodes;
}

private tuple[list[Figure] labelNodes, list[Edge] edges] buildEdges(map[int, rel[int, str]] dependences){
	list[Edge] edges = [];
	list[Figure] labelNodes = [];
	int labelNum = 0;
	for(n <- dependences){
		for(<post, predicate> <- dependences[n] && post != -2 && post != -1){
			if(predicate != ""){
				labelNodes += box(text("<predicate>", fontSize(10)), id("l<labelNum>"), lineColor("white"));
				edges += [edge("<n>", "l<labelNum>", gap(10))];	
				edges += [edge("l<labelNum>", "<post>", toArrow(ellipse(size(5),fillColor("black"))))];
			}else{
				edges += [edge("<n>", "<post>", toArrow(ellipse(size(5),fillColor("black"))))];				
			}
			labelNum = labelNum + 1;	
		}
	}
	return <labelNodes, edges>;
}

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

test bool testDD(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	map[int, set[str]] uses = getUses();
	map[int use, rel[int def, str name] defs] dp = buildDataDependence(cf, statements, defs, gens, uses);
	map[int use, rel[int def, str name] defs] expectedDP = ();
	expectedDP[3] = {<0, "n">, <1, "i">, <10, "i">};
	expectedDP[6] = {<5, "j">, <1, "i">, <8, "j">, <10, "i">};
	expectedDP[7] = {<4, "sum">, <7, "sum">, <5, "j">, <8, "j">};
	expectedDP[8] = {<5, "j">, <8, "j">};
	expectedDP[9] = {<4, "sum">, <7, "sum">, <1, "i">, <10, "i">};
	expectedDP[10] = {<1, "i">, <10, "i">};
	expectedDP[11] = {<4, "sum">, <7, "sum">, <2, "sum">, <1, "i">, <10, "i">};
	
	return (dp == expectedDP);
}

test bool testDominance1(){
	flow = [<0, 1>, <1, 2>, <0, 2>, <2, 3>, <1, 3>, <1, 5>, <3, 4>, 
			<5, 6>, <4, 6>, <6, 5>, <0, 7>, <7, 8>, <7, 9>, <8, 10>, 
			<9, 10>, <9, 11>, <11 ,10>, <10, 12>, <12, 10>, <6, 12>, <12, 0>];
	doms = buildDominance(flow, 0, [0..14]);
	return (doms[0] == 0) && (doms[1] == 0) && (doms[2] == 0) &&
			(doms[3] == 0) && (doms[4] == 3) && (doms[5] == 0) &&
			(doms[6] == 0) && (doms[7] == 0) && (doms[8] == 7) &&
			(doms[9] == 7) && (doms[10] == 0) && (doms[11] == 9) && (doms[12] == 0);
}

test bool testDominance2(){
	flow = [<5, 4>, <5, 3>, <4, 1>, <3, 2>, <1, 2>, <2, 1>];
	doms = buildDominance(flow, 5, [0..6]);
	return (doms[5] == 5) && (doms[4] == 5) && (doms[3] == 5) && (doms[2] == 5) && (doms[1] == 5);
}

test bool testDominance3(){
	flow = [<6, 5>, <6, 4>, <4, 3>, <4, 2>, <5, 1>, <1, 2>, <2, 1>, <2, 3>, <3, 2>];
	doms = buildDominance(flow, 6, [0..7]);
	return (doms[6] == 6) && (doms[5] == 6) && (doms[4] == 6) && (doms[3] == 6) && (doms[2] == 6) && (doms[1] == 6);
}

test bool testSumDominance(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	statements = getStatements();
	list[int] nodes = toList(domain(statements));
	doms = buildDominance(cf.cflow, cf.firstStatement, nodes);
	return (doms[11] == 3) && (doms[10] == 9) && (doms[9] == 6) && (doms[8] == 7) && (doms[7] == 6) && (doms[1] == 0)
			&& (doms[6] == 5) && (doms[5] == 4) && (doms[4] == 3) && (doms[3] == 2) && (doms[2] == 1) && (doms[0] == 0);
}

test bool testGen(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	map[int, set[str]] gens = getGens();
	map[int, set[str]] expectedGens = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	return (gens == expectedGens);
}

test bool testInputs(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	inputs = getReachingDefs(cf, statements, defs, gens).inputs;
	map[int, map[int, set[str]]] expectedInputs = ();
	expectedInputs[0] = ();
	expectedInputs[1] = (0:{"n"});
	expectedInputs[2] = (1:{"i"},0:{"n"});
	expectedInputs[3] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[4] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[5] = (10:{"i"},8:{"j"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[6] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[7] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[8] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},1:{"i"},0:{"n"});
	expectedInputs[9] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[10] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	expectedInputs[11] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	
	return (inputs == expectedInputs);
}

test bool testOutputs(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	outputs = getReachingDefs(cf, statements, defs, gens).outputs;
	outputs = (k1:(k2:outputs[k1][k2] | k2 <- outputs[k1], !isEmpty(outputs[k1][k2])) | k1 <- outputs);
	map[int, map[int, set[str]]] expectedOutputs = (
		0: (0:{"n"}),
		1: (1:{"i"},0:{"n"}),
		2: (2:{"sum"},1:{"i"},0:{"n"}),
		3: (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"}),
		4: (10:{"i"},8:{"j"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"}),
		5: (10:{"i"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"}),
		6: (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"}),
		7: (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},1:{"i"},0:{"n"}),
		8: (10:{"i"},8:{"j"},7:{"sum"},1:{"i"},0:{"n"}),
		9: (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"}),
		10: (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},0:{"n"}),
		11: (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"})
	);
	
	return (outputs == expectedOutputs);
}

test bool testUse1(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/dataFlow/Use.java|)[0]);
	map[int, set[str]] uses = getUses();
	map[int, set[str]] expectedUses = (1:{"i"}, 3:{"m", "j"}, 4:{"m", "i", "j"}, 5:{"m"});
	return (uses == expectedUses);
}

test bool testUse2(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/dataFlow/Use.java|)[1]);
	map[int, set[str]] uses = getUses();
	map[int, set[str]] expectedUses = (2:{"i", "j"}, 3:{"i", "j"}, 4:{"i"}, 5:{"i", "j"});
	return (uses == expectedUses);
}