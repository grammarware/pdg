module screen::ControlFlowScreen

import IO;
import lang::java::jdt::m3::Core;

import extractors::Project;
import graph::control::Flow;

@doc {
	To run a test:
		displayControlFlowGraph(|project://pdg-JavaTest/src/PDG|, "testBreak1");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3(project);
	loc methodLocation = getMethodLocation(methodName, projectModel);
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	
	createControlFlowGraph(methodAST);
}

private loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	return |file://methodDoesNotExist|;
}