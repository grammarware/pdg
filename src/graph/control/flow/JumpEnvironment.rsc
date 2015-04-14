module graph::control::flow::JumpEnvironment

// Register break nodes, for post-process binding.
set[int] breakNodes = {};
set[int] parentBreakNodes = {};

public void addBreakNode(int identifier) {
	breakNodes += {identifier};
}

public set[int] getBreakNodes() {
	set[int] breaks = breakNodes;
	
	breakNodes = {};
	
	return breaks;
}

// Register continue nodes, for post-process binding.
set[int] continueNodes = {};
set[int] parentContinueNodes = {};

public void addContinueNode(int identifier) {
	continueNodes += {identifier};
}

public set[int] getContinueNodes() {
	set[int] continues = continueNodes;
	
	continueNodes = {};
	
	return continues;
}

// Register return nodes, for post-process binding.
set[int] returnNodes = {};

public void addReturnNode(int identifier) {
	returnNodes += {identifier};
}

public set[int] getReturnNodes() {
	set[int] returns = returnNodes;
	
	returnNodes = {};
	
	return returns;
}

// Scoping functions to account for block scope.
public void scopeDown() {
	parentBreakNodes = breakNodes;
	parentContinueNodes = continueNodes;
	
	breakNodes = {};
	continueNodes = {};
}

public void scopeUp() {
	breakNodes = parentBreakNodes;
	continueNodes = parentContinueNodes;
}