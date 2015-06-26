+ private File folder;

public File newFile(String fileName) throws IOException {
+	File file= new File(getRoot(), fileName);
+	file.createNewFile();
	return file;
}

+ public File getRoot() {
	if (folder == null) {
		throw new IllegalStateException("the temporary folder has not yet been created");
	}
+	return folder;
}