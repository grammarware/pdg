module ADT

import lang::java::m3::AST;

data CF = controlFlow(lrel[int stat1, int stat2] cflow, int firstStatement, list[int] lastStatements);
data DF = dataFlow(lrel[int stat1, int stat2, str name] dflow, Environment environment);
