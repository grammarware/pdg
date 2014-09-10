module ADT

import lang::java::m3::AST;

data CF = controlFlow(lrel[int stat1, int stat2] cflow, int firstStatement, list[int] lastStatements);

data ControlDependence = CD(map[int, rel[int, str]] dependences, int regionNum);
data DataDependence = DD(map[int use, rel[int def, str name] defs] dependences);
