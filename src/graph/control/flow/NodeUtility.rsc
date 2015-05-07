module graph::control::flow::NodeUtility

import lang::java::m3::AST;

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