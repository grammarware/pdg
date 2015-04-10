module Utils::Relation

import List;
import Relation;
import Set;
import IO;

public map[str label, set[int] nod] groupByLabel(rel[int, str] rs){
	map[str, set[int]] labelMap = ();
	for(<n, label> <- rs && label != ""){
		if(label notin labelMap) labelMap[label] = {n};
		else labelMap[label] += {n};
	}
	return labelMap;
}