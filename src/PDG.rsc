module PDG

import lang::java::m3::AST;
import List;
import Set;
import Map;
import ADT;
import IO;
import ControlDependence::ControlFlow;
import ControlDependence::Dominance;

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
public CF buildFlow(Declaration method){
	str name = method.name;
	Environment environment = env(());
	return getControlFlow(method.impl, environment);	
}

//cf = buildDominatorTree(getMethodAST(|project://JavaTest/src/PDG/controlFlow/Basic.java|)[1]);
public map[int, int] buildDominatorTree(Declaration method){
	CF cf = buildFlow(method);
	map[int number, Statement stat] statements = getStatements();
	return buildDominance(cf.cflow, cf.firstStatement, toList(domain(statements)));
}

private bool isClassType(Declaration::\class(_,_,_,_)) = true;
private bool isClassType(Declaration::\class(_)) = true;
private default bool isClassType(Declaration _) = false;

private bool isMethodType(Declaration::\method(_,_,_,_)) = true;
private bool isMethodType(Declaration::\method(_,_,_,_,__)) = true;
private default bool isMethodType(Declaration _) = false;