module graph::CallEnvironment

import Prelude;
import lang::java::m3::AST;
import analysis::m3::Registry;

import graph::DataStructures;
import graph::NodeEnvironment;
import graph::JumpEnvironment;
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

private ControlFlow createCallSiteFlow(Expression callNode, NodeType nType = CallSite()) {
	int identifier = storeNode(callNode, nodeType = nType);
	ControlFlow callsite = ControlFlow({}, identifier, {identifier});
	
	// See if the called method is part of the project.
	try {
		loc resolved = resolveM3(callNode@decl);
	
		callSites += {identifier};
		calledMethods += callNode@decl;
		callsite = addArgumentNodes(callsite, "<callNode.name>:<resolved.offset>", callNode.arguments);
		callsite = addReturnOutNode(callsite, "<callNode.name>:<resolved.offset>", callNode@typ, callNode@src, resolved);
	}
	// It is not part of the project. Handle it differently.
	catch: {
		callsite = addArgumentNodes(callsite, callNode.name, callNode.arguments);
		callsite = addReturnOutNode(callsite, callNode.name, callNode@typ, callNode@src);
	}
	
	return callsite;
}

public list[ControlFlow] registerMethodCalls(node expression) {
	list[ControlFlow] callsites = [];
	
	top-down visit(expression) {
		// A nested class is out of scope, so don't process any further.
		case \class(_): {
			return callsites;
		}
		case callNode: \methodCall(isSuper, name, arguments): {
			callsites += 
				callNode == expression
				? createCallSiteFlow(callNode, nType = Normal()) 
				: createCallSiteFlow(callNode);
		}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		callsites += 
				callNode == expression
				? createCallSiteFlow(callNode, nType = Normal()) 
				: createCallSiteFlow(callNode);
    	}
	}
	
	return callsites;
}