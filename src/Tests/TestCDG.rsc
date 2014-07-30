module Tests::TestCDG

import ADT;
import ControlDependence::ControlDependence;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import IO;
import List;

public void displaceTestCDG(){
	flow = [<1, 2>, <1, 3>, <2, 4>, <2, 5>, <3, 5>, <3, 7>, <4, 6>, <5, 6>, <6, 7>];
	CF cf = controlFlow(flow, 1, [7]);
	nodes = [1..8];
	tuple[map[int, rel[int, str]] dependences, int regionNum] controlDependences = buildDependence(cf, nodes);
	render(buildCDG(controlDependences.dependences, nodes, controlDependences.regionNum));
	//println(buildCDG(dependences, -3));
}

private Figure buildCDG(map[int, rel[int, str]] dependences, list[int] nodes, int regionNum){
	list[Figure] nodes = buildNodes(nodes, regionNum);
	//list[Edge] edges = [edge("1", "4", toArrow(ellipse(size(5),fillColor("black"))), label(text("aaa")), gap(5))];
	list[Edge] edges = buildEdges(dependences)[0..15];
	return graph(nodes, edges, hint("layered"), vgap(20), hgap(40));
}

private list[Figure] buildNodes(list[int] nodes, int regionNum){
	list[Figure] nodes = [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- nodes];
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	Figure stopNode = box(text("Stop"), id("-2"), size(10), fillColor("red"), gap(10));
	Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	list[Figure] regionNodes = [box(text("R<n*(-1)>"), id("<n>"), size(10), fillColor("green"), gap(10)) | n <- [regionNum..-3]];
	
	return [entryNode, stopNode, startNode] + nodes + regionNodes;
}

private list[Edge] buildEdges(map[int, rel[int, str]] dependences){
	list[Edge] edges = [];
	for(n <- dependences){
		for(<post, predicate> <- dependences[n]){
			edges += [edge("<n>", "<post>", toArrow(ellipse(size(5),fillColor("black"))), label(text(predicate)), gap(5))];			
		}
	}
	
	return edges;
}
