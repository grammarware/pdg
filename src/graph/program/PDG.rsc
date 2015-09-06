@contributor{René Bulsing - UvA MSc 2015}
module graph::program::PDG

import Prelude;

import graph::DataStructures;

public ProgramDependence createPDG(ControlDependence controlDependence, DataDependence dataDependence) {
	return ProgramDependence(controlDependence.graph, dataDependence.graph);
}