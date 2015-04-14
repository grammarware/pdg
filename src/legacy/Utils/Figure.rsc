module legacy::Utils::Figure

import vis::KeySym;
import util::Editors;
import legacy::graph::control::Flow;
import lang::java::m3::AST;
import util::Editors;

// Returns a bool function to use in onMouseDown that links edits a given location
// when the left button is pressed.
// @param f: location (of a file);
// @return: bool, depending whether left button was clicked or not.
public bool(int button, map[KeyModifier,bool] modifiers) goToSource(loc location) =
bool(int button, map[KeyModifier,bool] modifiers)
{ 
    if(button == 1) {
        edit(location,[]);
        return true;
    }
    return false;
};


public loc getLoc(Statement stat){
	if(Statement::\expressionStatement(Expression stmt) := stat) 
		return stmt@src;
	else
		return stat@src;
}