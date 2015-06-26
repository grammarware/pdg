module clone::processing::LogWriter

import Prelude;
import analysis::m3::Registry;

import clone::DataStructures;


public loc getMethodLocation(str methodName, str fileName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(method.file == methodName
			, method.parent.file == fileName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

public loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(method.file == methodName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

public void printMethods(Projects projects, set[str] methods) {
	unregisterProject(projects.first.location);
	unregisterProject(projects.second.location);
	
	registerProject(projects.first.location, projects.first.model);
	for(method <- methods, /<fileName:.*>.java:<methodName:.*>/ := method) {
		try {
			loc methodLocation = getMethodLocation(methodName, fileName, projects.first.model);
			
			println("======= CONTENTS FOR: <methodLocation>");
			for(line <- getMethodLines(methodLocation)) {
				println(line);
			}
		} catch: {
			println("Method <method> not found.");
		}
	}
	unregisterProject(projects.first.location);
}