module ControlDependence::Dominance

import List;
import Map;
import lang::java::m3::AST;
import Utils::Traversal;
import Utils::ListRelation;
import ADT;
import IO;

public map[int, list[int]] getDominators(map[int, int] idom, int first, list[int] nodes){
	map[int, list[int]] doms = ();
	for(n <- nodes){
		doms[n] = [n];
		finger = n;
		while(finger != first){
			doms[n] += [idom[finger]];
			finger = idom[finger];
		}
	}
	return doms;
}

//flow = [<6, 5>, <6, 4>, <4, 3>, <4, 2>, <5, 1>, <1, 2>, <2, 1>, <2, 3>, <3, 2>];
//buildDominance(flow, 6, 6);
public map[int, int] buildDominance(lrel[int, int] flow, int first, list[int] nodes){
	map[int, list[int]] predecessor = getPredecessors(flow);
	list[int] postOrder = toPostOrder(toMap(flow), first, nodes);
	map[int, int] idom = ();
	//initialize the dominators array, -1 means undefined
	for(s <- postOrder) 
		idom[s] = -1;
		
	idom[first] = first;
	bool changed = true;
	while(changed){
		changed = false;
		for(b <- reverse(postOrder - first)){
			newIdom = getProcessedPred(idom, b, predecessor);
			if(size(predecessor[b]) > 1){
				for(p <- (predecessor[b] - newIdom), idom[p] != -1)
					newIdom = intersect(p, newIdom, idom, postOrder);
			}
			
			if(idom[b] != newIdom){
				idom[b] = newIdom;
				changed = true;
			}
		}
	}
	return idom;
}

private int intersect(int b1, int b2, map[int, int] idom, list[int] postOrder){
	finger1 = b1;
	finger2 = b2;
	while(finger1 != finger2){
		while(indexOf(postOrder, finger1) < indexOf(postOrder, finger2))
			finger1 = idom[finger1];
		while(indexOf(postOrder, finger1) > indexOf(postOrder, finger2))
			finger2 = idom[finger2];
	}
	return finger1;
}

private int getProcessedPred(map[int, int] idom, int n, map[int, list[int]] predecessor){
	list[int] processed = [];
	for(i <- predecessor[n], idom[i] != -1) 
		processed += i;
	return processed[0];
}