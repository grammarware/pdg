module graph::\data::GlobalData

import Prelude;

import graph::DataStructures;


private map[MethodData, set[int]] globalLinks = ();

public void addGlobal(MethodData methodData, int vertex) {
	if(methodData in globalLinks) {
		globalLinks[methodData] += { vertex };
	} else {
		globalLinks[methodData] = { vertex };
	}
}

public map[MethodData, set[int]] getGlobalLinks() {
	map[MethodData, set[int]] returnLinks = globalLinks;
	globalLinks = ();
	
	return returnLinks;
}