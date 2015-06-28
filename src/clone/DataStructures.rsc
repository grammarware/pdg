module clone::DataStructures

import lang::java::m3::Core;

import graph::DataStructures;


data Flow = Flow(Vertex root, set[Vertex] intermediates, Vertex target, set[int] lineNumbers, set[str] methodSpan);

alias Seeds = rel[Candidate, Candidate];

data ProjectData = ProjectData(loc location, M3 model);
alias Projects = tuple[ProjectData first, ProjectData second];

alias Highlights = map[loc file, set[int] lineNumbers];
alias Flows = tuple[set[Flow] control, set[Flow] \data];

data Candidate = Candidate(loc seed, SystemDependence systemDependence, Flows flows, Highlights highlights, set[str] methodSpan);
alias CandidatePair = tuple[Candidate first, Candidate second];
alias CandidatePairs = set[CandidatePair];

data CloneData = CloneData(CandidatePairs refactored, CandidatePairs interprocedural,
							CandidatePairs nonInterprocedural, CandidatePairs small,
							CandidatePairs not);

public bool isIntermediate(map[Vertex, node] environment, Vertex vertex) {
	if(vertex notin environment 
		|| (environment[vertex]@nodeType != Normal() && environment[vertex]@nodeType != Global())) {
		return true;
	}
	
	switch(environment[vertex]) {
		case m: \methodCall(_, _, _): {
			try return m@src.file == "<m@decl.parent.file>.java";
			catch: return false;
		}
    	case m: \methodCall(_, _, _, _): {
    		try return m@src.file == "<m@decl.parent.file>.java";
			catch: return false;
    	}
    	case \do(_, _):
    		return true;
    	case \foreach(_, _, _):
    		return true;
    	case \for(_, _, _, _):
    		return true;
    	case \for(_, _, _):
    		return true;
    	case \if(_, _):
    		return true;
    	case \if(_, _, _):
    		return true;
		case \switch(_, _):
			return true;
		case \while(_, _):
			return true;
	}
	
	return false;
}