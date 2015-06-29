module clone::Main

import Prelude;
import analysis::m3::Registry;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::call::CallGraph;
import graph::DataStructures;
import extractors::Project;
import clone::DataStructures;
import clone::seeds::Expander;
import clone::seeds::Seeder;
import clone::flow::Creator;
import clone::flow::Matcher;
import clone::detection::Categorizer;
import clone::utility::ConsoleLogger;
import clone::processing::Visualizer;
import clone::processing::LogWriter;


private void clonesToConsole(CloneData clones) {
	logInfo("Refactored clones:");
	for(c <- clones.refactored) {
		println("\t[First]: <c.first.methodSpan>");
		println("\t[Second]: <c.second.methodSpan>");
	}
	
	logInfo("Interprocedural clones:");
	for(c <- clones.interprocedural) {
		println("\t[First]: <c.first.methodSpan>");
		println("\t[Second]: <c.second.methodSpan>");
	}
	
	logInfo("Non-Interprocedural clones:");
	for(c <- clones.nonInterprocedural) {
		println("\t[First]: <c.first.methodSpan>");
		println("\t[Second]: <c.second.methodSpan>");
	}
	
	logInfo("Small clones:");
	for(c <- clones.small) {
		println("\t[First]: <c.first.methodSpan>");
		println("\t[Second]: <c.second.methodSpan>");
	}
	
	logInfo("Not clones:");
	for(c <- clones.not) {
		println("\t[First]: <c.first.methodSpan>");
		println("\t[Second]: <c.second.methodSpan>");
	}
}

public void findClones(str baseName, str firstProjectName, str secondProjectName) {
	loc projectLocation = createProjectLoc(firstProjectName);
	ProjectData firstProject = ProjectData(projectLocation, createM3(projectLocation));
	
	projectLocation = createProjectLoc(secondProjectName);
	ProjectData secondProject = ProjectData(projectLocation, createM3(projectLocation));
	
	Projects projects = <firstProject, secondProject>;
	logInfo("Got M3 models.");
	
	datetime before = now();
	
	Seeds seeds = generateSeeds(projects);
	logInfo("Got the seeds.");
	logInfo("To be processed: <size(seeds)>.");

	CandidatePairs candidates = expandSeeds(projects, seeds);
	logInfo("Expanded the seeds.");
	
	candidates = findMatches(candidates);
	logInfo("Found matches.");
	
	Duration after = createDuration(before, now());
	logInfo("Time: <after.hours> hour(s), <after.minutes> minute(s), <after.seconds> second(s)");
	
	CloneData clones = categorizeClones(candidates);
	clonesToConsole(clones);
	
	loc logLocation = |project://pdg-master/results| + "[<printDateTime(now(), "yyyy-MM-dd_HH.mm.ss")>] - <baseName>";
	mkDirectory(logLocation);
	logClones(logLocation, projects, clones);
	
	visualizeCloneCandidates(clones.refactored);
}