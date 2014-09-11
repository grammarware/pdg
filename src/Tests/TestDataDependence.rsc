module Tests::TestDataDependence

import lang::java::m3::AST;
import IO;
import PDG;
import ADT;
import ControlDependence::ControlFlow;
import DataDependence::DataDependence;

test bool testInputs(){
	CF cf = getControlFlow(getMethodAST(|project://JavaTest/src/PDG/dataFlow/DataDependence.java|)[0]);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	map[int, set[str]] uses = getUses();
	map[int use, rel[int def, str name] defs] dp = buildDataDependence(cf, statements, defs, gens, uses);
	map[int use, rel[int def, str name] defs] exptectedDP = ();
	exptectedDP[3] = {<0, "n">, <1, "i">, <10, "i">};
	exptectedDP[6] = {<5, "j">, <1, "i">, <8, "j">, <10, "i">};
	exptectedDP[7] = {<4, "sum">, <7, "sum">, <5, "j">, <8, "j">};
	exptectedDP[8] = {<5, "j">, <8, "j">};
	exptectedDP[9] = {<4, "sum">, <7, "sum">, <1, "i">, <10, "i">};
	exptectedDP[10] = {<1, "i">, <10, "i">};
	exptectedDP[11] = {<4, "sum">, <7, "sum">, <2, "sum">, <1, "i">, <10, "i">};
	
	return (dp == exptectedDP);
}