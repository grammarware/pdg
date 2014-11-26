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

public map[int, list[int]] dominatorTree(map[int, int] idom, list[int] nodes){
	map[int, list[int]] dominatorTree = ();
	for(n <- nodes){
		//idom[firstNode] = firstNode, so delete self-loop
		if(idom[n] != n){
			if(idom[n] notin dominatorTree) dominatorTree[idom[n]] = [n];
			else dominatorTree[idom[n]] += [n];
		}
	}
	return dominatorTree;
}

//flow = [<6, 5>, <6, 4>, <4, 3>, <4, 2>, <5, 1>, <1, 2>, <2, 1>, <2, 3>, <3, 2>];
//buildDominance(flow, 6, 6);
public map[int, int] buildDominance(lrel[int, int] flow, int first, list[int] nodes){
	map[int, list[int]] predecessor = getPredecessors(flow);
	list[int] postOrder = toPostOrder(Utils::ListRelation::toMap(flow), first, nodes);
	//initialize the dominators array, -5 means undefined
	map[int, int] idom = (s:-5 | s <- postOrder);
		
	idom[first] = first;
	bool changed = true;
	while(changed){
		changed = false;
		for(b <- reverse(postOrder - first)){
			newIdom = getProcessedPred(idom, b, predecessor);
			if(size(predecessor[b]) > 1){
				for(p <- (predecessor[b] - newIdom), idom[p] != -5)
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

private int getProcessedPred(map[int, int] idom, int n, map[int, list[int]] predecessor) = [i | i <- predecessor[n], idom[i] != -5][0];
