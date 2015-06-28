module clone::processing::LogWriter

import Prelude;
import analysis::m3::Registry;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import extractors::Project;
import extractors::File;
import clone::DataStructures;


private loc getMethodLocation(str methodName, str fileName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(method.file == methodName
			&& method.parent.file == fileName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

private void writeString(loc location, ProjectData project, set[str] methodSpan) {
	map[str, list[str]] writeString = ();
	
	for(method <- methodSpan, /<fileName:.*>.java:<methodName:.*>/ := method) {
		try {
			loc methodLocation = getMethodLocation(methodName, fileName, project.model);
			methodLocation = resolveLocation(methodLocation, project.model);
			
			writeString[fileName] += getLines(methodLocation);
		} catch error: {
			println(error);
		}
	}
	
	for(file <- writeString) {
		writeFile(location + "/<project.location.authority>-<file>.java", intercalate("\n", writeString[file]));
	}
}

private void writeClones(loc baseLocation, str directory, Projects projects, CandidatePairs candidates) {
	loc directoryLocation = baseLocation + "<directory>/";
	mkDirectory(directoryLocation);
	
	for(<first, second> <- candidates) {
		loc storageLocation = directoryLocation + first.seed.file;
		mkDirectory(storageLocation);
		
		writeString(storageLocation, projects.first, first.methodSpan);
		writeString(storageLocation, projects.second, second.methodSpan);
	}
}


public void logClones(loc baseLocation, Projects projects, CloneData clones) {
	writeClones(baseLocation, "refactored", projects, clones.refactored);
	writeClones(baseLocation, "interprocedural", projects, clones.interprocedural);
	writeClones(baseLocation, "non-interprocedural", projects, clones.nonInterprocedural);
	writeClones(baseLocation, "small", projects, clones.small);
	writeClones(baseLocation, "not", projects, clones.not);
}