@contributor{René Bulsing - UvA MSc 2015}
module clone::Main

import Prelude;
import analysis::m3::Registry;
import lang::java::m3::Core;

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
		logMessage("First", "<c.first.methodSpan>", prefix = "    ");
		logMessage("Second", "<c.second.methodSpan>", prefix = "    ");
	}
	
	logInfo("Interprocedural clones:");
	for(c <- clones.interprocedural) {
		logMessage("First", "<c.first.methodSpan>", prefix = "    ");
		logMessage("Second", "<c.second.methodSpan>", prefix = "    ");
	}
	
	logInfo("Non-Interprocedural clones:");
	for(c <- clones.nonInterprocedural) {
		logMessage("First", "<c.first.methodSpan>", prefix = "    ");
		logMessage("Second", "<c.second.methodSpan>", prefix = "    ");
	}
	
	logInfo("Small clones:");
	for(c <- clones.small) {
		logMessage("First", "<c.first.methodSpan>", prefix = "    ");
		logMessage("Second", "<c.second.methodSpan>", prefix = "    ");
	}
	
	logInfo("Not clones:");
	for(c <- clones.not) {
		logMessage("First", "<c.first.methodSpan>", prefix = "    ");
		logMessage("Second", "<c.second.methodSpan>", prefix = "    ");
	}
}

public void findClones(str baseName, str firstProjectName, str secondProjectName) {
	initializeConsoleLogger();
	
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
	
	loc logLocation = |project://pdg/results| + "[<printDateTime(now(), "yyyy-MM-dd_HH.mm.ss")>] - <baseName>";
	mkDirectory(logLocation);
	logClones(logLocation, projects, clones);
	writeConsoleLogToFile(logLocation);
	
	visualizeCloneCandidates(clones.refactored);
}