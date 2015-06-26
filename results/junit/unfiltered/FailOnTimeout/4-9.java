@Override
public void evaluate() throws Throwable {
+	Thread thread= new Thread() {
		@Override
		public void run() {
			try {
				fNext.evaluate();
				fFinished= true;
			} catch (Throwable e) {
				fThrown= e;
			}
		}
	};
+	thread.start();
+	thread.join(fTimeout);
+	if (fFinished)
		return;
+	if (fThrown != null)
+		throw fThrown;
+	Exception exception= new Exception(String.format(
			"test timed out after %d milliseconds", fTimeout));
+	exception.setStackTrace(thread.getStackTrace());
+	throw exception;
}