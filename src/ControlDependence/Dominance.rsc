module ControlDependence::Dominance

import List;
import Map;
import lang::java::m3::AST;
import Utils::Traversal;
import Utils::ListRelation;
import ADT;
import IO;

//flow = [<6, 5>, <6, 4>, <4, 3>, <4, 2>, <5, 1>, <1, 2>, <2, 1>, <2, 3>, <3, 2>];
//getDominator(flow, 6, 6);
public map[int, int] buildDominance(lrel[int, int] flow, int first, int totalAmount){
	map[int, list[int]] predecessor = getPredecessors(flow);
	list[int] postOrder = toPostOrder(toMap(flow), first, totalAmount);
	map[int, int] doms = ();
	//initialize the dominators array, -1 means undefined
	for(s <- postOrder) 
		doms[s] = -1;
		
	doms[first] = first;
	bool changed = true;
	while(changed){
		changed = false;
		for(b <- reverse(postOrder - first)){
			newIdom = getProcessedPred(doms, b, predecessor);
			if(size(predecessor[b]) > 1){
				for(p <- (predecessor[b] - newIdom), doms[p] != -1)
					newIdom = intersect(p, newIdom, doms, postOrder);
			}
			
			if(doms[b] != newIdom){
				doms[b] = newIdom;
				changed = true;
			}
		}
	}
	return doms;
}

private int intersect(int b1, int b2, map[int, int] doms, list[int] postOrder){
	finger1 = b1;
	finger2 = b2;
	while(finger1 != finger2){
		while(indexOf(postOrder, finger1) < indexOf(postOrder, finger2))
			finger1 = doms[finger1];
		while(indexOf(postOrder, finger1) > indexOf(postOrder, finger2))
			finger2 = doms[finger2];
	}
	return finger1;
}

private int getProcessedPred(map[int, int] doms, int n, map[int, list[int]] predecessor){
	list[int] processed = [];
	for(i <- predecessor[n], doms[i] != -1) 
		processed += i;
	return processed[0];
}