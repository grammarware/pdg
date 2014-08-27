module DataDependence::DataFlow

import lang::java::m3::AST;
import ADT;

public DF computeDataFlow(Statement stat, Environment environment){
	lrel[int, int, str] dflow = [];
	visit(stat){
				case \variable(str name, int extraDimensions): {
					environment.currentEnv += (name: stat);
				}
				case \variable(str name, int extraDimensions, Expression \initializer): {
					environment.currentEnv += (name: stat);
				}
				case \simpleName(str name): {
					statS = getStatFromEnv(name, environment);
					if(Statement::\empty() != statS) {
				 		dflow += <statS, stat, name>;
				 	} 	
				 }
				 case \assignment(\simpleName(str name), _ , _): {
					environment = updateEnv(name, environment, stat);
				}
				case \postfix(\simpleName(str name), _ ): {
					environment = updateEnv(name, environment, stat);
					println(environment);
				}
			}
	
	return dataFlow(dflow, environment);
}


private int getStatFromEnv(str name, Environment env){
	if(name in env.currentEnv){
		return env.currentEnv[name];
	}else if(\env(_,_) := env){
		return getStatFromEnv(name, env.parentEnv);
	}
	//}else{
	//	return Statement::\empty();
	//}
}


private Environment updateEnv(str name, Environment env, int stat){
	if(name in env.currentEnv)
		// if on this level, update
		env.currentEnv[name] = stat;
	else if(\env(_,_):=env)
		// we need to go deeper
		env.parentEnv = updateEnv(name, env.parentEnv, stat);
	else
		// if not found, introduce it
		// NB: this should not happen
		env.currentEnv[name] = stat;
	return env;
}