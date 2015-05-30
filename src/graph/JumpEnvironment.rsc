module graph::JumpEnvironment

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

// Register throw nodes, for post-process binding.
set[int] throwNodes = {};
set[int] parentThrowNodes = {};

public void addThrowNode(int identifier) {
	throwNodes += {identifier};
}

public set[int] getThrowNodes() {
	set[int] throwss = throwNodes;
	
	throwNodes = {};
	
	return throwss;
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

public void initializeJumpEnvironment() {
	breakNodes = {};
	parentBreakNodes = {};
	continueNodes = {};
	parentContinueNodes = {};
	throwNodes = {};
	parentThrowNodes = {};
	returnNodes = {};
}

// Scoping functions to account for block scope.
public void scopeDown() {
	parentBreakNodes += breakNodes;
	parentContinueNodes += continueNodes;
	parentThrowNodes += throwNodes;
	
	breakNodes = {};
	continueNodes = {};
	throwNodes = {};
}

public void scopeUp() {
	breakNodes += parentBreakNodes;
	continueNodes += parentContinueNodes;
	throwNodes += parentThrowNodes;
}