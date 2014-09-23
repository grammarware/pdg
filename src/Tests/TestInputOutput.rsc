module Tests::TestInputOutput

import lang::java::m3::AST;
import IO;
import PDG;
import ADT;
import ControlDependence::ControlFlow;
import DataDependence::ReachingDefs;

test bool testInputs(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	inputs = getReachingDefs(cf, statements, defs, gens).inputs;
	map[int, map[int, set[str]]] exptectedInputs = ();
	exptectedInputs[0] = ();
	exptectedInputs[1] = (0:{"n"});
	exptectedInputs[2] = (1:{"i"},0:{"n"});
	exptectedInputs[3] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[4] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[5] = (10:{"i"},8:{"j"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[6] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[7] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[8] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},1:{"i"},0:{"n"});
	exptectedInputs[9] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[10] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedInputs[11] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	
	return (inputs == exptectedInputs);
}

test bool testOutputs(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/Sum.java|)[0]);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	outputs = getReachingDefs(cf, statements, defs, gens).outputs;
	map[int, map[int, set[str]]] exptectedOutputs = ();
	exptectedOutputs[0] = (0:{"n"});
	exptectedOutputs[1] = (1:{"i"},0:{"n"});
	exptectedOutputs[2] = (2:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[3] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[4] = (10:{"i"},8:{"j"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[5] = (10:{"i"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[6] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[7] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},1:{"i"},0:{"n"});
	exptectedOutputs[8] = (10:{"i"},8:{"j"},7:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[9] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},1:{"i"},0:{"n"});
	exptectedOutputs[10] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},0:{"n"});
	exptectedOutputs[11] = (10:{"i"},8:{"j"},7:{"sum"},5:{"j"},4:{"sum"},2:{"sum"},1:{"i"},0:{"n"});
	return (outputs == exptectedOutputs);
}

