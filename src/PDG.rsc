module PDG

import lang::java::m3::AST;
import List;
import Set;
import Map;
import ADT;
import IO;
import ControlDependence::ControlFlow;
import ControlDependence::ControlDependence;
import ControlDependence::Dominance;
import DataDependence::DataDependence;

//buildPDG(getMethodAST(|project://JavaTest/src/PDG/dataFlow/DataDependence.java|)[0]);
public tuple[ControlDependence, DataDependence, map[int, Statement]] buildPDG(Declaration method){
	CF cf = getControlFlow(method);
	map[int number, Statement stat] statements = getStatements();
	//control dependence
	list[int] nodes = toList(domain(statements));
	tuple[map[int, rel[int, str]] dependences, int regionNum] controlDependences = buildDependence(cf, nodes);
	
	//data dependence
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	map[int, set[str]] uses = getUses();
	map[int use, rel[int def, str name] defs] dataDependences = buildDataDependence(cf, statements, defs, gens, uses);	
	
	return <CD(controlDependences.dependences, controlDependences.regionNum), DD(dataDependences), statements>;
}

public list[Declaration] getMethodAST(loc project){
	return  [meth | meth <- getClassAST(project).body && isMethodType(meth)];
}

public Declaration getAST(loc project){
	//loc project = |project://JavaTest/src/Main.java|;
	return createAstFromFile(project, false, javaVersion = "1.8");
}

public Declaration getClassAST(loc project){
	return  head([cl | cl <- getAST(project).types && isClassType(cl)]);
}

//
////for test
////cf = buildDominatorTree(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Basic.java|)[1]);
//public map[int, int] buildDominatorTree(Declaration method){
//	CF cf = buildControlFlow(method);
//	map[int number, Statement stat] statements = getStatements();
//	return buildDominance(cf.cflow, cf.firstStatement, toList(domain(statements)));
//}

private bool isClassType(Declaration::\class(_,_,_,_)) = true;
private bool isClassType(Declaration::\class(_)) = true;
private default bool isClassType(Declaration _) = false;

private bool isMethodType(Declaration::\method(_,_,_,_)) = true;
private bool isMethodType(Declaration::\method(_,_,_,_,_)) = true;
private default bool isMethodType(Declaration _) = false;