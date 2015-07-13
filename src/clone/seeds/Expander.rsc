module clone::seeds::Expander

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import analysis::m3::AST;
import analysis::m3::Registry;

import clone::flow::Creator;
import clone::DataStructures;
import graph::DataStructures;
import graph::factory::GraphFactory;


private int processed = 1;

public SystemDependence getSystemDependence(M3 projectModel, loc methodLocation) {
	node methodAST = getMethodASTEclipse(methodLocation, model = projectModel);
	return createSystemDependence(methodLocation, methodAST, projectModel, File());
}

public Candidate expandCandidate(Candidate candidate) {
	println("  [<processed>]: <candidate.systemDependence.location>.");
	
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
	println("[Expanding]: ");
	
	return { expandCandidatePair(seed) | seed <- seeds };
}