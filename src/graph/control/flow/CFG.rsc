@contributor{René Bulsing - UvA MSc 2015}
module graph::control::flow::CFG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;
import graph::JumpEnvironment;
import graph::NodeEnvironment;
import graph::CallEnvironment;
import graph::TransferEnvironment;
import graph::control::flow::CFConnector;

data GeneratedData
	= EmptyGD() 
	| GeneratedData(MethodData methodData, ControlFlow controlFlow);

private str methodName = "";

private void initializeEnvironments(M3 projectModel) {
	initializeJumpEnvironment();
	initializeNodeEnvironment();
	initializeCallEnvironment(projectModel);
	initializeTransferEnvironment();
}

private MethodData createMethodData(node abstractTree) {
	MethodData methodData = emptyMethodData();
	
	methodData.nodeEnvironment = getNodeEnvironment();
	
	Statement entryNode = Statement::empty();
	entryNode@nodeType = Entry();
	entryNode@src = abstractTree@src(0,0,<0,0>,<0,0>);
	methodData.nodeEnvironment[ENTRYNODE] = entryNode;
	
	methodData.parameterNodes = getTransferNodes();
	methodData.calledMethods = getCalledMethods();
	methodData.callSites = getCallSites();
	methodData.name = methodName;
	methodData.abstractTree = abstractTree;
	
	return methodData;
}

public GeneratedData createCFG(M3 projectModel, methodNode: Declaration::\constructor(name, parameters, exceptions, impl)) {
	methodName = methodNode@decl.file;
	
	initializeEnvironments(projectModel);
	
	list[ControlFlow] parameterFlows = createParameterNodes(parameters, methodName);
	ControlFlow controlFlow;
	
	if(isEmpty(parameterFlows)) {
		controlFlow = process(impl);
	} else {
		controlFlow = connectControlFlows(parameterFlows + [ process(impl) ]);
	}
	
	if(controlFlow == EmptyCF()) {
		return EmptyGD();
	}
	
	controlFlow.exitNodes += getThrowNodes();
	
	MethodData methodData = createMethodData(methodNode);
	
	return GeneratedData(methodData, controlFlow);
}

public GeneratedData createCFG(M3 projectModel, methodNode: Declaration::\method(\return, name, parameters, exceptions, impl)) {
	methodName = methodNode@decl.file;
	
	initializeEnvironments(projectModel);
	
	list[ControlFlow] parameterFlows = createParameterNodes(parameters, methodName);
	ControlFlow controlFlow;
	
	if(isEmpty(parameterFlows)) {
		controlFlow = process(impl);
	} else {
		controlFlow = connectControlFlows(parameterFlows + [ process(impl) ]);
	}
	
	if(\return != Type::\void()) {
		controlFlow = addReturnNodes(controlFlow, methodName, methodNode@src);	
	} else {
		controlFlow.exitNodes += getReturnNodes();
	}
	
	controlFlow.exitNodes += getThrowNodes();
	
	MethodData methodData = createMethodData(methodNode);
	
	return GeneratedData(methodData, controlFlow);
}

default GeneratedData createCFG(M3 projectModel, node tree) {
	return EmptyGD();
}

private ControlFlow process(blockNode: \block(body)) {	
	return connectControlFlows([ process(statement) | statement <- body ]);
}

private ControlFlow process(ifNode: \if(condition, thenBranch)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(condition));
	int identifier = storeNode(ifNode);

	ControlFlow ifFlow = ControlFlow({}, 0, {});
	ifFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifFlow.exitNodes += {identifier};
	
	ControlFlow thenFlow = process(thenBranch);
	
	if(thenFlow != EmptyCF()) {
		ifFlow.graph += thenFlow.graph + createConnectionEdges(ifFlow, thenFlow);
		ifFlow.exitNodes += thenFlow.exitNodes;
	}
	
	return connectControlFlows(callSites + ifFlow);
}

private ControlFlow process(ifNode: \if(condition, thenBranch, elseBranch)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(condition));
	int identifier = storeNode(ifNode);
	
	ControlFlow ifElseFlow = ControlFlow({}, 0, {});
	ifElseFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifElseFlow.exitNodes += {identifier};
	
	set[int] addedExitNodes = {};
	
	ControlFlow thenFlow = process(thenBranch);
	bool hasIfBranch = false;
	
	if(thenFlow != EmptyCF()) {
		ifElseFlow.graph += thenFlow.graph + createConnectionEdges(ifElseFlow, thenFlow);
		addedExitNodes += thenFlow.exitNodes;
		
		hasIfBranch = true;
	}
	
	ControlFlow elseFlow = process(elseBranch);	
	bool hasElseBranch = false;
	
	if(elseFlow != EmptyCF()) {
		ifElseFlow.graph += elseFlow.graph + createConnectionEdges(ifElseFlow, elseFlow);
		addedExitNodes += elseFlow.exitNodes;
		
		hasElseBranch = true;
	}
	
	ifElseFlow.exitNodes += addedExitNodes;
	
	if(hasIfBranch && hasElseBranch) {
		ifElseFlow.exitNodes -= {identifier};
	}
	
	return connectControlFlows(callSites + ifElseFlow);
}

private ControlFlow createForFlow(int identifier, Statement body) {
	ControlFlow forFlow = ControlFlow({}, 0, {});
	
	forFlow.entryNode = identifier;
	forFlow.exitNodes += {identifier};
	
	scopeDown();
	
	ControlFlow bodyFlow = process(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	forFlow.graph += bodyFlow.graph;
	forFlow.graph += createConnectionEdges(forFlow, bodyFlow);
	forFlow.graph += createConnectionEdges(bodyFlow, forFlow);
		
	forFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return forFlow;
}

private ControlFlow process(forEachNode: \foreach(parameter, collection, body)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(collection));
	int identifier = storeNode(forEachNode);
	
	return connectControlFlows(callSites + createForFlow(identifier, body));
}

private ControlFlow process(forNode: \for(initializers, updaters, body)) {
	int identifier = storeNode(forNode);
	
	return createForFlow(identifier, body);
}

private ControlFlow process(forNode: \for(initializers, condition, updaters, body)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(condition));
	int identifier = storeNode(forNode);
	
	return connectControlFlows(callSites + createForFlow(identifier, body));
}

private ControlFlow process(whileNode: \while(condition, body)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(condition));
	int identifier = storeNode(whileNode);
	
	ControlFlow whileFlow = ControlFlow({}, 0, {});
	whileFlow.entryNode = identifier;
	whileFlow.exitNodes += {identifier};
	
	scopeDown();
	
	ControlFlow bodyFlow = process(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	whileFlow.graph += bodyFlow.graph;
	whileFlow.graph += createConnectionEdges(bodyFlow, whileFlow);
	whileFlow.graph += createConnectionEdges(whileFlow, bodyFlow);
	
	whileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return connectControlFlows(callSites + whileFlow);
}

private ControlFlow process(doNode: \do(body, condition)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(condition));
	int identifier = storeNode(doNode);
	
	ControlFlow doWhileFlow = ControlFlow({}, 0, {});
	doWhileFlow.entryNode = identifier;
	doWhileFlow.exitNodes += {identifier};
	
	scopeDown();
	
	// Process the body first, as it is always executed once.
	ControlFlow bodyFlow = process(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	doWhileFlow.graph += bodyFlow.graph;
	doWhileFlow.graph += createConnectionEdges(bodyFlow, doWhileFlow);
	
	doWhileFlow.entryNode = bodyFlow.entryNode;
	doWhileFlow.graph += createConnectionEdges(doWhileFlow, bodyFlow);
	
	doWhileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return connectControlFlows(callSites + doWhileFlow);
}

private list[ControlFlow] processCases(list[Statement] statements) {
	ControlFlow caseFlow = ControlFlow({}, 0, {});
	
	tuple[node popped, list[node] remainder] popTuple = pop(statements);
	ControlFlow caseNode = process(popTuple.popped);
	statements = popTuple.remainder;
	
	caseFlow.entryNode = caseNode.entryNode;
	caseFlow.exitNodes = caseNode.exitNodes;
	
	bool isNotCase(Statement treeNode) = !isCase(treeNode) && !isDefaultCase(treeNode);
	
	list[Statement] caseBody = [ cast(#Statement, statement) | statement <- takeWhile(statements, isNotCase) ];
	
	ControlFlow caseBodyFlow = process(\block(caseBody));
	statements -= caseBody;
	
	if(caseBodyFlow != EmptyCF()) {
		caseFlow.graph = caseBodyFlow.graph + createConnectionEdges(caseFlow, caseBodyFlow);
		caseFlow.exitNodes = caseBodyFlow.exitNodes;
	}
	
	list[ControlFlow] caseFlows = [caseFlow];
	
	if(size(statements) >= 1) {
		caseFlows += processCases(statements); 
	}
	
	return caseFlows;
}

private ControlFlow process(switchNode: \switch(expression, statements)) {
	list[ControlFlow] callSites = registerMethodCalls(\expressionStatement(expression));
	int identifier = storeNode(switchNode);
	
	ControlFlow switchFlow = ControlFlow({}, 0, {});
	
	switchFlow.entryNode = identifier;
	switchFlow.exitNodes = {identifier};
	
	list[ControlFlow] caseFlows = processCases(statements);
	set[int] finalExitNodes = {};
	bool hasDefaultCase = false;
	
	for(caseFlow <- caseFlows) {
		if(isDefaultCase(resolveNode(caseFlow.entryNode))) {
			hasDefaultCase = true;
		}
		
		switchFlow.graph += caseFlow.graph + createConnectionEdges(switchFlow, caseFlow);
		switchFlow.exitNodes += caseFlow.exitNodes;
		
		// Previous loop's exit nodes are now bound. Remove them.
		switchFlow.exitNodes -= finalExitNodes;
		
		finalExitNodes = caseFlow.exitNodes;
	}
	
	switchFlow.exitNodes = hasDefaultCase 
		? finalExitNodes + getBreakNodes()
		: { identifier } + finalExitNodes + getBreakNodes();
	
	return connectControlFlows(callSites + switchFlow);
}

private ControlFlow createTryFlow(int identifier, Statement body, list[Statement] catchClauses) {
	ControlFlow tryFlow = ControlFlow({}, 0, {});
	
	tryFlow.entryNode = identifier;
	tryFlow.exitNodes = { identifier };
	
	scopeDown();
	
	ControlFlow bodyFlow = process(body);
	tryFlow.graph = bodyFlow.graph + createConnectionEdges(tryFlow, bodyFlow);
	tryFlow.exitNodes = bodyFlow.exitNodes;
	
	if(isEmpty(catchClauses)) {
		scopeUp();
		return tryFlow;
	}

	set[int] throwNodes = getThrowNodes();
	set[int] potentialThrows = throwNodes +
				{ treeNode 
					| treeNode <- carrier(tryFlow.graph)
					, isPotentialThrow(resolveNode(treeNode))
				};

	scopeUp();
	
	list[ControlFlow] catchFlows = [ process(catchClause) | catchClause <- catchClauses ];
	
	for(catchFlow <- catchFlows) {
		tryFlow.graph += potentialThrows * {catchFlow.entryNode};
		tryFlow.graph += catchFlow.graph;
		tryFlow.exitNodes += catchFlow.exitNodes;
	}
	
	return tryFlow;
}

private ControlFlow process(tryNode: \try(body, catchClauses)) {
	int identifier = storeNode(tryNode);
	
	return createTryFlow(identifier, body, catchClauses);
}

private ControlFlow process(tryNode: \try(body, catchClauses, finalClause)) {
	int identifier = storeNode(tryNode);
	
	ControlFlow tryFlow = createTryFlow(identifier, body, catchClauses);
	ControlFlow finalFlow = process(finalClause);

	set[int] bottomNodes = bottom(tryFlow.graph);
	set[int] catchExits = { exit | exit <- bottomNodes, isExitNode(resolveNode(exit)) };
	
	if(!isEmpty(catchExits)) {
		// No need to make a new one if there is only one needed.
		ControlFlow altFinalFlow = catchExits != bottomNodes ? process(finalClause) : finalFlow;
		int processed = 0;
		
		// Execute the final block before returning, throwing, breaking, or continuing.
		for(exit <- catchExits) {
			processed += 1;
			
			for(predecessor <- predecessors(tryFlow.graph, exit)) {
				tryFlow.graph -= { <predecessor, exit> };
				
				tryFlow.graph += altFinalFlow.graph;
				tryFlow.graph += { <predecessor, altFinalFlow.entryNode> };
				tryFlow.graph += { <finalExit, exit> | finalExit <- altFinalFlow.exitNodes };
			}
			
			if(processed < size(catchExits)) {
				altFinalFlow = process(finalClause);
			}			
		}
	}
	
	if(catchExits != bottomNodes) {
		tryFlow.graph += finalFlow.graph;
		tryFlow.graph += createConnectionEdges(tryFlow, finalFlow);
		tryFlow.exitNodes = finalFlow.exitNodes;
	}
	
	return tryFlow;
}

private ControlFlow process(catchNode: \catch(exception, body)) {
	int identifier = storeNode(catchNode);
	ControlFlow catchFlow = ControlFlow({}, 0, {});
	catchFlow.entryNode = identifier;
	catchFlow.exitNodes = {identifier};
	
	scopeDown();
	
	ControlFlow bodyFlow = process(body);
	
	scopeUp();
	
	if(bodyFlow == EmptyCF()) {
		return catchFlow;
	}

	catchFlow.graph = bodyFlow.graph + createConnectionEdges(catchFlow, bodyFlow);
	catchFlow.exitNodes = bodyFlow.exitNodes;
	
	return catchFlow;
}


private ControlFlow process(breakNode: \break()) {
	int identifier = storeNode(breakNode);
	addBreakNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(breakNode: \break(expression)) {
	list[ControlFlow] callSites = registerMethodCalls(breakNode);
	int identifier = storeNode(breakNode);
	
	addBreakNode(identifier);
	
	return connectControlFlows(callSites + ControlFlow({}, identifier, {}));
}

private ControlFlow process(continueNode: \continue()) {
	int identifier = storeNode(continueNode);
	addContinueNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(continueNode: \continue(expression)) {
	list[ControlFlow] callSites = registerMethodCalls(continueNode);
	int identifier = storeNode(continueNode);
	
	addContinueNode(identifier);
	
	return connectControlFlows(callSites + ControlFlow({}, identifier, {}));
}

private ControlFlow process(returnNode: \return()) {
	int identifier = storeNode(returnNode);
	addReturnNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(returnNode: \return(expression)) {
	list[ControlFlow] callSites = registerMethodCalls(returnNode);
	int identifier = storeNode(returnNode);
	
	ControlFlow returnFlow = ControlFlow({}, identifier, {identifier});
	ControlFlow resultFlow = createResultNode(returnFlow, methodName, expression);
	
	return connectControlFlows(callSites + [returnFlow, resultFlow]);
}

private ControlFlow process(throwNode: \throw(expression)) {
	int identifier = storeNode(throwNode);
	addThrowNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(statementNode: \expressionStatement(statement)) {
	list[ControlFlow] callSites = registerMethodCalls(statement);
			
	if(isMethodCall(statement) && !isEmpty(callSites)) {
		return connectControlFlows(callSites);
	}
	
	int identifier = storeNode(statementNode);
	return connectControlFlows(callSites + ControlFlow({}, identifier, {identifier}));
}

private ControlFlow process(Statement statement) {
	list[ControlFlow] callSites = registerMethodCalls(statement);
	
	int identifier = storeNode(statement);
	return connectControlFlows(callSites + ControlFlow({}, identifier, {identifier}));
}