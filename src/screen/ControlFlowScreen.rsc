module screen::ControlFlowScreen

import IO;
import lang::java::jdt::m3::Core;

@doc {
	To run a test:
		displayControlFlowGraph(|project://pdg-JavaTest/src/PDG|, "testBreak1");
}
public void displayControlFlowGraph(loc project, str methodName) {
	M3 projectModel = createM3FromEclipseProject(project);
	for(method <- methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			println(method);
			println(getMethodASTEclipse(method, model = projectModel));
		}
	}
}