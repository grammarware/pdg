module graph::control::flow::MethodNodes

import Prelude;
import lang::java::m3::AST;

import graph::DataStructures;
import graph::control::flow::CFConnector;
import graph::control::flow::TransferNodes;
import graph::control::flow::NodeEnvironment;

// The set of all the methods that are called by the currently
// analysed method.
private set[loc] calledMethods = {};

public set[loc] getCalledMethods() {
	set[loc] returnedCalls = calledMethods;
	
	calledMethods = {};
	
	return returnedCalls;
}

public list[ControlFlow] registerMethodCalls(Expression expression) {
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
			
			callsite = ControlFlow({}, identifier, {identifier});
			callsite = addArgumentNodes(callsite, name, arguments);
			callsite = addReturnOutNode(callsite, name, callNode@typ, callNode@decl);
			
			callsites += callsite;
    	}
	}
	
	return callsites;
}