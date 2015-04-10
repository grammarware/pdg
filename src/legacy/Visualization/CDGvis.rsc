module Visualization::CDGvis

import Types;
import PDG;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import IO;
import List;
import Map;
import Set;
import String;
import Utils::Figure;

public str HEADER = "\n";

//displayCDG(|project://pdg-JavaTest/src/PDG/Sum.java|, 0);
public void displayCDG(loc project, int methNum){
	meth = getMethodAST(project)[methNum];
	tuple[ControlDependence cd, DataDependence dd, map[int, Statement] statements] pd = buildPDG(meth);
	list[int] nodes = toList(domain(pd.statements));
	render("Control Dependence Graph", buildCDG(pd.cd.dependences, nodes, pd.cd.regionNum, pd.statements));
}

private Figure buildCDG(map[int, rel[int, str]] cd, list[int] nodes, int regionNum, map[int, Statement] statements){
	str getHeader() { return HEADER; }
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(cd);
	list[Figure] nodes = buildNodes(nodes, regionNum, statements) + labelEdges.labelNodes;
	return vcat([text(getHeader,font("GillSans"),fontSize(13)),
				graph(nodes, labelEdges.edges, hint("layered"), vgap(40), hgap(40))], gap(5));
}

private list[Figure] buildNodes(list[int] nodes, int regionNum, map[int, Statement] statements){
	list[Figure] statementNodes = [statementNode(n, statements[n]) | n <- nodes];
	Figure entryNode = box(text("Entry"), id("-3"), size(10), fillColor("red"), gap(10));
	list[Figure] regionNodes = [box(text("R<(n*(-1))-4>"), id("<n>"), size(10), fillColor("green"), gap(10)) | n <- [regionNum..-3]];

	return statementNodes + regionNodes + entryNode;
}

private Figure statementNode(int n, Statement stat){
	loc location = getLoc(stat);
	return box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10),
			onMouseEnter(void() {setBrowserHeader(location);}),
			onMouseDown(goToSource(location)));
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

private void setBrowserHeader(loc location) {
	HEADER = "<center("<location>", 30)>";
}