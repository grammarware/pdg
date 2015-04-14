module legacy::Visualization::DDGvis

import legacy::Types;
import legacy::PDG;
import lang::java::m3::AST;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import IO;
import List;
import Map;
import Set;
import String;
import legacy::Utils::Figure;

public str HEADER = "\n";

//displayDDG(|project://JavaTest/src/PDG/Sum.java|, 0);
public void displayDDG(loc project, int methNum){
	meth = getMethodAST(project)[methNum];
	tuple[ControlDependence cd, DataDependence dd, map[int, Statement] statements] pd = buildPDG(meth);
	render("Data Dependence Graph", buildDDG(pd.dd.dependences, pd.statements));
}

private Figure buildDDG(map[int, rel[int, str]] dd, map[int, Statement] statements){
	str getHeader() { return HEADER; }
	tuple[list[Figure] labelNodes, list[Edge] edges] labelEdges = buildEdges(dd);
	list[Figure] nodes = [statementNode(n, statements[n]) | n <- nodes(dd)] + labelEdges.labelNodes;
	return vcat([text(getHeader,font("GillSans"),fontSize(13)),
			graph(nodes, labelEdges.edges, hint("layered"), vgap(10), hgap(10))], gap(5));
}

private Figure statementNode(int n, Statement stat){
	loc location = getLoc(stat);
	return box(text("<n>"), id("<n>"), size(10), fillColor("lightgreen"), gap(10),
			onMouseEnter(void() {setBrowserHeader(location);}),
			onMouseDown(goToSource(location)));
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

private set[int] nodes(map[int, rel[int, str]] dd){
	set[int] nodes = {};
	for(use <- dd){
		nodes += use;
		for(<def, name> <- dd[use]){
			nodes += def;
		}
	}
	return nodes;
}

private void setBrowserHeader(loc location) {
	HEADER = "<center("<location>", 30)>";
}