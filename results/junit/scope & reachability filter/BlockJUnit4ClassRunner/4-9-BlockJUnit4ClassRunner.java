protected List<FrameworkMethod> computeTestMethods() {
+	return getTestClass().getAnnotatedMethods(Test.class);
}

@Override
protected void collectInitializationErrors(List<Throwable> errors) {
	super.collectInitializationErrors(errors);

+	validateConstructor(errors);
+	validateInstanceMethods(errors);
+	validateFields(errors);
}

protected void validateConstructor(List<Throwable> errors) {
+	validateOnlyOneConstructor(errors);
+	validateZeroArgConstructor(errors);
}

protected void validateOnlyOneConstructor(List<Throwable> errors) {
+	if (!hasOneConstructor()) {
+		String gripe= "Test class should have exactly one public constructor";
+		errors.add(new Exception(gripe));
	}
}

protected void validateZeroArgConstructor(List<Throwable> errors) {
+	if (hasOneConstructor()
			&& !(getTestClass().getOnlyConstructor().getParameterTypes().length == 0)) {
+		String gripe= "Test class should have exactly one public zero-argument constructor";
+		errors.add(new Exception(gripe));
	}
}

private boolean hasOneConstructor() {
+	return getTestClass().getJavaClass().getConstructors().length == 1;
}

@Deprecated
protected void validateInstanceMethods(List<Throwable> errors) {
+	validatePublicVoidNoArgMethods(After.class, false, errors);
+	validatePublicVoidNoArgMethods(Before.class, false, errors);
+	validateTestMethods(errors);

+	if (computeTestMethods().size() == 0)
+		errors.add(new Exception("No runnable methods"));
}

private void validateFields(List<Throwable> errors) {
+	RULE_VALIDATOR.validate(getTestClass(), errors);
}

protected void validateTestMethods(List<Throwable> errors) {
+	validatePublicVoidNoArgMethods(Test.class, false, errors);
}