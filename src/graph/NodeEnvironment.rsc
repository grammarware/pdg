module graph::NodeEnvironment

import Prelude;
import lang::java::m3::AST;

import graph::DataStructures;

// Storage for all the visited nodes with their identifier as key.
private map[int, node] nodeEnvironment = ();

// A counter to identify nodes.
private int nodeIdentifier = 0;

public void initializeNodeEnvironment() {
	nodeEnvironment = ();
	nodeIdentifier = 0;
}

private int getIdentifier() {
	int identifier = nodeIdentifier;
	
	nodeIdentifier += 1;
	
	return identifier;
}

public map[int, node] getNodeEnvironment() {
	return nodeEnvironment;
}

public int storeNode(node treeNode, NodeType nodeType = Normal()) {
	int identifier = getIdentifier();

	treeNode@nodeType = nodeType;
	nodeEnvironment[identifier] = treeNode;
	
	return identifier;
}

public node resolveNode(int identifier) {
	return nodeEnvironment[identifier];
}

public bool isDefaultCase(Statement statement) {
	return \defaultCase() := statement;
}

public bool isCase(Statement statement) {
	return \case(_) := statement;
}

public bool isMethodCall(Expression expression) {
	switch(expression) {
		case \methodCall(_, _, _): {
			return true;
		}
    	case \methodCall(_, _, _, _): {
    		return true;
    	}
	}
	
	return false;
}

public bool isPotentialThrow(node treeNode) {
	switch(treeNode) {	
		case \block(_): {
			return false;
		}
		case \if(_, _): {
			return true;
		}
		case \if(_, _, _): {
			return true;
		}
		case \for(_, _, _): {
			return true;
		}
		case \for(_, _, _, _): {
			return true;
		}
		case \while(_, _): {
			return true;
		}
		case \do(_, _): {
			return true;
		}
		case \switch(_, _): {
			return false;
		}
		case \try(_, _): {
			return false;
		}
    	case \try(_, _, _): {
    		return false;
    	}
    	case \catch(_, _): {
    		return false;
    	}
		case \break(): {
			return false;
		}
		case \break(_): {
			return false;
		}
		case \continue(): {
			return false;
		}
		case \continue(_): {
			return false;
		}
		case \return(): {
			return false;
		}
		case \return(_): {
			return false;
		}
		case \throw(_): {
			return true;
		}
		case \methodCall(_, _, _): {
			return true;
		}
    	case \methodCall(_, _, _, _): {
    		return true;
    	}
		case Statement statement: {
			return true;
		}
	}

	return false;
}