module Statement::Definition

import lang::java::m3::AST;
import ADT;

public tuple[map[str, set[int]] defs, map[int, set[str]] gens] extractDefGen(Statement stat, int counting, map[str, set[int]] defs, map[int, set[str]] gens){
	visit(stat){
		case \variable(str name, int extraDimensions): {
			defs = insertStrToMap(name, counting, defs);
			gens = insertInToMap(name, counting, gens);
		}
		case \variable(str name, int extraDimensions, Expression \initializer): {
			defs = insertStrToMap(name, counting, defs);
			gens = insertInToMap(name, counting, gens);
		}
		case \assignment(\simpleName(str name), _ , _): {
			defs = insertStrToMap(name, counting, defs);
			gens = insertInToMap(name, counting, gens);
		}
		case \postfix(\simpleName(str name), _ ): {
			defs = insertStrToMap(name, counting, defs);
			gens = insertInToMap(name, counting, gens);
		}
	}
	return <defs, gens>;
}

private map[str, set[int]] insertStrToMap(str name, int stat, map[str, set[int]] m){
	if(name in m) m[name] += {stat};
	else m[name] = {stat};
	return m;
}

private map[int, set[str]] insertInToMap(str name, int stat, map[int, set[str]] m){
	if(stat in m) m[stat] += {name};
	else m[stat] = {name};
	return m;
}