module Types

import lang::java::m3::AST;
import vis::KeySym;

data ControlFlow = ControlFlow(lrel[int begin, int end] edges, int startStatement, list[int] endStatements);

data ControlDependence = CD(map[int, rel[int, str]] dependences, int regionNum);
data DataDependence = DD(map[int use, rel[int def, str name] defs] dependences);

data KindOfGraph
	= PDG() // Program Dependence Graph
	| CDG() // Control Dependence Graph
	| CFG() // Control Flow Graph
	| PDT() // Post-Dominator Tree
	| DDG();// Data Dependence Graph

alias DefGenUse
	= tuple[
			map[str, set[int]] defs,
			map[int, set[str]] gens,
			map[int, set[str]] uses
		];

alias Handler = bool(int button, map[KeyModifier,bool] modifiers);