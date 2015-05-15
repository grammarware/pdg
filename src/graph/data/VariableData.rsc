module graph::\data::VariableData

import lang::java::m3::AST;

import graph::DataStructures;


alias VariableData = tuple[str name, int origin];

private map[int, set[str]] uses = ();
private map[str, set[VariableData]] definitions = ();
private map[int, set[VariableData]] generators = ();
private map[int, set[VariableData]] kills = ();

public void initializeVariableData(MethodData methodData) {
	definitions = ();
	uses = ();
	generators = ();
	kills = ();
	
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

public void checkForUse(int identifier, Expression expression) {
	if(\simpleName(name) := expression) {
		storeUse(identifier, name);
	}
	
	if(callNode: \methodCall(_, name, _) := expression) {
		if(callNode@typ != \void()) {
			storeUse(identifier, "$method_<name>_return_<callNode@src.offset>");
		}
	}
	
	if(callNode: \methodCall(_, _, name, _):= expression) {
		if(callNode@typ != \void()) {
			storeUse(identifier, "$method_<name>_return_<callNode@src.offset>");
		}
	}
}

public void checkForDefinition(int identifier, Expression expression) {
	if(\simpleName(name) := expression) {
		storeDefinition(name, identifier);
		storeGenerator(identifier, name);
	} 
}