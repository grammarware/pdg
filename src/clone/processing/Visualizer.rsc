module clone::processing::Visualizer

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;

import clone::DataStructures;


public list[LineDecoration] getLineDecorations(set[int] lineNumbers) {
	return [ highlight(lineNumber, "Clone") | lineNumber <- lineNumbers ];
}

int identifier = 0;

public Figures createBoxes(map[loc, set[int]] clones) {
	return [ box(text("<identifier>: <clone.file>"), id("<identifier>: <clone.uri>"), 
						size(50), fillColor("lime"), 
						onMouseDown(
							goToSource(
								clone, getLineDecorations(clones[clone])
							)
						)
				) | clone <- clones ];
}

public bool(int button, map[KeyModifier,bool] modifiers) goToSource(loc location, list[LineDecoration] decorations) =
	bool(int button, map[KeyModifier,bool] modifiers)
	{ 
	    if(button == 1) {
	        edit(location, decorations);
	        return true;
	    }
	    return false;
	};

public list[Figure] increaseIdentifier() {
	identifier += 1;
	return [];
}
	
public void visualizeCloneCandidates(CandidatePairs candidates) {
	identifier = 0;
	
	list[Figure] boxes = ([] 
			| it + createBoxes(first.highlights) + createBoxes(second.highlights) + increaseIdentifier() 
			| <first, second> <- candidates 
		);
	render(graph(boxes, [], hint("layered"), gap(50)));
}