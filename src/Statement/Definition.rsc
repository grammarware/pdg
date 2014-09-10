module Statement::Definition

import lang::java::m3::AST;
import ADT;
import IO;
import Set;

public tuple[map[str, set[int]] defs, map[int, set[str]] gens, map[int, set[str]] uses] extractDefGenUse(Statement stat, int counting, map[str, set[int]] defs, map[int, set[str]] gens, map[int, set[str]] uses){
	visit(stat){
		case \variable(str name, int extraDimensions): {
			defs = insertDef(name, counting, defs);
			gens = insertGen(name, counting, gens);
		}
		case \variable(str name, int extraDimensions, Expression initializer): {
			defs = insertDef(name, counting, defs);
			gens = insertGen(name, counting, gens);
			uses = insertUse(extractUse(initializer), counting, uses);
		}
		case \assignment(\simpleName(str name), str operator, Expression rhs): {
			defs = insertDef(name, counting, defs);
			gens = insertGen(name, counting, gens);
			uses = insertUse(extractUse(rhs), counting, uses);
		}
		case \postfix(\simpleName(str name), _ ): {
			defs = insertDef(name, counting, defs);
			gens = insertGen(name, counting, gens);
			uses = insertUse({name}, counting, uses);
		}	
		case \prefix(str operator, \simpleName(str name)):{
			defs = insertDef(name, counting, defs);
			gens = insertGen(name, counting, gens);
			uses = insertUse({name}, counting, uses);
		}
		case \methodCall(_, _, list[Expression] arguments): {
			names = {};
			for(argu <- arguments) names += extractUse(argu);
			uses = insertUse(names, counting, uses);
		}
		case \methodCall(_, _, _, list[Expression] arguments): {
			names = {};
			for(argu <- arguments) names += extractUse(argu);
			uses = insertUse(names, counting, uses);
		}
	}
	return <defs, gens, uses>;
}

public set[str] extractUse(Expression expr){
	set[str] names = {};
	visit(expr){
		case \simpleName(str name): {
			names += name;
		}
	}
	return names;
}

private map[str, set[int]] insertDef(str name, int stat, map[str, set[int]] m){
	if(name in m) m[name] += {stat};
	else m[name] = {stat};
	return m;
}

private map[int, set[str]] insertGen(str name, int stat, map[int, set[str]] m){
	if(stat in m) m[stat] += {name};
	else m[stat] = {name};
	return m;
}

private map[int, set[str]] insertUse(set[str] names, int stat, map[int, set[str]] m){
	if(size(names) == 0) return m;
	else{
		if(stat in m) m[stat] += names;
		else m[stat] = names;
		return m;
	}
}