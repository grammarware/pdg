module PDG

import lang::java::m3::AST;
import List;
import Set;
import Map;
import ADT;
import IO;
import ControlDependence::ControlFlow;
import ControlDependence::Dominance;
import DataDependence::DataFlow;

public Declaration getAST(loc project){
	//loc project = |project://JavaTest/src/Main.java|;
	return createAstFromFile(project, false, javaVersion = "1.8");
}

public Declaration getClassAST(loc project){
	return  head([cl | cl <- getAST(project).types && isClassType(cl)]);
}


public list[Declaration] getMethodAST(loc project){
	return  [meth | meth <- getClassAST(project).body && isMethodType(meth)];
}

//cf = buildFlow(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Basic.java|)[0]);
public CF buildControlFlow(Declaration method){
	str name = method.name;
	return getControlFlow(method.impl);	
}

//buildPDG(getMethodAST(|project://JavaTest/src/PDG/dataFlow/InOut.java|)[0]);
public void buildPDG(Declaration method){
	CF cf = getControlFlow(method.impl);
	map[int number, Statement stat] statements = getStatements();
	map[str, set[int]] defs = getDefs();
	map[int, set[str]] gens = getGens();
	buildDataFlow(cf, statements, defs, gens);
	
}

//for test
//cf = buildDominatorTree(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Basic.java|)[1]);
public map[int, int] buildDominatorTree(Declaration method){
	CF cf = buildControlFlow(method);
	map[int number, Statement stat] statements = getStatements();
	return buildDominance(cf.cflow, cf.firstStatement, toList(domain(statements)));
}

private bool isClassType(Declaration::\class(_,_,_,_)) = true;
private bool isClassType(Declaration::\class(_)) = true;
private default bool isClassType(Declaration _) = false;

private bool isMethodType(Declaration::\method(_,_,_,_)) = true;
private bool isMethodType(Declaration::\method(_,_,_,_,__)) = true;
private default bool isMethodType(Declaration _) = false;