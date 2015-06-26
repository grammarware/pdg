+ private List<Throwable> errors= new ArrayList<Throwable>();

public void addError(Throwable error) {
+	errors.add(error);
}

public <T> void checkThat(final T value, final Matcher<T> matcher) {
+	checkSucceeds(new Callable<Object>() {
		public Object call() throws Exception {
			assertThat(value, matcher);
			return value;
		}
	});
}

public Object checkSucceeds(Callable<Object> callable) {
+	try {
+		return callable.call();
+	} catch (Throwable e) {
+		addError(e);
+		return null;
	}		
}