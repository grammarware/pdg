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
private int counting;

public CF getControlFlow(Statement stat){
	counting = 0;
	return statementCF(stat);
}

public map[int number, Statement stat] getStatements(){
	return statements;
}

//analyze each statement
private CF statementCF(Statement stat){
	switch(stat){
		case \block(_): return blockCF(stat.statements);
		case \if(_,_): return ifCF(stat);
		case \if(_,_,_): return ifCF(stat);
		case \for(_,_,_): return forCF(stat);
		case \for(_,_,_,_): return forCF(stat);
		case \while(_, _): return whileCF(stat);
		//default: {
		//	visit(stat){
		//		case \variable(str name, int extraDimensions): {
		//			environment.currentEnv += (name: stat);
		//		}
		//		case \variable(str name, int extraDimensions, Expression \initializer): {
		//			environment.currentEnv += (name: stat);
		//		}
		//		case \simpleName(str name): {
		//			statS = getStatFromEnv(name, environment);
		//			if(Statement::\empty() != statS) {
		//		 		dflow += <statS, stat, name>;
		//		 	} 	
		//		 }
		//		 case \assignment(\simpleName(str name), _ , _): {
		//			environment = updateEnv(name, environment, stat);
		//		}
		//		case \postfix(\simpleName(str name), _ ): {
		//			environment = updateEnv(name, environment, stat);
		//			println(environment);
		//		}
		//	}
		//	return <controlFlow(cflow, first, last), dataFlow(dflow, environment)>;
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
	if(Statement::\if(_,_,_) := stat){
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
	cflow += catenate(forBodyCF.lastStatements, updaters[0]) + toLRel(updaters) + <last(updaters), loopStart>;
	return controlFlow(cflow, firstStatement, lastStatements);
}


// \while(Expression condition, Statement body)
public CF whileCF(Statement stat){
	int cond = counting;
	statements += (cond: Statement::\expressionStatement(stat.condition));
	counting += 1;
	CF bodyCF = statementCF(stat.body);
	lrel[int, int] cflow = [<cond, bodyCF.firstStatement>] + bodyCF.cflow + catenate(bodyCF.lastStatements, cond);
	return controlFlow(cflow, cond, [cond]);
}

//concatenate relation lists (recursion)
public CF concatCF (CF mainCF, list[Statement] restStatements){ 
	if(size(restStatements) == 0) return mainCF;
	else{
		CF firstCF = statementCF(restStatements[0]);
		if(firstCF.firstStatement != -1){
			int firstStatement = mainCF.firstStatement;
			CF restCF = concatCF(firstCF, tail(restStatements));
			list[int] lastStatements = restCF.lastStatements;
			lrel[int, int] cflow = mainCF.cflow + [<l, firstCF.firstStatement> | l <- mainCF.lastStatements] + restCF.cflow;
			return controlFlow(cflow, firstStatement, lastStatements);
		}
		//if the following statement is an empty block, then ignore it
		elseif(firstCF.firstStatement == -1 && size(restStatements) > 1) return concatCF (mainCF, tail(restStatements));
		//if there is only one element in the statement list and it is an empty block
		else return mainCF;
	}
}

//private Statement getStatFromEnv(str name, Environment env){
//	if(name in env.currentEnv){
//		return env.currentEnv[name];
//	}else if(\env(_,_) := env){
//		return getStatFromEnv(name, env.parentEnv);
//	}else{
//		return Statement::\empty();
//	}
//}


//private Environment updateEnv(str name, Environment env, Statement stat){
//	if(name in env.currentEnv)
//		// if on this level, update
//		env.currentEnv[name] = stat;
//	elseif(\env(_,_):=env)
//		// we need to go deeper
//		env.parentEnv = updateEnv(name, env.parentEnv, stat);
//	else
//		// if not found, introduce it
//		// NB: this should not happen
//		env.currentEnv[name] = stat;
//	return env;
//}


