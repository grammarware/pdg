module extractors::File

import Prelude;
import analysis::m3::Registry;

// Use this to always load the whole file without registry locs.
private bool bypassRegistry = false;
// Cache for all the code lines requested, to substantially reduce IO.
private map[str, list[str]] lineCache = ();

@doc {
	Get all the file its contents as a list of strings. 
	The offsets are excluded in the retrieval of the 
	contents if the bypassRegistry boolean is set to true.
 
	@side-effect - 
		Caches every file its retrieved lines to reduce IO.

	@param (loc) fileLoc -
		The location of the file to read.

	@return (list[str]) -
		The list of code lines as strings.
}
public list[str] getFileLines(loc fileLoc) {
	loc location = bypassRegistry ? toLocation(resolveM3(fileLoc).uri) : fileLoc;
	str cacheKey = location.uri;
	
	if(cacheKey notin lineCache) {
		lineCache[cacheKey] = readFileLines(location);
	}
	
	return lineCache[cacheKey];
}

@doc {
	Get the lines of the given method as a list of 
	strings. The offsets are always included in this 
	retrieval.
 
	@side-effect -
		Caches every method its retrieved lines to 
		reduce IO.
 
	@param (loc) fileLoc -
		The location of the method to read.
 
	@return (list[str]) -
		The list of code lines as strings.
}
public list[str] getMethodLines(loc methodLocation) {
	str cacheKey = methodLocation.uri;
		
	if(cacheKey notin lineCache) {
		lineCache[cacheKey] = readFileLines(methodLocation);
	}
	
	return lineCache[cacheKey];
}

public list[str] getLines(loc lineLoc) {
	return readFileLines(lineLoc);
}
