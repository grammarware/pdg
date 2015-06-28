module clone::detection::Categorizer

import Prelude;

import clone::DataStructures;


private int SIZE_THRESHOLD = 4;
							
private bool containsClones(CandidatePair pair) {
	return !isEmpty(pair.first.highlights) || !isEmpty(pair.second.highlights);
}

private bool isLargeEnough(CandidatePair pair) {
	int firstLineSpan = (0 | it + size(lineNumbers) | lineNumbers <- range(pair.first.highlights));
	int secondLineSpan = (0 | it + size(lineNumbers) | lineNumbers <- range(pair.second.highlights));
	
	return firstLineSpan > SIZE_THRESHOLD || secondLineSpan > SIZE_THRESHOLD;
}

private bool isInterprocedural(CandidatePair pair) {
	return size(pair.first.methodSpan) > 1 || size(pair.second.methodSpan) > 1;
}

private bool isRefactored(CandidatePair pair) {
	return size(pair.first.methodSpan) != size(pair.second.methodSpan);
}

public CloneData categorizeClones(CandidatePairs candidates) {
	CloneData clones = CloneData({}, {}, {}, {}, {});
	
	for(pair <- candidates) {
		if(!containsClones(pair)) {
			clones.not += { pair };
		}
		else if(!isLargeEnough(pair)) {
			clones.small += { pair };
		}
		else if(!isInterprocedural(pair)) {
			clones.nonInterprocedural += { pair };
		}
		else if(isRefactored(pair)) {
			clones.refactored += { pair };
		} 
		else {
			clones.interprocedural += { pair };
		}
	}
	
	return clones;
}