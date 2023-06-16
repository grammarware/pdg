@contributor{René Bulsing - UvA MSc 2015}
module clone::utility::ConsoleLogger

import Prelude;

private list[str] logHistory = [];

public void initializeConsoleLogger() {
	logHistory = [];
}

public void logInfo(str message) {
	str loggable = "[Info]: <message>";
	logHistory += loggable;
	println(loggable);
}

public void logWarning(str message) {
	str loggable = "[Warning]: <message>";
	logHistory += loggable;
	println(loggable);
}

public void logMessage(str \tag, str message, str prefix = "") {
	str loggable = "<prefix>[<\tag>]: <message>";
	logHistory += loggable;
	println(loggable);
}

public void writeConsoleLogToFile(loc location) {
	writeFile(location + "/Log.txt", intercalate("\n", logHistory));
	logHistory = [];
}