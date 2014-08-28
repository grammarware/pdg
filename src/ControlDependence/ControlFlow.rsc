module ControlDependence::ControlFlow

import lang::java::m3::AST;
import Tuple;
import List;
import Map;
import Relation;
import Type;
import IO;
import ADT;
import Utils::ListRelation;

//mark every statement with analyzing sequence number
private map[int number, Statement stat] statements = ();

//'counting' is used to mark each statement
private int counting = 0;

//keey all the return statements
public list[int] returnStatements = [];

public CF getControlFlow(Statement stat, Environment environment){
	counting = 0;
	returnStatements = [];
	return statementCF(stat);
}

public map[int number, Statement stat] getStatements(){
	return statements;
}

//analyze each statement
private CF statementCF(Statement stat){
	switch(stat){
		case \block(_): return blockCF(stat.statements);
		case \if(_, _): return ifCF(stat);
		case \if(_, _, _): return ifCF(stat);
		case \for(_, _, _): return forCF(stat);
		case \for(_, _, _, _): return forCF(stat);
		case \while(_, _): return whileCF(stat);
		case \switch(_, _): return switchCF(stat);
		
		//firstStatement is -2: means it is a break
		case \break(_): return controlFlow([], -2, []);
		//firstStatement is -3: means it is a return
		case \return(): return returnCF(stat);
		case \return(_): return returnCF(stat);
		//default: {
		//	statements += (counting: stat);
		//	firstStatement = counting;
		//	lastStatements = [counting];
		//	counting += 1;
		//	
		//	
		//	return controlFlow([], first, last), dataFlow(dflow, environment)>;
		//}
		default: {	
			statements += (counting: stat);
			firstStatement = counting;
			lastStatements = [counting];
			counting += 1;
			return controlFlow([], firstStatement, lastStatements);
		}
	}
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
	counting += 1;
	CF thenBranchCF = statementCF(stat.thenBranch);
	lrel[int, int] cflow = [<cond, thenBranchCF.firstStatement>] + thenBranchCF.cflow; 
	list[int] lastStatements = thenBranchCF.lastStatements;
	if(Statement::\if(_,_) := stat) lastStatements += cond;
	else{
		CF elseBranchCF = statementCF(stat.elseBranch);
		cflow += [<cond, elseBranchCF.firstStatement>] + elseBranchCF.cflow;
		lastStatements += elseBranchCF.lastStatements;
		
	}
	return controlFlow(cflow, cond, lastStatements);	
}


//// \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)
//// \for(list[Expression] initializers, list[Expression] updaters, Statement body)
public CF forCF(Statement stat){
	int firstStatement = counting;
	list[int] lastStatements = [];
	list[int] initializers = [];
	list[int] updaters = [];
	for(initializer <- stat.initializers){
		statements += (counting: Statement::\expressionStatement(initializer));
		initializers += counting;
		counting += 1;
	}
	currentLast = counting - 1;
	loopStart = counting;
	//add the initializer sequence to the flow
	lrel[int, int] cflow = toLRel(initializers);
	//if there is a condition
	if(Statement::\for(_,_,_,_) := stat){
		statements += (counting: Statement::\expressionStatement(stat.condition));
		//catenate the last initializer with the condition
		cflow += <last(initializers), counting>;
		lastStatements += counting;
		currentLast = counting;
		loopStart = counting;
		counting += 1;
	}
	
	CF forBodyCF = statementCF(stat.body);
	//catenate the condition or the last initializer(if no condition) with the forBody
	cflow += [<currentLast, forBodyCF.firstStatement>] + forBodyCF.cflow;
	
	for(updater <- stat.updaters){
		statements += (counting: Statement::\expressionStatement(updater));
		updaters += counting;
		counting += 1;
	}
	
	//catenate the forBody with the updaters and the last updater with the loop start
	combinedFlow = combineTwoFlows(forBodyCF.lastStatements, updaters[0]);
	cflow += combinedFlow.cflow + toLRel(updaters) + <last(updaters), loopStart>;
	lastStatements += combinedFlow.rStatements;
	return controlFlow(cflow, firstStatement, lastStatements);
}


// \while(Expression condition, Statement body)
public CF whileCF(Statement stat){
	int cond = counting;
	statements += (cond: Statement::\expressionStatement(stat.condition));
	counting += 1;
	CF bodyCF = statementCF(stat.body);
	combinedFlow = combineTwoFlows(bodyCF.lastStatements, cond);
	lrel[int, int] cflow = [<cond, bodyCF.firstStatement>] + bodyCF.cflow + combinedFlow.cflow;
	list[int] lastStatements = [cond] + combinedFlow.rStatements;
	return controlFlow(cflow, cond, lastStatements);
}

// \switch(Expression expression, list[Statement] statements)
public CF switchCF(Statement stat){
	int expr = counting;
	statements += (expr: Statement::\expressionStatement(stat.expression));
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
	counting += 1;
	return controlFlow([], rStat, [rStat]);
}

//concatenate relation lists (recursion)
public CF concatCF (CF mainCF, list[Statement] restStatements){ 
	if(size(restStatements) == 0) return mainCF;
	else{
		CF firstCF = statementCF(restStatements[0]);
		//not an empty block or break or return
		//if(firstCF.firstStatement != -1 && firstCF.firstStatement != -2 && firstCF.firstStatement notin returnStatements){
		if(firstCF.firstStatement != -1 && firstCF.firstStatement != -2){
			int firstStatement = mainCF.firstStatement;
			CF restCF = concatCF(firstCF, tail(restStatements));
			combinedFlow = combineTwoFlows(mainCF.lastStatements, firstCF.firstStatement);
			lrel[int, int] cflow = mainCF.cflow + combinedFlow.cflow + restCF.cflow;
			lastStatements = combinedFlow.rStatements + restCF.lastStatements;
			//lrel[int, int] cflow = mainCF.cflow + [<l, firstCF.firstStatement> | l <- mainCF.lastStatements] + restCF.cflow;
			return controlFlow(cflow, firstStatement, lastStatements);
		}
		//if the following statement is an empty block, then ignore it
		if(firstCF.firstStatement == -1 && size(restStatements) > 1) return concatCF (mainCF, tail(restStatements));
		//if there is only one element in the statement list and it is an empty block; or it is a break
		else return mainCF;
	}
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

private bool isCase(Statement stat){
	if(Statement::\case(_) := stat || Statement::\defaultCase() := stat) return true;
	else return false;
}

private bool isBreak(Statement stat){
	if(Statement::\break(_) := stat || Statement::\break() := stat) return true;
	else return false;
}

private bool isReturn(Statement stat){
	if(Statement::\return(_) := stat || Statement::\return() := stat) return true;
	else return false;
}