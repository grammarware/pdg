module extractors::Project

import IO;

import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

/* Caches to reduce IO. */
private map[loc, M3] M3Cache = ();
private map[loc, set[Declaration]] ASTCache = ();
private map[M3, set[loc]] classCache = ();
private map[M3, set[loc]] methodCache = ();
private map[M3, set[loc]] fileCache = ();

@doc {
	Create a location variable from the given
	project name.
	
	@param (String) projectName -
		The name of the project.
	@return (loc) -
		The constructed location variable.
}
public loc createProjectLoc(str projectName) {
	return |project://<projectName>|;
}

@doc {
	Create a M3 model from the given project location
	and cache it. If it's already cached retrieve it
	from the cache.
	
	@param (loc) project -
		The project location variable.
	@return (M3) -
		The M3 model for the project.
}
public M3 createM3(loc project) {
	if(project notin M3Cache) {
		M3Cache[project] = createM3FromEclipseProject(project);
	}
	
	return M3Cache[project];
}

@doc {
	Create an AST from the given project location and 
	cache it. If it's already cached retrieve it from 
	the cache.
	
	@param (loc) project -
		The project location variable.
	@param (bool) collectBindings -
		Do not know what this is.
	@return (set[Declaration]) -
		The AST for the project.
}
public set[Declaration] createProjectAST(loc project, bool collectBindings) {
	if(project notin ASTCache) {
		ASTCache[project] = createAstsFromEclipseProject(project, collectBindings);
	}
	
	return ASTCache[project];
}

@doc {
	Get a list of all classes in an M3 model and cache 
	it. If it's already cached retrieve it from the cache.
	
	@param (M3) project -
		The M3 project model.
	@return (set[loc]) -
		The set of locations of all classes in the model.
}
public set[loc] getM3Classes(M3 project) {
	if(project notin classCache) {
		classCache[project] = classes(project);
	}
	
	return classCache[project];
}

@doc {
	Get a list of all methods in an M3 model and cache 
	it. If it's already cached retrieve it from the cache.
 
	@param (M3) project -
 		The M3 project model.
	@return (set[loc]) -
		The set of locations of all methods in the model.
}
public set[loc] getM3Methods(M3 project) {
	if(project notin methodCache) {
		methodCache[project] = methods(project);
	}
	
	return methodCache[project];
}

@doc {
	Get a list of all files in an M3 model and cache 
	it. If it's already cached retrieve it from the cache.
	
	@param (M3) project - 
		The M3 project model.
	@return (set[loc]) -
		The set of locations of all files in the model.
}
public set[loc] getM3Files(M3 project) {
	if(project notin fileCache) {
		fileCache[project] = files(project);
	}
	
	return fileCache[project];
}

 
/* =========== *
 * == Tests == *
 * =========== */ 
public set[loc] getM3MethodsUtil(str projectName) {
	M3 project = createM3(createProjectLoc(projectName));
	
	return methods(project);
}

public set[loc] getM3FilesUtil(str projectName) {
	M3 project = createM3(createProjectLoc(projectName));
	
	return files(project);
}