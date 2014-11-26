module Utils::ListRelation

import List;
import ListRelation;
import IO;

//toLRel([1,2,3]) = [<1, 2>, <2, 3>]
public lrel[int, int] toLRel([]) = [];
public default lrel[int, int] toLRel(list[int] ls) = [<ls[i], ls[i+1]> | i <- [0..size(ls) - 1]];

// added to the Rascal library as well
public map[&T0,list[&T1]] toMap(lrel[&T0,&T1] R) = isEmpty(R) ? ()
	: (k:[v | <k,&T1 v> <- R] | &T0 k <- domain(R));

public map[int, list[int]] getPredecessors(lrel[int, int] lr){
	map[int, list[int]] m = ();
	for(<num1, num2> <- lr){
		if(num2 notin m) m[num2] = [num1];
		else m[num2] += [num1];
	}
	return m;
}
