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

public void initializeCallEnvironment() {
	calledMethods = {};
}

public set[loc] getCalledMethods() {
	return calledMethods;
}

public list[ControlFlow] registerMethodCalls(Expression expression) {
	list[ControlFlow] callsites = [];
	ControlFlow callsite;
	
	int identifier;
	
	visit(expression) {
		case callNode: \methodCall(isSuper, name, arguments): {
			loc resolved;
			
			try resolved = resolveM3(callNode@decl);
			catch: resolved = callNode@decl;
			
			identifier = storeNode(callNode, nodeType = CallSite());
			calledMethods += callNode@decl;
			
			callsite = ControlFlow({}, identifier, {identifier});
			callsite = addArgumentNodes(callsite, name, arguments);
			callsite = addReturnOutNode(callsite, name, callNode@typ, callNode@src, resolved);
			
			callsites += callsite;
		}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		loc resolved;
			
			try resolved = resolveM3(callNode@decl);
			catch: resolved = callNode@decl;
    		
    		identifier = storeNode(callNode, nodeType = CallSite());
			calledMethods += callNode@decl;
			
			callsite = ControlFlow({}, identifier, {identifier});
			callsite = addArgumentNodes(callsite, name, arguments);
			callsite = addReturnOutNode(callsite, name, callNode@typ, callNode@src, resolved);
				
			callsites += callsite;
    	}
	}
	
	return callsites;
}