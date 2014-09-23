module Visualization::PDGvis

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

//displayPDG(|project://JavaTest/src/PDG/Sum.java|);
public void displayPDG(loc project){
	meth = getMethodAST(project)[0];
	tuple[ControlDependence cd, DataDependence dd, map[int, Statement] statements] pd = buildPDG(meth);
	list[int] nodes = toList(domain(pd.statements));
	//renderSave(buildPDG(pd.cd.dependences, pd.dd.dependences, nodes, pd.cd.regionNum), |file:///Users/Lulu/Desktop/pdg.png|);
	render("PDG", buildPDG(pd.cd.dependences, pd.dd.dependences, nodes, pd.cd.regionNum));
}

private Figure buildPDG(map[int, rel[int, str]] cd, map[int, rel[int, str]] dd, list[int] nodes, int regionNum){
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(cd, dd);
	list[Figure] nodes = buildNodes(nodes, regionNum) + labelEdges.labelNodes;
	return graph(nodes, labelEdges.edges, hint("layered"), vgap(10), hgap(10));
}

private list[Figure] buildNodes(list[int] nodes, int regionNum){
	list[Figure] nodes = [box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10)) | n <- nodes];
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	//Figure stopNode = box(text("Stop"), id("-2"), size(10), fillColor("red"), gap(10));
	//Figure startNode = box(text("Start"), id("-1"), size(10), fillColor("red"), gap(10));
	list[Figure] regionNodes = [box(text("R<(n*(-1))-4>"), id("<n>"), size(10), fillColor("green"), gap(10)) | n <- [regionNum..-3]];

	return [entryNode] + nodes + regionNodes;
}

private tuple[list[Figure] labelNodes, list[Edge] edges] buildEdges(map[int, rel[int, str]] cd, map[int, rel[int, str]] dd){
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