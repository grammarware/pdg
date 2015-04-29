module graph::system::SDG

import Prelude;
import lang::java::m3::AST;

map[int, node] callSites = ();

public void createSDG(map[int, node] nodeEnvironment) {
	println(domain(nodeEnvironment));
	
	for(key <- domain(nodeEnvironment)) {
		println(key);
		visitNode(key, nodeEnvironment[key]);
	}
	
	println(callSites);
}

private void visitNode(int identifier, node treeNode) {
	visit(treeNode) {
		case \expressionStatement(stmt): {
			visitNode(identifier, stmt);
		}
		case callNode: \methodCall(isSuper, name, arguments): {
			callSites[identifier] = callNode;
    	}
    	case callNode: \methodCall(isSuper, receiver, name, arguments): {
    		callSites[identifier] = callNode;
    	}
    	case Statement statement: {
    		return;
    	}
	}
}