module Visualization::CDGvis

import ADT;
import PDG;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import IO;
import List;
import Map;
import Set;

//displayCDG(|project://JavaTest/src/PDG/dataFlow/DataDependence.java|);
public void displayCDG(loc project){
	meth = getMethodAST(project)[0];
	tuple[ControlDependence cd, DataDependence dd, map[int, Statement] statements] pd = buildPDG(meth);
	list[int] nodes = toList(domain(pd.statements));
	render(buildCDG(pd.cd.dependences, nodes, pd.cd.regionNum));
}

private Figure buildCDG(map[int, rel[int, str]] cd, list[int] nodes, int regionNum){
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(cd);
	list[Figure] nodes = buildNodes(nodes, regionNum) + labelEdges.labelNodes;
	return graph(nodes, labelEdges.edges, hint("layered"), vgap(40), hgap(40));
}

private list[Figure] buildNodes(list[int] nodes, int regionNum){
	list[Figure] nodes = [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- nodes];
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	//Figure stopNode = box(text("Stop"), id("-2"), size(10), fillColor("red"), gap(10));
	//Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	list[Figure] regionNodes = [box(text("R<(n*(-1))-4>"), id("<n>"), size(10), fillColor("green"), gap(10)) | n <- [regionNum..-3]];

	return nodes + regionNodes + entryNode;
}

private tuple[list[Figure] labelNodes, list[Edge] edges] buildEdges(map[int, rel[int, str]] cd){
	list[Edge] edges = [];
	list[Figure] labelNodes = [];
	int labelNum = 0;
	for(n <- cd){
		for(<post, predicate> <- cd[n] && post != -2 && post != -1){
			if(predicate != ""){
				labelNodes += box(text("<predicate>", fontSize(15)), id("l<labelNum>"), lineColor("white"));
				edges += [edge("<n>", "l<labelNum>", gap(10))];	
				edges += [edge("l<labelNum>", "<post>", toArrow(ellipse(size(5),fillColor("black"))))];
			}else{
				edges += [edge("<n>", "<post>", toArrow(ellipse(size(5),fillColor("black"))))];				
			}	
			labelNum += 1;	
		}
	}
	return <labelNodes, edges>;
}