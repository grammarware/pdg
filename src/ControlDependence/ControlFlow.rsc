module ControlDependence::ControlFlow

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
import Statement::Definition;
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
//condition followed by break or continue;
//becasue normal statements followed by bc dont have branch and compute seperately
//for condition followed by bc, it need to do separately and also connect to the following firststatement
private list[int] condFollowdByBC = [];

map[str, set[int]] defs = ();
map[int, set[str]] gens = ();
map[int, set[str]] uses = ();

public CF getControlFlow(Declaration meth){
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

public map[int number, Statement stat] getStatements(){
	return statements;
}

public map[str, set[int]] getDefs(){
	return defs;
}

public map[int, set[str]] getGens(){
	return gens;
}

public map[int, set[str]] getUses(){
	return uses;
}

// Analyse each statement
private CF statementCF(stat:\block(_)) = blockCF(stat.statements);
private CF statementCF(stat:\if(_, _)) = ifCF(stat);
private CF statementCF(stat:\if(_, _, _)) = ifCF(stat);
private CF statementCF(stat:\for(_, _, _)) = forCF(stat);
private CF statementCF(stat:\for(_, _, _, _)) = forCF(stat);
private CF statementCF(stat:\while(_, _)) = whileCF(stat);
private CF statementCF(stat:\switch(_, _)) = switchCF(stat);

//firstStatement is -2: means it is a break
private CF statementCF(\break()) = controlFlow([], -2, []);
private CF statementCF(\break(_)) = controlFlow([], -2, []);

//firstStatement is -3: means it is a break
private CF statementCF(\continue()) = controlFlow([], -3, []);
private CF statementCF(\continue(_)) = controlFlow([], -3, []);

private CF statementCF(stat:\return()) = returnCF(stat);
private CF statementCF(stat:\return(_)) = returnCF(stat);

private default CF statementCF(Statement stat)
{
	statements += (counting: stat);
	firstStatement = counting;
	lastStatements = [counting];
	
	callDefGenUse(stat, counting);
	
	counting += 1;
	return controlFlow([], firstStatement, lastStatements);
}


// \block(list[Statement] statements)
public CF blockCF(list[Statement] block){
	lrel[int, int] cflow = []; 
	if(size(block) > 0){
		CF cf = statementCF(block[0]);
		firstStatement = cf.firstStatement;
		//recurse inside the block
		CF blockCF = concatCF(cf, tail(block));
		cflow += blockCF.cflow;
		lastStatements = blockCF.lastStatements;
	
		return controlFlow(cflow, firstStatement, lastStatements);
	}else{
		//firstStatement is -1: means it is an empty block
		return controlFlow([], -1, []);
	}	
}


// \if(Expression condition, Statement thenBranch)
// \if(Expression condition, Statement thenBranch, Statement elseBranch)
public CF ifCF(Statement stat){
	int cond = counting;
	//add the condition statement to the statement map and set it as the start of this sub-flow 
	statements += (cond: Statement::\expressionStatement(stat.condition));
	uses[counting] = extractUse(stat.condition);
	counting += 1;
	//CF thenBranchCF = statementCF(stat.thenBranch);
	combinedThen = concatCF(controlFlow([], cond, [cond]), [stat.thenBranch]);
	//lrel[int, int] cflow = [<cond, thenBranchCF.firstStatement>] + thenBranchCF.cflow; 
	lrel[int, int] cflow = combinedThen.cflow;
	list[int] lastStatements = combinedThen.lastStatements;
	if(isBreak(stat.thenBranch) || isContinue(stat.thenBranch)) condFollowdByBC += cond;
	
	if(Statement::\if(_,_) := stat) lastStatements += cond;
	else{
		//CF elseBranchCF = statementCF(stat.elseBranch);
		combinedElse = concatCF(controlFlow([], cond, [cond]), [stat.elseBranch]);
		cflow += combinedElse.cflow;
		lastStatements += combinedElse.lastStatements;
		
	}
	
	return controlFlow(cflow, cond, dup(lastStatements));	
}


//// \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)
//// \for(list[Expression] initializers, list[Expression] updaters, Statement body)
public CF forCF(Statement stat){
	int firstStatement = counting;
	list[int] lastStatements = [];
	list[int] initializers = [];
	list[int] updaters = [];
	loop += 1;
	breakOrContinue[loop] = (); 
	
	for(initializer <- stat.initializers){
		statements += (counting: Statement::\expressionStatement(initializer));
		initializers += counting;
		callDefGenUse(Statement::\expressionStatement(initializer), counting);
		counting += 1;
	}
	currentLast = counting - 1;
	loopStart = counting;
	//add the initializer sequence to the flow
	initCFlow = toLRel(initializers);
	//if there is a condition
	if(Statement::\for(_,_,_,_) := stat){
		statements += (counting: Statement::\expressionStatement(stat.condition));
		uses[counting] = extractUse(stat.condition);
		//catenate the last initializer with the condition
		initCFlow += <last(initializers), counting>;
		lastStatements += counting;
		currentLast = counting;
		loopStart = counting;
		counting += 1;
	}
	combinedForBody = concatCF(controlFlow(initCFlow, firstStatement, [currentLast]), [stat.body]);
	//CF forBodyCF = statementCF(stat.body);
	//catenate the condition or the last initializer(if no condition) with the forBody
	lrel[int, int] cflow = combinedForBody.cflow;

	for(updater <- stat.updaters){
		statements += (counting: Statement::\expressionStatement(updater));
		updaters += counting;
		callDefGenUse(Statement::\expressionStatement(updater), counting);
		counting += 1;
	}
	
	//break or continue
	for(l <- combinedForBody.lastStatements && l in breakOrContinue[loop]){
		for(bc <- breakOrContinue[loop][l]){
			if(bc == -2) lastStatements += l;
			else cflow += [<l, updaters[0]>];
		}
	}
	
	//catenate the forBody with the updaters and the last updater with the loop start
	combinedFlow = combineTwoFlows(exclude(combinedForBody.lastStatements, breakOrContinue[loop], []), updaters[0]);
	cflow += combinedFlow.cflow + toLRel(updaters) + <last(updaters), loopStart>;
	lastStatements += combinedFlow.rStatements;
	
	//clear 
	breakOrContinue[loop] = ();
	return controlFlow(cflow, firstStatement, dup(lastStatements));
}


// \while(Expression condition, Statement body)
public CF whileCF(Statement stat){
	int cond = counting;
	statements += (cond: Statement::\expressionStatement(stat.condition));
	uses[counting] = extractUse(stat.condition);
	counting += 1;
	loop += 1;
	breakOrContinue[loop] = (); 
	
	combinedWhileBody = concatCF(controlFlow([], cond, [cond]), [stat.body]);
	combinedFlow = combineTwoFlows(exclude(combinedWhileBody.lastStatements, breakOrContinue[loop], []), cond);
	lrel[int, int] cflow = combinedWhileBody.cflow + combinedFlow.cflow;
	list[int] lastStatements = [cond] + combinedFlow.rStatements;
	
	//break or continue
	for(l <- combinedWhileBody.lastStatements && l in breakOrContinue[loop]){
		for(bc <- breakOrContinue[loop][l]){
			if(bc == -2) lastStatements += l;
			else cflow += [<l, cond>];
		}
	}
	
	breakOrContinue[loop] = ();	
	return controlFlow(cflow, cond, lastStatements);
}

// \switch(Expression expression, list[Statement] statements)
public CF switchCF(Statement stat){
	int expr = counting;
	statements += (expr: Statement::\expressionStatement(stat.expression));
	uses[counting] = extractUse(stat.expression);
	counting += 1;
	switchStatements = stat.statements;

	//group by case
	int j = -1;
	list[list[Statement]] statsGroupByCase = [];
	for(s <- switchStatements){
		//normally it starts with an case
		if(isCase(s)){
			j += 1;
			statsGroupByCase += [[]];
		}
		else statsGroupByCase[j] += [s];
	}

	list[list[CF]] caseCFs = [[]];
	int k = 0;
	for(i <- [0..size(statsGroupByCase)]){
		CF cf = blockCF(statsGroupByCase[i]);
		caseCFs[k] += [cf];
		//if there is a break then branch. if it is the last case, no need to do branch
		if(i != size(statsGroupByCase) - 1){
			if(isBreak(last(statsGroupByCase[i])) || isReturn(last(statsGroupByCase[i]))){
				k += 1;
				caseCFs += [[]];
			}
		}
	}
	
	list[int] lastStatements = [];
	lrel[int, int] cflow = [];
	for(cfs <- caseCFs){
		CF combinedCF = combineCFs(cfs);
		lastStatements += combinedCF.lastStatements;
		cflow += [<expr, cf.firstStatement> | cf <- cfs] + combinedCF.cflow;
	}
	
	return controlFlow(cflow, expr, lastStatements);
}

// | \return(Expression expression)
// | \return()
public CF returnCF(Statement stat){
	rStat = counting;
	statements += (rStat: stat);
	returnStatements += [rStat];
	if(Statement::\return(Expression expression) := stat) uses[counting] = extractUse(stat.expression);
	counting += 1;
	return controlFlow([], rStat, [rStat]);
}

//concatenate relation lists (recursion)
public CF concatCF(CF mainCF, []) = mainCF;
public default CF concatCF(CF mainCF, list[Statement] restStatements){
	CF firstCF = statementCF(restStatements[0]);
	//not an empty block or break or return
	//if(firstCF.firstStatement != -1 && firstCF.firstStatement != -2 && firstCF.firstStatement notin returnStatements){
	if(firstCF.firstStatement == -2 || firstCF.firstStatement == -3){
		for(l <- mainCF.lastStatements){
			if(l notin breakOrContinue[loop]) breakOrContinue[loop][l] = [firstCF.firstStatement];
			else breakOrContinue[loop][l] += [firstCF.firstStatement];
		}
		return mainCF;
	}elseif(firstCF.firstStatement != -1){
		int firstStatement = mainCF.firstStatement;
		CF restCF = concatCF(firstCF, tail(restStatements));
		combinedFlow = combineTwoFlows(exclude(mainCF.lastStatements, breakOrContinue[loop], condFollowdByBC), firstCF.firstStatement);
		lrel[int, int] cflow = mainCF.cflow + combinedFlow.cflow + restCF.cflow;
		lastStatements = combinedFlow.rStatements + restCF.lastStatements;
		
		for(l <- mainCF.lastStatements, l in breakOrContinue[loop]) lastStatements += l;
		
		//lrel[int, int] cflow = mainCF.cflow + [<l, firstCF.firstStatement> | l <- mainCF.lastStatements] + restCF.cflow;
		return controlFlow(cflow, firstStatement, lastStatements);
	}
	//if the following statement is an empty block, then ignore it
	if(firstCF.firstStatement == -1 && size(restStatements) > 1) return concatCF(mainCF, tail(restStatements));
	//if there is only one element in the statement list and it is an empty block; or it is a break
	else return mainCF;
}

private CF combineCFs(list[CF] cfs){
	int firstStatement = cfs[0].firstStatement;
	list[int] lastStatements = [];
	lrel[int, int] cflow = [];
	if(size(cfs) > 1){
		for(i <- [0..size(cfs) - 1]){
			combinedFlow = combineTwoFlows(cfs[i].lastStatements, cfs[i+1].firstStatement);
			cflow += cfs[i].cflow + combinedFlow.cflow;
			lastStatements += combinedFlow.rStatements;
		}
	}
	lastStatements += last(cfs).lastStatements;
	cflow += last(cfs).cflow;
	return controlFlow(cflow, firstStatement, lastStatements);
}

//catenate the last statements with the first statement of the next CF
private tuple[lrel[int, int] cflow, list[int] rStatements] combineTwoFlows(list[int] ls, int f){
	//int firstStatement = cf1. firstStatement;
	list[int] rStatements = [];
	lrel[int, int] cflow = [];
	for(l <- ls){
		if(l in returnStatements){
			rStatements += l;
		}else{
			cflow += [<l, f>];
		}
	}
	return <cflow, rStatements>;
}

private void callDefGenUse(Statement stat, int counting){
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
