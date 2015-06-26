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
	processed += 1;
	
	systemDependence = getSystemDependence(candidate.systemDependence.model, candidate.systemDependence.location);
	Flows flows = <createControlFs(systemDependence), createDataFs(systemDependence)>;
	
	return Candidate(systemDependence, flows, (), {});
}

public CandidatePairs expandRange(CandidatePairs candidates) {
	return { <first, expandCandidate(second)> | <first, second> <- candidates };
}

public CandidatePairs expandDomain(CandidatePairs candidates) {
	return { <expandCandidate(first), second> | <first, second> <- candidates };
}

public CandidatePairs expandSeeds(Projects projects, Seeds seeds) {	
	unregisterProject(projects.first.location);
	unregisterProject(projects.second.location);
	
	processed = 1;
	println("[Project 1]: ");
	registerProject(projects.first.location, projects.first.model);
	CandidatePairs candidatePairs = expandDomain(seeds);
	unregisterProject(projects.first.location);
	
	processed = 1;
	println("[Project 2]: ");
	registerProject(projects.second.location, projects.second.model);
	candidatePairs = expandRange(candidatePairs);
	unregisterProject(projects.second.location);
	
	return candidatePairs;
}