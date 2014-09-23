module Tests::TestUse

import lang::java::m3::AST;
import IO;
import PDG;
import ADT;
import ControlDependence::ControlFlow;

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