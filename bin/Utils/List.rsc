module Utils::List
import List;


//catenate([1,2], 3) = [<1, 3>, <2, 3>]
public lrel[int, int] catenate(list[int] ls, int m){
	return [<l, m> | l <- ls];
}

//toLRel([1,2,3]) = [<1, 2>, <2, 3>]
public lrel[int, int] toLRel(list[int] ls){
	if(size(ls) > 1)	return [<ls[i], ls[i+1]> | i <- [0..size(ls) - 1]];
	else return [];
}