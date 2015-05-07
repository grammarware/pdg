module graph::control::flow::CFG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;
import graph::control::flow::CFConnector;
import graph::control::flow::JumpEnvironment;
import graph::control::flow::NodeEnvironment;

// The set of all the methods that are called by the currently
// analysed method.
private set[loc] calledMethods = {};

// Maps a parameter node to its call-site node.
private map[int, int] parameterNodes = ();

private str methodName = "";

alias GeneratedData = tuple[MethodData methodData, ControlFlow controlFlow];

private ControlFlow addReturnNodes(ControlFlow controlFlow, loc sourceLocation) {	
	Statement returnOut = \expressionStatement(\variable("$<methodName>_return", 0, \simpleName("$<methodName>_result")));
	returnOut@src = sourceLocation;
	
	int identifier = storeNode(returnOut, nodeType = Parameter());
	parameterNodes[identifier] = ENTRYNODE;
	
	controlFlow.graph += { <returnNode, identifier> | returnNode <- getReturnNodes() };
	controlFlow.exitNodes += { identifier };
	
	return controlFlow;
}
private list[ControlFlow] createParameterNodes(list[Declaration] parameters) {
	list[ControlFlow] parameterAssignments = [];
	
	if(isEmpty(parameters)) {
		return parameterAssignments;
	}
	
	int parameterNumber = 0;
	Statement parameterIn;
	
	for(parameter <- parameters) {
		parameterIn = \expressionStatement(\variable(parameter.name, 0, \simpleName("$method_<methodName>_in_<parameterNumber>")));
		parameterIn@src = parameter@src;
		
		int identifier = storeNode(parameterIn, nodeType = Parameter());
		parameterNodes[identifier] = ENTRYNODE;
		parameterAssignments += ControlFlow({}, identifier, {identifier});
		
		parameterNumber += 1;
	}
	
	return parameterAssignments;
}

public GeneratedData createCFG(methodNode: Declaration::\method(\return, name, parameters, exceptions, impl)) {
	calledMethods = {};
	parameterNodes = ();
	
	methodName = name;
	
	list[ControlFlow] parameterFlows = createParameterNodes(parameters);
	
	ControlFlow controlFlow = connectControlFlows(parameterFlows + [ process(impl) ]);
	
	if(\return != Type::\void()) {
		controlFlow = addReturnNodes(controlFlow, methodNode@src);	
	} else {
		controlFlow.exitNodes += getReturnNodes();
	}
	
	controlFlow.exitNodes += getThrowNodes();
	
	MethodData methodData = emptyMethodData();
	methodData.nodeEnvironment = getNodeEnvironment();
	methodData.parameterNodes = parameterNodes;
	methodData.calledMethods = calledMethods;
	methodData.name = name;
	
	resetJumps();
	
	return <methodData, controlFlow>;
}

private ControlFlow addArgumentNodes(ControlFlow controlFlow, str calledMethod, list[Expression] arguments) {
	if(isEmpty(arguments)) {
		return controlFlow;
	}
	
	list[ControlFlow] argumentAssignments = [];
	int argumentNumber = 0;
	Statement argumentIn;
	
	for(argument <- arguments) {
		argumentIn = \expressionStatement(\variable("$method_<calledMethod>_in_<argumentNumber>", 0, argument));
		argumentIn@src = argument@src;
		
		int identifier = storeNode(argumentIn, nodeType = Parameter());
		parameterNodes[identifier] = controlFlow.entryNode;
		
		argumentAssignments += ControlFlow({}, identifier, {identifier});
		argumentNumber += 1;
	}
	
	return connectControlFlows([ controlFlow ] + argumentAssignments);
}

private ControlFlow addReturnOutNode(ControlFlow controlFlow, str calledMethod, node returnType, loc sourceLocation) {
	if("<returnType>" == "void()") {
		return controlFlow;
	}
	
	Statement returnValue = \expressionStatement(\variable("$method_<calledMethod>_return", 0, \simpleName("$<calledMethod>_return")));
	returnValue@src = sourceLocation;
	
	int identifier = storeNode(returnValue, nodeType = Parameter());
	parameterNodes[identifier] = controlFlow.entryNode;
	
	return connectControlFlows([ controlFlow, ControlFlow({}, identifier, {identifier}) ]);
}

private list[ControlFlow] registerMethodCalls(Expression expression) {
	list[ControlFlow] callsites = [];
	ControlFlow callsite;
	
	int identifier;
	
	visit(expression) {
		case callNode: \methodCall(isSuper, name, arguments): {
			identifier = storeNode(callNode, nodeType = CallSite());
			calledMethods += callNode@decl;
			
			callsite = ControlFlow({}, identifier, {identifier});
			callsite = addArgumentNodes(callsite, name, arguments);
			callsite = addReturnOutNode(callsite, name, callNode@typ, callNode@decl);
			
			callsites += callsite;
		}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		identifier = storeNode(callNode, nodeType = CallSite());
			calledMethods += callNode@decl;
			
			callsites += ControlFlow({}, identifier, {identifier});
    	}
	}
	
	return callsites;
}

private ControlFlow process(blockNode: \block(body)) {	
	return connectControlFlows([ process(statement) | statement <- body ]);
}

private ControlFlow process(ifNode: \if(condition, thenBranch)) {
	int identifier = storeNode(ifNode);
	ControlFlow ifFlow = ControlFlow({}, 0, {});
	
	ifFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifFlow.exitNodes += {identifier};
	
	ControlFlow thenFlow = process(thenBranch);
	
	ifFlow.graph += thenFlow.graph + createConnectionEdges(ifFlow, thenFlow);
	ifFlow.exitNodes += thenFlow.exitNodes;
	
	return ifFlow;
}

private ControlFlow process(ifNode: \if(condition, thenBranch, elseBranch)) {
	int identifier = storeNode(ifNode);
	ControlFlow ifElseFlow = ControlFlow({}, 0, {});
	
	ifElseFlow.entryNode = identifier;
	// The condition is an exit node on false.
	ifElseFlow.exitNodes += {identifier};
	
	ControlFlow thenFlow = process(thenBranch);	
	ifElseFlow.graph += thenFlow.graph + createConnectionEdges(ifElseFlow, thenFlow);
	
	ControlFlow elseFlow = process(elseBranch);	
	ifElseFlow.graph += elseFlow.graph + createConnectionEdges(ifElseFlow, elseFlow);
	
	ifElseFlow.exitNodes += elseFlow.exitNodes + thenFlow.exitNodes;
	ifElseFlow.exitNodes -= {identifier};
	
	return ifElseFlow;
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

private ControlFlow process(forNode: \for(initializers, updaters, body)) {
	int identifier = storeNode(forNode);
	
	return createForFlow(identifier, body);
}

private ControlFlow process(forNode: \for(initializers, condition, updaters, body)) {
	int identifier = storeNode(forNode);
	
	return createForFlow(identifier, body);
}

private ControlFlow process(whileNode: \while(condition, body)) {
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
	
	return whileFlow;
}

private ControlFlow process(doNode: \do(body, condition)) {
	int identifier = storeNode(doNode);
	ControlFlow doWhileFlow = ControlFlow({}, 0, {});
	
	scopeDown();
	
	// Process the body first, as it is always executed once.
	ControlFlow bodyFlow = process(body);
	bodyFlow.exitNodes += getContinueNodes();
	
	doWhileFlow.entryNode = identifier;
	doWhileFlow.exitNodes += {identifier};
	
	doWhileFlow.graph += bodyFlow.graph;
	doWhileFlow.graph += createConnectionEdges(bodyFlow, doWhileFlow);
	
	doWhileFlow.entryNode = bodyFlow.entryNode;
	doWhileFlow.graph += createConnectionEdges(doWhileFlow, bodyFlow);
	
	doWhileFlow.exitNodes += getBreakNodes();
	
	scopeUp();
	
	return doWhileFlow;
}

private list[ControlFlow] processCases(list[Statement] statements) {
	ControlFlow caseFlow = ControlFlow({}, 0, {});
	
	tuple[node popped, list[node] remainder] popTuple = pop(statements);
	ControlFlow caseNode = process(popTuple.popped);
	statements = popTuple.remainder;
	
	caseFlow.entryNode = caseNode.entryNode;
	caseFlow.exitNodes = caseNode.exitNodes;
	
	bool isNotDefault(Statement treeNode) = !(\defaultCase() := treeNode);
	bool isNotCase(Statement treeNode) = (!(\case(_) := treeNode) && isNotDefault(treeNode));
	
	list[Statement] caseBody = [ cast(#Statement, statement) | statement <- takeWhile(statements, isNotCase) ];
	
	ControlFlow caseBodyFlow = process(\block(caseBody));
	statements -= caseBody;
	
	caseFlow.graph = caseBodyFlow.graph + createConnectionEdges(caseFlow, caseBodyFlow);
	caseFlow.exitNodes = caseBodyFlow.exitNodes;
	
	list[ControlFlow] caseFlows = [caseFlow];
	
	if(size(statements) >= 1) {
		caseFlows += processCases(statements); 
	}
	
	return caseFlows;
}

private ControlFlow process(switchNode: \switch(expression, statements)) {
	int identifier = storeNode(switchNode);
	ControlFlow switchFlow = ControlFlow({}, 0, {});
	
	switchFlow.entryNode = identifier;
	switchFlow.exitNodes = {identifier};
	
	list[ControlFlow] caseFlows = processCases(statements);
	set[int] finalExitNodes = {};
	
	for(caseFlow <- caseFlows) {
		switchFlow.graph += caseFlow.graph + createConnectionEdges(switchFlow, caseFlow);
		switchFlow.exitNodes += caseFlow.exitNodes;
		
		// Previous loop's exit nodes are now bound. Remove them.
		switchFlow.exitNodes -= finalExitNodes;
		
		finalExitNodes = caseFlow.exitNodes;
	}
	
	switchFlow.exitNodes = finalExitNodes + getBreakNodes();
	
	return switchFlow;
}

private ControlFlow createTryFlow(int identifier, Statement body, list[Statement] catchClauses) {
	ControlFlow tryFlow = ControlFlow({}, 0, {});
	
	tryFlow.entryNode = identifier;
	tryFlow.exitNodes = { identifier };
	
	scopeDown();
	
	ControlFlow bodyFlow = process(body);
	tryFlow.graph = bodyFlow.graph + createConnectionEdges(tryFlow, bodyFlow);
	tryFlow.exitNodes = bodyFlow.exitNodes;

	set[int] throwNodes = getThrowNodes();
	set[int] potentialThrows = throwNodes 
							 + { treeNode | treeNode <- carrier(tryFlow.graph), 
							 	 			isPotentialThrow(resolveNode(treeNode)) };

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
	
	tryFlow.graph += createConnectionEdges(tryFlow, finalFlow);
	tryFlow.exitNodes = finalFlow.exitNodes;	
	
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
	int identifier = storeNode(breakNode);
	addBreakNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(continueNode: \continue()) {
	int identifier = storeNode(continueNode);
	addContinueNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(continueNode: \continue(expression)) {
	int identifier = storeNode(continueNode);
	addContinueNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(returnNode: \return()) {
	int identifier = storeNode(returnNode);
	addReturnNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(returnNode: \return(expression)) {
	list[ControlFlow] callSites = registerMethodCalls(expression);
	int identifier = storeNode(returnNode);
	
	ControlFlow returnFlow = ControlFlow({}, 0, {});
	returnFlow.entryNode = identifier;
	returnFlow.exitNodes = {identifier};
			
	Statement resultOut = \expressionStatement(\variable("$<methodName>_result", 0, expression));
	resultOut@src = expression@src;
	
	identifier = storeNode(resultOut, nodeType = Parameter());
	ControlFlow resultFlow = ControlFlow({}, identifier, {});
	parameterNodes[identifier] = returnFlow.entryNode;
	
	addReturnNode(identifier);
	
	return connectControlFlows(callSites + [returnFlow, resultFlow]);
}

private ControlFlow process(throwNode: \throw(expression)) {
	int identifier = storeNode(throwNode);
	addThrowNode(identifier);
	
	return ControlFlow({}, identifier, {});
}

private ControlFlow process(statementNode: \expressionStatement(statement)) {
	list[ControlFlow] callsites = registerMethodCalls(statement);
			
	if(isMethodCall(statement)) {
		return connectControlFlows(callsites);
	}
	
	int identifier = storeNode(statementNode);
	return connectControlFlows(callsites + ControlFlow({}, identifier, {identifier}));
}

private ControlFlow process(Statement statement) {
	int identifier = storeNode(statement);
	
	return ControlFlow({}, identifier, {identifier});
}