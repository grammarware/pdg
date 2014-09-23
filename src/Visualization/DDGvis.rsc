module Visualization::DDGvis

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

//displayDDG(|project://JavaTest/src/PDG/dataFlow/DataDependence.java|);
public void displayDDG(loc project){
	meth = getMethodAST(project)[0];
	tuple[ControlDependence cd, DataDependence dd, map[int, Statement] statements] pd = buildPDG(meth);
	render(buildDDG(pd.dd.dependences));
}

private Figure buildDDG(map[int, rel[int, str]] dd){
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(dd);
	list[Figure] nodes = buildNodes(dd) + labelEdges.labelNodes;
	return graph(nodes, labelEdges.edges, hint("layered"), vgap(10), hgap(10));
}

private list[Figure] buildNodes(map[int, rel[int, str]] dd){
	set[int] nodes = {};
	for(use <- dd){
		nodes += use;
		for(<def, name> <- dd[use]){
			nodes += def;
		}
	}
	return [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- nodes];
}

private tuple[list[Figure] labelNodes, list[Edge] edges] buildEdges(map[int, rel[int, str]] dd){
	list[Edge] edges = [];
	list[Figure] labelNodes = [];
	int labelNum = 0;
	for(use <- dd){
		for(<def, name> <- dd[use]){
			labelNodes += box(text("<name>", fontSize(15)), id("l<labelNum>"), lineColor("white"));
			edges += [edge("<def>", "l<labelNum>", lineStyle("dashdot"), lineColor("Blue"))];	
			edges += [edge("l<labelNum>", "<use>", lineStyle("dashdot"), lineColor("Blue"), toArrow(ellipse(size(5),fillColor("Blue"))))];
			labelNum += 1;
		}
	}
	return <labelNodes, edges>;
}