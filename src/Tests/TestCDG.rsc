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
	//list[Edge] edges = [edge("1", "4", toArrow(ellipse(size(5),fillColor("black"))), label(text("aaa")), gap(5))];
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(dependences);
	list[Figure] nodes = buildNodes(nodes, regionNum) + labelEdges.labelNodes;
	return graph(nodes, labelEdges.edges, hint("layered"), vgap(20), hgap(30));
}

private list[Figure] buildNodes(list[int] nodes, int regionNum){
	list[Figure] nodes = [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- nodes];
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	//Figure stopNode = box(text("Stop"), id("-2"), size(10), fillColor("red"), gap(10));
	//Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	list[Figure] regionNodes = [box(text("R<n*(-1)>"), id("<n>"), size(10), fillColor("green"), gap(10)) | n <- [regionNum..-3]];
	
	//return [entryNode, stopNode, startNode] + nodes + regionNodes;
	return [entryNode] + nodes + regionNodes;
}

private tuple[list[Figure] labelNodes, list[Edge] edges] buildEdges(map[int, rel[int, str]] dependences){
	list[Edge] edges = [];
	list[Figure] labelNodes = [];
	int labelNum = 0;
	for(n <- dependences){
		for(<post, predicate> <- dependences[n] && post != -2 && post != -1){
			if(predicate != ""){
				labelNodes += box(text("<predicate>", fontSize(10)), id("l<labelNum>"), lineColor("white"));
				edges += [edge("<n>", "l<labelNum>", gap(10))];	
				edges += [edge("l<labelNum>", "<post>", toArrow(ellipse(size(5),fillColor("black"))))];
			}else{
				edges += [edge("<n>", "<post>", toArrow(ellipse(size(5),fillColor("black"))))];				
			}
			println("<n> ---- <post>---<predicate>");	
			labelNum = labelNum + 1;	
		}
	}
	return <labelNodes, edges>;
}
