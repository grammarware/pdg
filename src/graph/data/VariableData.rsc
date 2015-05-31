module graph::\data::VariableData

import Prelude;
import lang::java::m3::AST;
import graph::DataStructures;
import analysis::m3::Registry;


private map[int, set[str]] uses = ();
private map[str, set[VariableData]] definitions = ();
private map[int, set[VariableData]] generators = ();
private map[int, set[VariableData]] kills = ();
private map[str, loc] declarationLocs = ();

public void initializeVariableData(MethodData methodData) {
	definitions = ();
	uses = ();
	generators = ();
	kills = ();
	declarationLocs = ();
	
	for(identifier <- environmentDomain(methodData)) {
		kills[identifier] = {};
		generators[identifier] = {};
	}
}

public map[int, set[str]] getUses() {
	return uses;
}

public map[str, set[VariableData]] getDefinitions() {
	return definitions;
}

public map[int, set[VariableData]] getGenerators() {
	return generators;
}

public map[int, set[VariableData]] getKills() {
	return kills;
}

public void storeDefinition(str variableName, int statement) {
	VariableData definition = <variableName, statement>;
	
	if(variableName in definitions) {
		definitions[variableName] += { definition };
	} else {
		definitions[variableName] = { definition };
	}
}

public void storeUse(int statement, str variableName) {
	if(statement in uses) {
		uses[statement] += { variableName };
	} else {
		uses[statement] = { variableName };
	}
}

public void storeGenerator(int statement, str variableName) {
	VariableData generated = <variableName, statement>;
	
	if(statement in generators) {
		generators[statement] += { generated };
	} else {
		generators[statement] = { generated };
	}
}

public void storeKill(int statement, set[VariableData] killSet) {
	if(statement in kills) {
		kills[statement] += killSet;
	} else {
		kills[statement] = killSet;
	}
}

public loc getDeclarationLoc(str name) {
	return declarationLocs[name];
}

public void checkForUse(int identifier, Expression expression) {
	if(sName: \simpleName(name) := expression) {
		if(!isParameterVariable(name)) {
			if(sName@decl.scheme == "java+class") {
				return;
			}
			declarationLocs[name] = sName@decl;
		}
		storeUse(identifier, name);
	}
	
	if(callNode: \methodCall(_, name, _) := expression) {
		if(callNode@typ != \void()) {
			try {
				storeUse(identifier, "$method_<callNode@decl.file>_return_<callNode@src.offset>");
			}
			catch: {
				storeUse(identifier, "$method_<name>_return_<callNode@src.offset>");
			}
		}
	}
	
	if(callNode: \methodCall(_, _, name, _):= expression) {
		if(callNode@typ != \void()) {
			try {
				storeUse(identifier, "$method_<callNode@decl.file>_return_<callNode@src.offset>");
			}
			catch: {
				storeUse(identifier, "$method_<name>_return_<callNode@src.offset>");
			}
		}
	}
}

public void checkForDefinition(int identifier, Expression expression) {
	if(\simpleName(name) := expression) {
		storeDefinition(name, identifier);
		storeGenerator(identifier, name);
	} 
}