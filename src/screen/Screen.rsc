module screen::Screen

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import lang::java::m3::AST;

import extractors::Project;
import graph::DataStructures;


public loc getMethodLocation(str methodName, str fileName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>/ := method.file, name == methodName
			, method.parent.file == fileName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}


public loc getMethodLocation(str methodName, M3 projectModel) {
	for(method <- getM3Methods(projectModel)) {
		if(/<name:.*>\(/ := method.file, name == methodName) {
			return method;
		}
	}
	
	throw "Method \"<methodName>\" does not exist.";
}

public list[Edge] createEdges(str methodName, Graph[int] tree, str style, str color) {
	return [ edge("<methodName>:<graphEdge.from>", "<methodName>:<graphEdge.to>", 
					lineStyle(style), lineColor(color), toArrow(box(size(10), 
					fillColor(color)))) | graphEdge <- tree ];
}

private str getBoxColor(NodeType nodeType) {
	switch(nodeType) {
		case Normal(): return "lightgreen";
		case CallSite(): return "lightpink";
		case Parameter(): return "beige";
		case Global(): return "darkorange";
	}
}

public Figures createBoxes(MethodData methodData) {	
	return [ box(text("<methodData.name>:<treeNode>"), id("<methodData.name>:<treeNode>"), 
						size(50), fillColor(getBoxColor(resolveIdentifier(methodData, treeNode)@nodeType)), 
						onMouseDown(
							goToSource(
								getLocation(
									resolveIdentifier(methodData, treeNode)
								)
							)
						)
				) | treeNode <- environmentDomain(methodData) ];
}

public loc getLocation(node stat){
	return cast(#loc, getAnnotations(stat)["src"]);
}

public bool(int button, map[KeyModifier,bool] modifiers) goToSource(loc location) =
	bool(int button, map[KeyModifier,bool] modifiers)
	{ 
	    if(button == 1) {
	        edit(location,[]);
	        return true;
	    }
	    return false;
	};