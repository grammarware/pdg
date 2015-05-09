module framework::RTest

import IO;

public bool RTestFunction(str name, bool(&T param) t_function, map[&T, &T] assertions) {	
	for(testCase <- assertions) {
		if(t_function(testCase) != assertions[testCase]) {
			println("|<name>|: \"<testCase>\" FAILED. Got " +
				"<t_function(testCase)>. Expected <assertions[testCase]>.");
			return false;
		}
	}
	
	return true;
}

public bool RTestFunction(str name, &T(&T param) t_function, map[&T, &T] assertions) {	
	for(testCase <- assertions) {
		if(t_function(testCase) != assertions[testCase]) {
			println("|<name>|: \"<testCase>\" FAILED. Got " +
				"<t_function(testCase)>. Expected <assertions[testCase]>.");
			return false;
		}
	}
	
	return true;
}

public bool RTestFunction(str name, &U(&T param) t_function, map[&T, &U] assertions) {	
	for(testCase <- assertions) {
		if(t_function(testCase) != assertions[testCase]) {
			println("|<name>|: \"<testCase>\" FAILED. Got " +
				"<t_function(testCase)>. Expected <assertions[testCase]>.");
			return false;
		}
	}
	
		
	return true;
}

public bool RTestFunction(str name, &U(&U param1, &T param2) t_function, map[tuple[&U, &T], &U] assertions) {	
	for(<&U param1, &T param2> <- assertions) {
		if(t_function(param1, param2) != assertions[<param1, param2>]) {
			println("|<name>|: \"<<param1, param2>>\" FAILED. Got " +
				"<t_function(param1, param2)>. Expected <assertions[<param1, param2>]>.");
			return false;
		}
	}
	
	return true;
}

public bool RTestFunction(str name, &V(&U param1, &T param2) t_function, map[tuple[&U, &T], &V] assertions) {	
	for(<&U param1, &T param2> <- assertions) {
		if(t_function(param1, param2) != assertions[<param1, param2>]) {
			println("|<name>|: \"<<param1, param2>>\" FAILED. Got " +
				"<t_function(param1, param2)>. Expected <assertions[<param1, param2>]>.");
			return false;
		}
	}
	
	return true;
}