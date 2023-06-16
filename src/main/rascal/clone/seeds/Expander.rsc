@contributor{René Bulsing - UvA MSc 2015}
module clone::seeds::Expander

import Prelude;
import lang::java::m3::Core;
import analysis::m3::AST;
import analysis::m3::Registry;

import clone::flow::Creator;
import clone::DataStructures;
import clone::utility::ConsoleLogger;
import graph::DataStructures;
import graph::factory::GraphFactory;


private int processed = 1;

public SystemDependence getSystemDependence(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	return createSystemDependence(methodLocation, methodAST, projectModel, File());
}

public Candidate expandCandidate(Candidate candidate) {
	logMessage("<processed>", "<candidate.systemDependence.location>", prefix = "    ");
	
	loc seedLocation = candidate.systemDependence.location;
	systemDependence = getSystemDependence(candidate.systemDependence.model, seedLocation);
	
	return Candidate(seedLocation, systemDependence, <{}, {}>, (), {});
}

public CandidatePair expandCandidatePair(CandidatePair pair) {
	Candidate firstCandidate = expandCandidate(pair.first);
	Candidate secondCandidate = expandCandidate(pair.second);
	
	processed += 1;
	
	return <firstCandidate, secondCandidate>;	
}

public CandidatePairs expandSeeds(Projects projects, Seeds seeds) {	
	processed = 1;
	logInfo("Expanding the seeds.");
	
	return { expandCandidatePair(seed) | seed <- seeds };
}