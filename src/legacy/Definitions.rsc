module Definitions

import lang::java::m3::AST;
import Types;
import IO;
import Set;

public DefGenUse extractDefGenUse(Statement stat, int counting, DefGenUse s){
	visit(stat){
		case \variable(str name, int extraDimensions): {
			s.defs = insertDef(name, counting, s.defs);
			s.gens = insertGen(name, counting, s.gens);
		}
		case \variable(str name, int extraDimensions, Expression initializer): {
			s.defs = insertDef(name, counting, s.defs);
			s.gens = insertGen(name, counting, s.gens);
			s.uses = insertUse({name | /simpleName(str name) := initializer}, counting, s.uses);
		}
		case \assignment(\simpleName(str name), str operator, Expression rhs): {
			s.defs = insertDef(name, counting, s.defs);
			s.gens = insertGen(name, counting, s.gens);
			s.uses = insertUse({name | /simpleName(str name) := rhs}, counting, s.uses);
		}
		case \postfix(\simpleName(str name), _ ): {
			s.defs = insertDef(name, counting, s.defs);
			s.gens = insertGen(name, counting, s.gens);
			s.uses = insertUse({name}, counting, s.uses);
		}	
		case \prefix(str operator, \simpleName(str name)):{
			s.defs = insertDef(name, counting, s.defs);
			s.gens = insertGen(name, counting, s.gens);
			s.uses = insertUse({name}, counting, s.uses);
		}
		case \methodCall(_, _, list[Expression] arguments): {
			s.uses = insertUse({name | argu <- arguments, /simpleName(str name) := argu}, counting, s.uses);
		}
		case \methodCall(_, _, _, list[Expression] arguments): {
			s.uses = insertUse({name | argu <- arguments, /simpleName(str name) := argu}, counting, s.uses);
		}
	}
	return s;
}

public set[str] extractUse(Expression expr) {
	return { name | /simpleName(str name) := expr };
}

private map[str, set[int]] insertDef(str name, int stat, map[str, set[int]] m){
	if(name in m) {
		m[name] += {stat};
	} else {
		m[name] = {stat};
	}
	
	return m;
}

private map[int, set[str]] insertGen(str name, int stat, map[int, set[str]] m){
	if(stat in m) {
		m[stat] += {name};
	} else {
		m[stat] = {name};
	}
	
	return m;
}

private map[int, set[str]] insertUse(set[str] names, int stat, map[int, set[str]] m){
	if(size(names) == 0) {
		return m;
	}

	if(stat in m) {
		m[stat] += names;
	} else {
		m[stat] = names;
	}
	
	return m;
}