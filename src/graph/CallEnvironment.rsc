module graph::CallEnvironment

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;

import graph::DataStructures;
import graph::NodeEnvironment;
import graph::TransferEnvironment;
import graph::control::flow::CFConnector;

// The set of all the methods that are called by the currently
// analysed method.
private set[loc] calledMethods = {};
private set[int] callSites = {};

public void initializeCallEnvironment() {
	calledMethods = {};
	callSites = {};
}

public set[loc] getCalledMethods() {
	return calledMethods;
}

public set[int] getCallSites() {
	return callSites;
}

private ControlFlow createCallSiteFlow(Expression callNode) {
	int identifier = storeNode(callNode, nodeType = CallSite());
	
	calledMethods += callNode@decl;
	
	callsite = ControlFlow({}, identifier, {identifier});
	callsite = addArgumentNodes(callsite, callNode.name, callNode.arguments);
	
	// See if the called method is part of the project.
	try {
		loc resolved = resolveM3(callNode@decl);
	
		callSites += {identifier};
		callsite = addReturnOutNode(callsite, callNode.name, callNode@typ, callNode@src, resolved);
	}
	// It is not part of the project. Handle it differently.
	catch: {
		callsite = addReturnOutNode(callsite, callNode.name, callNode@typ, callNode@src);
	}
	
	return callsite;
}

public list[ControlFlow] registerMethodCalls(Expression expression) {
	list[ControlFlow] callsites = [];
	
	visit(expression) {
		case callNode: \methodCall(isSuper, name, arguments): {
			callsites += createCallSiteFlow(callNode);
		}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		callsites += createCallSiteFlow(callNode);
    	}
	}
	
	return callsites;
}