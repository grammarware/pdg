module TryCounter

import Prelude;
import analysis::m3::Registry;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import extractors::Project;

public void countTries(str projectName) {
	loc project = createProjectLoc(projectName);
	
	set[Declaration] asts = createProjectAST(project, false);
	
	int tryCounter = 0;
	int catchCounter = 0;
	int finallyCounter = 0;
	
	for(ast <- asts) {
		tuple[int tries,int catches,int finals] counts = count(ast);
		
		tryCounter += counts.tries;
    	catchCounter += counts.catches;
    	finallyCounter += counts.finals;
	}
	
	println("Total: Tries = <tryCounter>. Catches = <catchCounter>. Finally = <finallyCounter>.");
}

private tuple[int tries,int catches,int finals] count(Declaration ast) {
	int tryCounter = 0;
	int catchCounter = 0;
	int finallyCounter = 0;
	
	visit(ast) {
		case \try(Statement body, list[Statement] catchClauses): {
			tryCounter += 1;
			catchCounter += size(catchClauses);
		}
    	case \try(Statement body, list[Statement] catchClauses, Statement \finally): {
    		tryCounter += 1;
    		catchCounter += size(catchClauses);
    		finallyCounter += 1;
    	}
	}
	
	//println("[<ast@src.file>]: Tries = <tryCounter>. Catches = <catchCounter>. Finally = <finallyCounter>.");
	
	return <tryCounter, catchCounter, finallyCounter>;
}