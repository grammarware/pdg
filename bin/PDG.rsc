module PDG

import lang::java::m3::AST;
import List;
import ADT;
import IO;
import ControlDependence::ControlFlow;

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

//cf = buildFlow(getMethodAST(|project://JavaTest/src/Basic.java|)[0]);
public CF buildFlow(Declaration method){
	str name = method.name;
	return getControlFlow(method.impl);	
}

private bool isClassType(Declaration::\class(_,_,_,_)) = true;
private bool isClassType(Declaration::\class(_)) = true;
private default bool isClassType(Declaration _) = false;

private bool isMethodType(Declaration::\method(_,_,_,_)) = true;
private bool isMethodType(Declaration::\method(_,_,_,_,__)) = true;
private default bool isMethodType(Declaration _) = false;