module ControlDependence::Dominance

import lang::java::m3::AST;
import Utils::Traversal;
import Utils::ListRelation;
import ADT;

public list[int] getDominator(CF cf, int statementsNum){
	map[int, list[int]] relation = toMap(cf.cflow);
	int first = cf.firstStatement;
	list[int] postOrder = toPostOrder(relation, first, statementsNum);
	return blabla;
}