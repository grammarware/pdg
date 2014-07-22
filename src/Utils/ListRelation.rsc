module Utils::ListRelation
import List;
import IO;

//catenate([1,2], 3) = [<1, 3>, <2, 3>]
public lrel[int, int] catenate(list[int] ls, int m){
	return [<l, m> | l <- ls];
}

//toLRel([1,2,3]) = [<1, 2>, <2, 3>]
public lrel[int, int] toLRel(list[int] ls){
	if(size(ls) > 1)	return [<ls[i], ls[i+1]> | i <- [0..size(ls) - 1]];
	else return [];
}

public map[int, list[int]] toMap(lrel[int, int] lr){
	map[int, list[int]] m = ();
	for(<num1, num2> <- lr){
		if(num1 notin m) m[num1] = [num2];
		else m[num1] += [num2];
	}
	return m;
}

public map[int, list[int]] getPredecessors(lrel[int, int] lr){
	map[int, list[int]] m = ();
	for(<num1, num2> <- lr){
		if(num2 notin m) m[num2] = [num1];
		else m[num2] += [num1];
	}
	return m;
}