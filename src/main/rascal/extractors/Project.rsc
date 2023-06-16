@contributor{René Bulsing - UvA MSc 2015}
module extractors::Project

import Prelude;

import analysis::m3::Registry;
import lang::java::m3::Core;
import lang::java::m3::AST;

/* Caches to reduce IO. */
private map[loc, M3] M3Cache = ();
private map[loc, set[Declaration]] ASTCache = ();
private map[M3, set[loc]] classCache = ();
private map[M3, set[loc]] fileCache = ();

@doc {
	Create a M3 model from the given project location
	and cache it. If it's already cached retrieve it
	from the cache. If the project location contains a
	pom.xml file, the project is imported as a Maven
	project. Otherwise it is imported as a directory.
	
	@param (loc) project -
		The project location variable.
	@return (M3) -
		The M3 model for the project.
}
public M3 createM3(loc project) {	
	if (project notin M3Cache) {
		if (exists(project + "pom.xml")) {
			M3Cache[project] = createM3FromMavenProject(project);
		} else {
			M3Cache[project] = createM3FromDirectory(project);
		}
	}

	return M3Cache[project];
}

@doc {
	Create an AST from the given project location and 
	cache it. If it's already cached retrieve it from 
	the cache. If the project location contains a
	pom.xml file, the project is imported as a Maven
	project. Otherwise it is imported as a directory.
	
	@param (loc) project -
		The project location variable.
	@param (bool) collectBindings -
		Do not know what this is.
	@return (set[Declaration]) -
		The AST for the project.
}
public set[Declaration] createProjectAST(loc project, bool collectBindings) {
	if(project notin ASTCache) {
		if (exists(project + "pom.xml")) {
			ASTCache[project] = createAstsFromMavenProject(project, collectBindings);
		} else {
			ASTCache[project] = createAstsFromDirectory(project, collectBindings);
		}
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
	return methods(project);
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
	return files(project);
}

public loc resolveLocation(loc unresolved, M3 project) {
	set[loc] declarations = project.declarations[unresolved];
	
	if(size(declarations) > 1) {
		throw "Too many declarations for <unresolved>";
	}
	
	if(isEmpty(declarations)) {
		throw "No declarations for <unresolved>";
	}
	
	return getOneFrom(declarations);
}

/* Polyfill functions for old APIs that no longer exist. */
node getMethodASTEclipse(loc methodLoc, M3 model = m3(|unknown:///|)) {
	set[Declaration] ast = createProjectAST(model.id, true);
	set[Declaration] methodAst = { d | /Declaration d := ast, d.decl == methodLoc };
	if ({ oneResult } := methodAst) {
		return oneResult;
	}
	throw "Unexpected number of ASTs returned for <(methodLoc.uri)>";
}
 
/* =========== *
 * == Tests == *
 * =========== */ 
public set[loc] getM3MethodsUtil(loc projectLoc) {
	M3 project = createM3(projectLoc);
	
	return methods(project);
}

public set[loc] getM3FilesUtil(loc projectLoc) {
	M3 project = createM3(projectLoc);
	
	return files(project);
}