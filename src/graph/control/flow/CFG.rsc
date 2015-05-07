module graph::control::flow::CFG

import Prelude;
import analysis::m3::AST;
import analysis::graphs::Graph;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import graph::DataStructures;
import graph::control::flow::JumpEnvironment;
import graph::control::flow::CFConnector;
import graph::control::flow::NodeUtility;

// A counter to identify nodes.
private int nodeIdentifier = 0;

// The set of all the methods that are called by the currently
// analysed method.
private set[loc] calledMethods = {};

// Storage for all the visited nodes with their identifier as key.
private map[int, node] nodeEnvironment = ();

// Maps a parameter node to its call-site node.
private map[int, int] parameterNodes = ();

private str methodName = "";

private int getIdentifier() {
	int identifier = nodeIdentifier;
	
	nodeIdentifier += 1;
	
	return identifier;
}

private int storeNode(node treeNode, NodeType nodeType = Normal()) {
	int identifier = getIdentifier();

	treeNode@nodeType = nodeType;
	nodeEnvironment[identifier] = treeNode;
	
	return identifier;
}

public MethodData createCFG(MethodData methodData) {
	calledMethods = {};
	nodeEnvironment = ();
	parameterNodes = ();
	nodeIdentifier = 0;
	
	methodName = methodData.name;
	
	list[ControlFlow] parameterAssignments = [];
	int parameterNumber = 0;
	
	ControlFlow controlFlow;
	
	if(\method(_, name, parameters, _, impl) := methodData.abstractTree) {
		for(parameter <- parameters) {
			Statement parameterIn = \expressionStatement(\variable(parameter.name, 0, \simpleName("$method_<name>_in_<parameterNumber>")));
			parameterIn@src = parameter@src;
			
			identifier = storeNode(parameterIn, nodeType = Parameter());
			parameterNodes[identifier] = ENTRYNODE;
			parameterAssignments += ControlFlow({}, identifier, {identifier});
			
			parameterNumber += 1;
		}
		
		controlFlow = process(impl);
	}
	
	if(Declaration decl := methodData.abstractTree) {
		if(decl.\return != Type::\void()) {
			set[int] returnNodes = getReturnNodes();
			
			Statement returnOut = \expressionStatement(\variable("$<decl.name>_return", 0, \simpleName("$<decl.name>_result")));
			returnOut@src = decl@src;
			
			identifier = storeNode(returnOut, nodeType = Parameter());
			parameterNodes[identifier] = ENTRYNODE;
			
			controlFlow.graph += { <returnNode, identifier> | returnNode <- returnNodes };
			controlFlow.exitNodes += { identifier };			
		} else {
			controlFlow.exitNodes += getReturnNodes();
		}
	}
	
	controlFlow.exitNodes += getThrowNodes();
	
	methodData.calledMethods = calledMethods;
	methodData.nodeEnvironment = nodeEnvironment;
	methodData.parameterNodes = parameterNodes;
	methodData.controlFlow = controlFlow;

	if(!isEmpty(parameterAssignments)) {
		methodData.controlFlow = connectControlFlows(parameterAssignments + controlFlow);
	}
	
	resetJumps();
	
	return methodData;
}

private list[ControlFlow] registerMethodCalls(Expression expression) {
	list[ControlFlow] callsites = [];
	ControlFlow callsite;
	
	int identifier;
	
	visit(expression) {
		case callNode: \methodCall(isSuper, name, arguments): {
			identifier = storeNode(callNode, nodeType = CallSite());

			callsite = ControlFlow({}, identifier, {identifier});
			
			calledMethods += callNode@decl;
			
			list[ControlFlow] argumentAssignments = [];
			int argumentNumber = 0;
			
			for(argument <- arguments) {
				Statement argumentIn = \expressionStatement(\variable("$method_<name>_in_<argumentNumber>", 0, argument));
				argumentIn@src = argument@src;
				
				identifier = storeNode(argumentIn, nodeType = Parameter());
				parameterNodes[identifier] = callsite.entryNode;
				argumentAssignments += ControlFlow({}, identifier, {identifier});
				
				argumentNumber += 1;
			}
			
			if("<callNode@typ>" != "void()") {
				Statement returnValue = \expressionStatement(\variable("$method_<name>_return", 0, \simpleName("$<name>_return")));
				returnValue@src = callNode@decl;
				
				identifier = storeNode(returnValue, nodeType = Parameter());
				parameterNodes[identifier] = callsite.entryNode;
				argumentAssignments += ControlFlow({}, identifier, {identifier});
			}
			
			ControlFlow argumentAssignment;
			if(!isEmpty(argumentAssignments)) {
				callsite = connectControlFlows([ callsite ] + argumentAssignments);
			}
			
			callsites += callsite;
		}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		identifier = storeNode(callNode, nodeType = CallSite());
			
			callsites += ControlFlow({}, identifier, {identifier});
			calledMethods += callNode@decl;
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
							 	 			isPotentialThrow(nodeEnvironment[treeNode]) };

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