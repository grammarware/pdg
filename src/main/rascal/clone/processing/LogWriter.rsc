@contributor{René Bulsing - UvA MSc 2015}
module clone::processing::LogWriter

import Prelude;
import analysis::m3::Registry;
import lang::java::m3::Core;

import extractors::Project;
import extractors::File;
import clone::DataStructures;


private loc getResolvedMethodLocation(str methodName, str fileName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(method.file == methodName) {
			loc resolvedMethod = resolveLocation(method, projectModel);
			
			if(resolvedMethod.file == fileName) {
				return resolvedMethod;
			}
		}
	}
	
	throw "Method \"<methodName>\" in file \"<fileName>\" does not exist.";
}

private list[str] addHighlights(int startLine, list[str] code, set[int] highlights) {
	highlights = { highlight - startLine | highlight <- highlights };
	
	list[str] alteredCode = [];
	int identifier = 0;
	
	for(codeLine <- code) {
		alteredCode += identifier in highlights ? "+" + codeLine : codeLine;
		identifier += 1;
	}
	
	return alteredCode;
}

private void writeString(loc location, ProjectData project, Candidate candidate) {
	map[str, list[str]] writeString = ();
	
	for(method <- candidate.methodSpan, /<fileName:.*java>:<methodName:.*>/ := method) {
		try {
			loc methodLocation = getResolvedMethodLocation(methodName, fileName, project.model);
			
			list[str] methodCode = getLines(methodLocation);
			set[int] methodHighlights = candidate.highlights[methodLocation(0,0,<0,0>,<0,0>)];
			writeString[fileName] += addHighlights(methodLocation.begin.line, methodCode, methodHighlights);
		} catch error: {
			println(error);
		}
	}
	
	for(file <- writeString) {
		writeFile(location + "/<project.location.authority>-<file>", intercalate("\n", writeString[file]));
	}
}

private void writeClones(loc baseLocation, str directory, Projects projects, CandidatePairs candidates) {
	loc directoryLocation = baseLocation + "<directory>/";
	mkDirectory(directoryLocation);
	
	for(<first, second> <- candidates) {
		loc storageLocation = directoryLocation + first.seed.file;
		mkDirectory(storageLocation);
		
		writeString(storageLocation, projects.first, first);
		writeString(storageLocation, projects.second, second);
	}
}


public void logClones(loc baseLocation, Projects projects, CloneData clones) {
	writeClones(baseLocation, "refactored", projects, clones.refactored);
	writeClones(baseLocation, "interprocedural", projects, clones.interprocedural);
	writeClones(baseLocation, "non-interprocedural", projects, clones.nonInterprocedural);
	writeClones(baseLocation, "small", projects, clones.small);
	writeClones(baseLocation, "not", projects, clones.not);
}