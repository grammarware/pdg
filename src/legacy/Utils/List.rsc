module legacy::Utils::List

import List;
import Map;

//the items which are not in the bc map
public list[int] exclude(list[int] input, map[int, list[int]] yesmap, list[int] nolist)
	= [l | l <- input, l notin yesmap || l in nolist];

public bool equals(list[value] l1, list[value] l2){
	return toSet(l1) == toSet(l2);	
}