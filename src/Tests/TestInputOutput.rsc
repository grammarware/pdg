module Tests::TestInputOutput

import Prelude;
import lang::java::m3::AST;
import IO;
import PDG;
import ADT;
import ControlDependence::ControlFlow;
import DataDependence::DataDependence;

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

