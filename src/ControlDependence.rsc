module ControlDependence

import lang::java::m3::AST;
import ListRelation;
import List;
import Set;
import Map;
import IO;
import Types;
import DominatorTree;
import Utils::Traversal;
import Utils::Relation;

private int START = -1;
private int STOP = -2;
//ENTRY is a predict node with one edge labeled "T" going to START and another labeled "F" going to STOP;
private int ENTRY = -3;

public tuple[map[int, rel[int, str]] dependences, int regionNum] buildDependence(CF cf, list[int] nodes){
	flow = addCommonNodestoFlow(cf);
	nodes = nodes + START + STOP + ENTRY;
	map[int, int] postDominance = buildDominance(invert(flow), STOP, nodes);
	map[int, rel[int, str]] dependence = determineDependence(flow, nodes, postDominance);
	map[int, rel[int, str]] cd = getControlDependencePred(dependence);
	return insertRegionNode(cd, postDominance, nodes);
}

private map[int, rel[int, str]] determineDependence(lrel[int, int] flow, list[int] nodes, map[int, int] postDominance){
	map[int, rel[int, str]] dependence= ();
	map[int, list[int]] dominators = getDominators(postDominance, STOP, nodes);
	for(<node1, node2> <- flow, node2 notin dominators[node1]){
		list[int] pathNodes = [];
		//if node1 is the least common node (either node1 or the parent of node1)
		if(node1 in dominators[node2]){
			leastCommonNode = node1;
			pathNodes = getPathNodes(leastCommonNode, dominators[node2]) + leastCommonNode;
		}else{
			leastCommonNode = postDominance[node1];
			pathNodes = getPathNodes(leastCommonNode, dominators[node2]);
		}
		if(node1 in dependence){
			dependence[node1] += {<nod, "F"> | nod <- pathNodes};
		}else{
			dependence[node1] = {<nod, "T"> | nod <- pathNodes};
		}
	}
	
	return dependence;
}

private map[int, rel[int, str]] getControlDependencePred(map[int key, rel[int nod, str label] values] dependence){
	map[int, rel[int, str]] controlDependencePred = ();
	for(key <- dependence.key){
		for(dep <- dependence[key]){
			if(dep.nod notin controlDependencePred){
				controlDependencePred[dep.nod] = {<key, dep.label>};
			}else{
				controlDependencePred[dep.nod] += {<key, dep.label>};
			}
		}
	}
	return controlDependencePred;
}

private tuple[map[int, rel[int, str]] nodesWithRegion, int regionNum] insertRegionNode(map[int key, rel[int pred, str label] values] controlDependencePred, map[int, int] postDominance, list[int] nodes){
	map[rel[int, str], int] regionNodes = ();
	map[int, rel[int, str]] dependenceWithRegion = ();
	//region nodes start at -4
	int regionCounting = -4;
	map[int, list[int]] postDominatorTree = dominatorTree(postDominance, nodes);
	//post-order traverse post-dominator tree
	for(n <- toPostOrder(postDominatorTree, STOP, nodes), n in controlDependencePred){
		rel[int pre, str label] cd = controlDependencePred[n];
		if(cd notin regionNodes){
			regionNodes[cd] = regionCounting;
			regionCounting = regionCounting - 1;
			dependenceWithRegion = concateRegionNode(n, cd, regionNodes[cd], dependenceWithRegion);	
			
			if(n in postDominatorTree){
				for(child <- postDominatorTree[n]){
					if(cd <= controlDependencePred[child]){
						childRegion = regionNodes[controlDependencePred[child]];
						//modify the concatination
						dependenceWithRegion = modifyPredecessors(cd, childRegion, regionNodes[cd], dependenceWithRegion);
						afterReplace = controlDependencePred[child] - cd + <regionNodes[cd], "">;
						regionNodes[afterReplace] = childRegion;
						regionNodes = delete(regionNodes, controlDependencePred[child]);
						cd = afterReplace;
					}	
					if(controlDependencePred[child] < cd){
						childRegion = regionNodes[controlDependencePred[child]];
						dependenceWithRegion = modifyPredecessors(controlDependencePred[child], regionNodes[cd], childRegion, dependenceWithRegion);
						afterReplace = cd - controlDependencePred[child] + <childRegion, "">;
						regionNodes[afterReplace] = regionNodes[cd];
						regionNodes = delete(regionNodes, cd);
						cd = afterReplace;
					}	
				}
			}		
		}else dependenceWithRegion = concateRegionNode(n, cd, regionNodes[cd], dependenceWithRegion);
	}
	
	return filterRegionNode(dependenceWithRegion, regionCounting);
}

private tuple[map[int, rel[int, str]] filteredRegion, int regionNum] filterRegionNode(map[int, rel[int, str]] dwr, int regionCounting){
	for(pre <- dwr){
		nodes = groupByLabel(dwr[pre]);
		if("T" in nodes && size(nodes["T"]) > 1){
			dwr[pre] = dwr[pre] - {<n, "T"> | n <- nodes["T"]};
			regionNode = regionCounting;
			dwr[regionNode] = {};
			regionCounting = regionCounting - 1;
			dwr[pre] += {<regionNode, "T">};
			for(n <- nodes["T"]) dwr[regionNode] += {<n, "">};
		}
		if("F" in nodes && size(nodes["F"]) > 1){
			dwr[pre] = dwr[pre] - {<n, "T"> | n <- nodes["F"]};
			regionNode = regionCounting;
			dwr[regionNode] = {};
			regionCounting = regionCounting - 1;
			dwr[pre] += {<regionNode, "F">};
			for(n <- nodes["T"]) dwr[regionNode] += {<n, "">};
		}
	}
	return <dwr, regionCounting + 1>;
}

private map[int, rel[int, str]] concateRegionNode(int n, rel[int, str] cd, int r, map[int, rel[int, str]] dwr){
	if(r notin dwr) dwr[r] = {<n, "">};
	else dwr[r] += {<n, "">};
	for(<pre, label> <- cd){
		if(pre notin dwr) dwr[pre] = {<r, label>};
		else dwr[pre] += {<r, label>};
	}
	return dwr;
}

private map[int, rel[int, str]] modifyPredecessors(rel[int, str] cd, int r, int rReplaced, map[int, rel[int, str]] dwr){
	for(<pre, label> <- cd){
		dwr[pre] = dwr[pre] - <r, label>;
	}
	dwr[rReplaced] = dwr[rReplaced] + <r, "">;
	return dwr;
}

public lrel[int, int] addCommonNodestoFlow(CF cf){
	return [<ENTRY, START>, <ENTRY, STOP>, <START, cf.firstStatement>] + cf.cflow + [<s, STOP> | s <- cf.lastStatements];
}

//the nodes on the path to LCA (not including LCA)
private list[int] getPathNodes(int leastCommonNode, list[int] dominators){
	int pos = indexOf(dominators, leastCommonNode);
	return dominators[0..pos];
} 