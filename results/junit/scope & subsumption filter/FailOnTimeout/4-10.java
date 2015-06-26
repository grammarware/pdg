@Override
public void evaluate() throws Throwable {
	StatementThread thread= evaluateStatement();
+	if (!thread.fFinished)
+		throwExceptionForUnfinishedThread(thread);
}

private StatementThread evaluateStatement() throws InterruptedException {
+	StatementThread thread= new StatementThread(fOriginalStatement);
+	thread.start();
+	thread.join(fTimeout);
+	thread.interrupt();
	return thread;
}

private void throwExceptionForUnfinishedThread(StatementThread thread)
		throws Throwable {
+	if (thread.fExceptionThrownByOriginalStatement != null)
+		throw thread.fExceptionThrownByOriginalStatement;
	else
+		throwTimeoutException(thread);
}

private void throwTimeoutException(StatementThread thread) throws Exception {
+	Exception exception= new Exception(String.format(
			"test timed out after %d milliseconds", fTimeout));
+	exception.setStackTrace(thread.getStackTrace());
+	throw exception;
}