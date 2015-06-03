module fancy::DataStructures

import lang::java::m3::Core;

import graph::DataStructures;


data Flow = Flow(Vertex root, set[Vertex] intermediates, Vertex target, set[int] lineNumbers, set[str] methodSpan);

alias Seeds = rel[Candidate, Candidate];

data ProjectData = ProjectData(loc location, M3 model);
alias Projects = tuple[ProjectData first, ProjectData second];

alias Highlights = map[loc file, set[int] lineNumbers];
alias Flows = tuple[set[Flow] control, set[Flow] \data];

data Candidate = Candidate(SystemDependence systemDependence, Flows flows, Highlights highlights, set[str] methodSpan);
alias CandidatePair = tuple[Candidate first, Candidate second];
alias CandidatePairs = set[CandidatePair];