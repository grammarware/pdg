module graph::control::Flow

import lang::java::m3::AST;
import Tuple;
import List;
import Map;
import Relation;
import Type;
import IO;
import Types;
import Utils::ListRelation;
import Utils::List;
import Utils::Map;
import Definitions;

//mark every statement with analyzing sequence number
private map[int number, Statement stat] statements = ();

//'counting' is used to mark each statement
private int counting = 0;

//keey all the return statements
private list[int] returnStatements = [];

//for break and continue;
private int loop = 0;
//the statements followed by break or statement inside each loop
//-3 is break, -4 is continue; 'if' may have both
private map[int loop, map[int, list[int]] stat] breakOrContinue = ();

@doc{
	Condition followed by break or continue. Becasue normal 
	statements followed by bc dont have branch and compute 
	seperately for condition followed by bc, it need to do 
	separately and also connect to the following firststatement.
}
private list[int] condFollowdByBC = [];

map[str, set[int]] defs = ();
map[int, set[str]] gens = ();
map[int, set[str]] uses = ();

public ControlFlow getControlFlow(Declaration meth) {
	counting = 0;
	loop = 0;
	returnStatements = [];
	breakOrContinue[0] = ();
	condFollowdByBC = [];
	defs = ();
	gens = ();
	uses = ();
	return statementCF(meth.impl);
}

public map[int number, Statement stat] getStatements() {
	return statements;
}

public map[str, set[int]] getDefs() {
	return defs;
}

public map[int, set[str]] getGens() {
	return gens;
}

public map[int, set[str]] getUses() {
	return uses;
}

// Analyse each statement
private ControlFlow statementCF(stat:\block(_)) {
	return blockCF(stat.statements);
}

private ControlFlow statementCF(stat:\if(_, _)) {
	return ifCF(stat);
}

private ControlFlow statementCF(stat:\if(_, _, _)) {
	return ifCF(stat);
}

private ControlFlow statementCF(stat:\for(_, _, _)) {
	return forCF(stat);
}

private ControlFlow statementCF(stat:\for(_, _, _, _)) {
	return forCF(stat);
}

private ControlFlow statementCF(stat:\while(_, _)) {
	return whileCF(stat);
}

private ControlFlow statementCF(stat:\switch(_, _)) {
	return switchCF(stat);
}

//firstStatement is -2: means it is a break
private ControlFlow statementCF(\break()) = ControlFlow([], -2, []);
private ControlFlow statementCF(\break(_)) = ControlFlow([], -2, []);

//firstStatement is -3: means it is a break
private ControlFlow statementCF(\continue()) = ControlFlow([], -3, []);
private ControlFlow statementCF(\continue(_)) = ControlFlow([], -3, []);

private ControlFlow statementCF(stat:\return()) = returnCF(stat);
private ControlFlow statementCF(stat:\return(_)) = returnCF(stat);

private default ControlFlow statementCF(Statement statement) {
	statements += (counting: statement);
	
	startStatement = counting;
	endStatements = [counting];
	
	callDefGenUse(statement, counting);
	
	counting += 1;
	
	return ControlFlow([], startStatement, endStatements);
}


// \block(list[Statement] statements)
public ControlFlow blockCF(list[Statement] block) {
	lrel[int, int] edges = [];
	
	if(size(block) > 0) {
		ControlFlow controlFlow = statementCF(block[0]);
		startStatement = controlFlow.startStatement;
		
		//recurse inside the block
		ControlFlow blockCF = concatCF(controlFlow, tail(block));
		edges += blockCF.edges;
		endStatements = blockCF.endStatements;
	
		return ControlFlow(edges, startStatement, endStatements);
	}
	
	//firstStatement is -1: means it is an empty block
	return ControlFlow([], -1, []);	
}


// \if(Expression condition, Statement thenBranch)
// \if(Expression condition, Statement thenBranch, Statement elseBranch)
public ControlFlow ifCF(Statement statement) {
	int identifier = counting;
	
	//add the condition statement to the statement map and set it as the start of this sub-flow 
	statements += (identifier : \expressionStatement(statement.condition));
	uses[identifier] = extractUse(statement.condition);
	
	counting += 1;
	
	combinedThen = concatCF(ControlFlow([], identifier, [identifier]), [statement.thenBranch]);

	lrel[int, int] edges = combinedThen.edges;
	list[int] endStatements = combinedThen.endStatements;
	
	if(isBreak(statement.thenBranch) || isContinue(statement.thenBranch)) {
		condFollowdByBC += identifier;
	}
	
	if(\if(_,_) := statement) {
		endStatements += identifier;
	} else {
		combinedElse = concatCF(ControlFlow([], identifier, [identifier]), [statement.elseBranch]);
		edges += combinedElse.edges;
		endStatements += combinedElse.endStatements;
	}
	
	return ControlFlow(edges, identifier, dup(endStatements));	
}


// \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)
// \for(list[Expression] initializers, list[Expression] updaters, Statement body)
public ControlFlow forCF(Statement statement) {
	int startStatement = counting;
	list[int] endStatements = [];
	list[int] initializers = [];
	
	loop += 1;
	
	breakOrContinue[loop] = (); 
	
	for(initializer <- statement.initializers) {
		statements += (counting : \expressionStatement(initializer));
		initializers += [counting];
		
		callDefGenUse(\expressionStatement(initializer), counting);
		
		counting += 1;
	}
	
	currentEnd = counting - 1;
	loopStart = counting;
	
	//add the initializer sequence to the flow
	initializersEdges = toLRel(initializers);
	
	//if there is a condition
	if(\for(_,_,_,_) := statement) {
		statements += (counting : \expressionStatement(statement.condition));
		uses[counting] = extractUse(statement.condition);
		
		// Catenate the last initializer with the condition
		initializersEdges += <last(initializers), counting>;
		
		endStatements += [counting];
		currentEnd = counting;
		loopStart = counting;
		
		counting += 1;
	}
	
	combinedForBody = concatCF(ControlFlow(initializersEdges, startStatement, [currentEnd]), [statement.body]);

	// Catenate the condition or the last initializer(if no condition) with the forBody
	lrel[int, int] edges = combinedForBody.edges;
	list[int] updaters = [];

	for(updater <- statement.updaters) {
		statements += (counting : \expressionStatement(updater));
		updaters += counting;
		callDefGenUse(\expressionStatement(updater), counting);
	
		counting += 1;
	}
	
	//break or continue
	for(endStatement <- combinedForBody.endStatements && endStatement in breakOrContinue[loop]) {
		for(jump <- breakOrContinue[loop][endStatement]) {
			if(jump == -2) {
				endStatements += endStatement;
			} else {
				edges += [<endStatement, updaters[0]>];
			}
		}
	}
	
	//catenate the forBody with the updaters and the last updater with the loop start
	combinedFlow = combineTwoFlows(exclude(combinedForBody.endStatements, breakOrContinue[loop], []), updaters[0]);
	edges += combinedFlow.edges + toLRel(updaters) + <last(updaters), loopStart>;
	endStatements += combinedFlow.returns;
	
	//clear 
	breakOrContinue[loop] = ();
	
	return ControlFlow(edges, startStatement, dup(endStatements));
}


// \while(Expression condition, Statement body)
public ControlFlow whileCF(Statement statement) {
	int identifier = counting;
	
	statements += (identifier : \expressionStatement(statement.condition));
	uses[counting] = extractUse(statement.condition);
	
	counting += 1;
	loop += 1;
	
	breakOrContinue[loop] = (); 
	
	combinedWhileBody = concatCF(ControlFlow([], identifier, [identifier]), [statement.body]);
	combinedFlow = combineTwoFlows(exclude(combinedWhileBody.endStatements, breakOrContinue[loop], []), identifier);
	
	lrel[int, int] edges = combinedWhileBody.edges + combinedFlow.edges;
	list[int] endStatements = [identifier] + combinedFlow.returns;
	
	//break or continue
	for(endStatement <- combinedWhileBody.endStatements && endStatement in breakOrContinue[loop]) {
		for(jump <- breakOrContinue[loop][endStatement]) {
			if(jump == -2) {
				endStatements += endStatement;
			} else {
				edges += [<endStatement, identifier>];
			}
		}
	}
	
	breakOrContinue[loop] = ();	
	return ControlFlow(edges, identifier, endStatements);
}

// \switch(Expression expression, list[Statement] statements)
public ControlFlow switchCF(Statement statement) {
	int expressionIdentifier = counting;
	
	statements += (expressionIdentifier : \expressionStatement(statement.expression));
	uses[counting] = extractUse(statement.expression);
	
	counting += 1;
	switchStatements = statement.statements;

	//group by case
	int caseCount = -1;
	list[list[Statement]] statsGroupByCase = [];
	
	for(switchStatement <- switchStatements) {
		// Normally it starts with an case
		if(isCase(switchStatement)) {
			caseCount += 1;
			statsGroupByCase += [[]];
		} else {
			statsGroupByCase[caseCount] += [switchStatement];
		}
	}

	list[list[ControlFlow]] caseControlFlows = [[]];
	int flowIndex = 0;
	
	for(caseIndex <- [0..size(statsGroupByCase)]) {
		ControlFlow controlFlow = blockCF(statsGroupByCase[caseIndex]);
		caseControlFlows[flowIndex] += [controlFlow];
		
		//if there is a break then branch. if it is the last case, no need to do branch
		if(caseIndex != size(statsGroupByCase) - 1) {
			if(isBreak(last(statsGroupByCase[caseIndex])) || isReturn(last(statsGroupByCase[caseIndex]))) {
				flowIndex += 1;
				caseControlFlows += [[]];
			}
		}
	}
	
	list[int] endStatements = [];
	lrel[int, int] edges = [];
	
	for(controlFlows <- caseControlFlows) {
		ControlFlow combinedControlFlow = combineCFs(controlFlows);
		endStatements += combinedControlFlow.endStatements;
		edges += [<expressionIdentifier, controlFlow.startStatement> | controlFlow <- controlFlows] + combinedControlFlow.edges;
	}
	
	return ControlFlow(edges, expressionIdentifier, endStatements);
}

// | \return(Expression expression)
// | \return()
public ControlFlow returnCF(Statement statement) {
	returnIdentifier = counting;
	
	statements += (returnIdentifier : statement);
	returnStatements += [returnIdentifier];
	
	if(\return(Expression expression) := statement) {
		uses[counting] = extractUse(statement.expression);
	}
	
	counting += 1;
	
	return ControlFlow([], returnIdentifier, [returnIdentifier]);
}

//concatenate relation lists (recursion)
public ControlFlow concatCF(ControlFlow mainCF, []) {
	return mainCF;
}

public default ControlFlow concatCF(ControlFlow baseControlFlow, list[Statement] restStatements) {
	ControlFlow controlFlow = statementCF(restStatements[0]);

	// Not an empty block or break or return
	if(controlFlow.startStatement == -2 || controlFlow.startStatement == -3) {
		for(endStatement <- baseControlFlow.endStatements) {
			if(endStatement notin breakOrContinue[loop]) {
				breakOrContinue[loop][endStatement] = [controlFlow.startStatement];
			} else {
				breakOrContinue[loop][endStatement] += [controlFlow.startStatement];
			}
		}
		
		return baseControlFlow;
	} elseif(controlFlow.startStatement != -1) {
		int startStatement = baseControlFlow.startStatement;
		ControlFlow restControlFlow = concatCF(controlFlow, tail(restStatements));
		combinedFlow = 	combineTwoFlows(
							exclude(baseControlFlow.endStatements, breakOrContinue[loop], []), 
							controlFlow.startStatement
						);
		lrel[int, int] edges = baseControlFlow.edges + combinedFlow.edges + restControlFlow.edges;
		endStatements = combinedFlow.returns + restControlFlow.endStatements;
		
		for(endStatement <- baseControlFlow.endStatements, endStatement in breakOrContinue[loop]) { 
			endStatements += endStatement;
		}
		
		return ControlFlow(edges, startStatement, endStatements);
	}
	
	//if the following statement is an empty block, then ignore it
	if(controlFlow.startStatement == -1 && size(restStatements) > 1) {
		return concatCF(baseControlFlow, tail(restStatements));
	}
	
	//if there is only one element in the statement list and it is an empty block; or it is a break
	return baseControlFlow;
}

private ControlFlow combineCFs(list[ControlFlow] controlFlows) {
	int startStatement = controlFlows[0].startStatement;
	list[int] endStatements = [];
	lrel[int, int] edges = [];
	
	if(size(controlFlows) > 1) {
		for(i <- [0..size(controlFlows) - 1]) {
			combinedFlow = combineTwoFlows(controlFlows[i].endStatements, controlFlows[i+1].startStatement);
			edges += controlFlows[i].edges + combinedFlow.edges;
			endStatements += combinedFlow.returns;
		}
	}
	
	endStatements += last(controlFlows).endStatements;
	edges += last(controlFlows).edges;
	
	return ControlFlow(edges, startStatement, endStatements);
}

//catenate the last statements with the first statement of the next CF
private tuple[lrel[int, int] edges, list[int] returns] combineTwoFlows(list[int] endStatements, int startStatement) {
	list[int] returns = [];
	lrel[int, int] edges = [];
	
	for(endStatement <- endStatements) {
		if(endStatement in returnStatements) {
			returns += endStatement;
		} else {
			edges += [<endStatement, startStatement>];
		}
	}
	
	return <edges, returns>;
}

private void callDefGenUse(Statement stat, int counting) {
	<defs, gens, uses> = extractDefGenUse(stat, counting, <defs, gens, uses>);
}

private bool isCase(\case(_)) = true;
private bool isCase(\defaultCase()) = true;
private default bool isCase(Statement stat) = false;

private bool isBreak(\break(_)) = true;
private bool isBreak(\break()) = true;
private default bool isBreak(Statement stat) = false;

private bool isContinue(\continue(_)) = true;
private bool isContinue(\continue()) = true;
private default bool isContinue(Statement stat) = false;

private bool isReturn(\return(_)) = true;
private bool isReturn(\return()) = true;
private default bool isReturn(Statement stat) = false;
