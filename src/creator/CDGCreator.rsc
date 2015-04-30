module creator::PDTCreator

import Prelude;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import lang::java::m3::AST;

import graph::DataStructures;
import graph::control::PDT;
import graph::control::flow::CFG;

public list[MethodData] createPostDominators(list[MethodData] methodsData) {
	list[MethodData] newMethodsData = [];
	
	for(methodData <- methodsData) {
		newMethodsData += createPDT(methodData);
	}	
	
	return newMethodsData;
}