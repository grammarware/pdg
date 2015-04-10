module graph::control::Flow

import Prelude;
import analysis::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

public void createControlFlowGraph(Declaration tree) {
	top-down visit(tree) {
		case \block(body): {
			processBlock(body); 
		}
		case ifNode: \if(_, _): {
			processIf(ifNode);
		}
		case ifElseNode: \if(_, _, _): {
			processIfElse(ifElseNode);
		}
		case forNode: \for(_, _, _): {
			processFor(forNode);
		}
		case forNode: \for(_, _, _, _): {
			processFor(forNode);
		}
		case whileNode: \while(_, _): {
			processWhile(whileNode);
		}
		case doWhileNode: \do(_, _): {
			processDoWhile(doWhileNode);
		}
		case switchNode: \switch(_, _): {
			processSwitch(switchNode);
		}
		case breakNode: \break(): {
			processBreak(breakNode);
		}
		case breakNode: \break(_): {
			processBreak(breakNode);
		}
		case continueNode: \continue(): {
			processContinue(continueNode);
		}
		case continueNode: \continue(_): {
			processContinue(continueNode);
		}
		case returnNode: \return(): {
			processReturn(returnNode);
		}
		case returnNode: \return(_): {
			processReturn(returnNode);
		}
		case Statement statement: {
			processStatement(statement);
		}
	};
}

private void processBlock(list[Statement] body) {
	println(body);
}

private void processIf(Statement ifNode) {
	println(ifNode);
}

private void processIfElse(Statement ifElseNode) {
	println(ifElseNode);
}

private void processFor(Statement forNode) {
	println(forNode);
}

private void processWhile(Statement whileNode) {
	println(whileNode);
}

private void processDoWhile(Statement doWhileNode) {
	println(doWhileNode);
}

private void processSwitch(Statement switchNode) {
	println(switchNode);
}

private void processBreak(Statement breakNode) {
	println(breakNode);
}

private void processContinue(Statement continueNode) {
	println(continueNode);
}

private void processReturn(Statement returnNode) {
	println(returnNode);
}

private void processStatement(Statement statement) {
	println(statement);
}