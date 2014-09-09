module Utils::List
import List;
import Map;

//the items which are not in the bc map
public list[int] exclude(list[int] ls, map[int, list[int]] bc, list[int] condFollowdByBC){
	list[int] rls = [];
	for(l <- ls){
		if(l notin bc) rls += l;
		else if(l in bc && l in condFollowdByBC) rls += l;
	}
	return rls;
}

public bool equals(list[value] l1, list[value] l2){
	return toSet(l1) == toSet(l2);	
}