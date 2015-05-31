module graph::TransferEnvironment

import Prelude;
import lang::java::m3::AST;

import graph::DataStructures;
import graph::JumpEnvironment;
import graph::NodeEnvironment;
import graph::control::flow::CFConnector;


// Maps a parameter node to its call-site node.
private map[int, int] transferNodes = ();

public void initializeTransferEnvironment() {
	transferNodes = ();
}

public map[int, int] getTransferNodes() {
	return transferNodes;
}

public list[ControlFlow] createParameterNodes(list[Declaration] parameters, str methodName) {
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
		transferNodes[identifier] = ENTRYNODE;
		parameterAssignments += ControlFlow({}, identifier, {identifier});
		
		parameterNumber += 1;
	}
	
	return parameterAssignments;
}

public ControlFlow createResultNode(ControlFlow returnFlow, str methodName, Expression expression) {
	Statement resultOut = \expressionStatement(\variable("$<methodName>_result", 0, expression));
	resultOut@src = expression@src;
	
	int identifier = storeNode(resultOut, nodeType = Parameter());
	ControlFlow resultFlow = ControlFlow({}, identifier, {});
	transferNodes[identifier] = returnFlow.entryNode;
	
	addReturnNode(identifier);
	
	return resultFlow;
}

public ControlFlow addReturnNodes(ControlFlow controlFlow, str methodName, loc sourceLocation) {	
	Statement returnOut = \expressionStatement(
			\variable(
				"$<methodName>_return", 
				0, 
				\simpleName("$<methodName>_result")
			)
		);
	returnOut@src = sourceLocation;
	
	int identifier = storeNode(returnOut, nodeType = Parameter());
	transferNodes[identifier] = ENTRYNODE;
	
	controlFlow.graph += { <returnNode, identifier> | returnNode <- getReturnNodes() };
	controlFlow.exitNodes += { identifier };
	
	return controlFlow;
}

public ControlFlow addArgumentNodes(ControlFlow controlFlow, str calledMethod, list[Expression] arguments) {
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
		transferNodes[identifier] = controlFlow.entryNode;
		
		argumentAssignments += ControlFlow({}, identifier, {identifier});
		argumentNumber += 1;
	}
	
	return connectControlFlows([ controlFlow ] + argumentAssignments);
}

public ControlFlow addReturnOutNode(ControlFlow controlFlow, str calledMethod, node returnType, loc sourceLocation) {
	if("<returnType>" == "void()") {
		return controlFlow;
	}
	
	Statement returnValue = \expressionStatement(
			\variable(
				"$method_<calledMethod>_return_<sourceLocation.offset>", 
				0, 
				\simpleName("$<calledMethod>_return")
			)
		);
	returnValue@src = sourceLocation;
	
	int identifier = storeNode(returnValue, nodeType = Parameter());
	transferNodes[identifier] = controlFlow.entryNode;
	
	return connectControlFlows([ controlFlow, ControlFlow({}, identifier, {identifier}) ]);
}