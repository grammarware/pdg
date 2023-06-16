@contributor{René Bulsing - UvA MSc 2015}
module graph::CallEnvironment

import Prelude;
import lang::java::m3::Core;
import lang::java::m3::AST;
import analysis::m3::Registry;

import graph::DataStructures;
import graph::NodeEnvironment;
import graph::JumpEnvironment;
import graph::TransferEnvironment;
import graph::control::flow::CFConnector;


private set[loc] projectMethods;
// The set of all the methods that are called by the currently
// analysed method.
private set[loc] calledMethods;
private set[int] callSites;

public void initializeCallEnvironment(M3 projectModel) {
	projectMethods = methods(projectModel);
	calledMethods = {};
	callSites = {};
}

public set[loc] getCalledMethods()
	= calledMethods;

public set[int] getCallSites()
	= callSites;

private ControlFlow createCallSiteFlow(Expression callNode, NodeType nType = CallSite()) {
	int identifier = storeNode(callNode, nodeType = nType);
	ControlFlow callsite = ControlFlow({}, identifier, {identifier});
	
	// See if the called method is part of the project.
	if(callNode.decl in projectMethods) {
		callSites += {identifier};
		calledMethods += callNode.decl;
		callsite = addArgumentNodes(callsite, callNode.decl.file, callNode.arguments);
		callsite = addReturnOutNode(callsite, callNode.decl.file, callNode.typ, callNode.src);
	}
	// It is not part of the project. Handle it differently.
	else {
		callsite = addArgumentNodes(callsite, callNode.name, callNode.arguments);
		callsite = addReturnOutNode(callsite, callNode.name, callNode.typ, callNode.src);
	}
	
	return callsite;
}

private ControlFlow createCallSiteFlow(Statement callNode, NodeType nType = CallSite()) {
	int identifier = storeNode(callNode, nodeType = nType);
	ControlFlow callsite = ControlFlow({}, identifier, {identifier});
	
	// See if the called method is part of the project.
	if(callNode.decl in projectMethods) {
		callSites += {identifier};
		calledMethods += callNode.decl;
		callsite = addArgumentNodes(callsite, callNode.decl.file, callNode.arguments);
	}
	// It is not part of the project. Handle it differently.
	else {
		callsite = addArgumentNodes(callsite, callNode.decl.file, callNode.arguments);
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
    	case callNode: \constructorCall(isSuper, arguments): {
    		callsites += 
				callNode == expression
				? createCallSiteFlow(callNode, nType = Normal()) 
				: createCallSiteFlow(callNode);
    	}
    	case callNode: \constructorCall(isSuper, expr, arguments): {
    		callsites += 
				callNode == expression
				? createCallSiteFlow(callNode, nType = Normal()) 
				: createCallSiteFlow(callNode);
    	}
	}
	
	return callsites;
}