module graph::\data::GlobalData

import Prelude;
import analysis::m3::Registry;

import graph::DataStructures;


private map[loc, rel[MethodData, int]] globalLinks = ();

public void addGlobal(MethodData methodData, loc location, int vertex) {
	if(location in globalLinks) {
		globalLinks[location] += { <methodData, vertex> };
	} else {
		globalLinks[location] = { <methodData, vertex> };
	}
}

public map[loc, rel[MethodData, int]] getGlobalLinks() {
	map[loc, rel[MethodData, int]] returnLinks = globalLinks;
	globalLinks = ();
	
	return returnLinks;
}