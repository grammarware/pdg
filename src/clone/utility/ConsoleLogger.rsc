module clone::utility::ConsoleLogger

import Prelude;


public void logInfo(str message) {
	println("[Info]: <message>");
}

public void logWarning(str message) {
	println("[Warning]: <message>");
}