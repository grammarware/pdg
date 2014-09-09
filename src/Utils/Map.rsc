module Utils::Map
import Map;
import List;
import Utils::List;

public map[str, set[int]] insertStrToMap(str name, int stat, map[str, set[int]] m){
	if(name in m) m[name] += stat;
	else m[name] = {stat};
	return m;
}

public map[int, set[str]] insertInToMap(str name, int stat, map[int, set[str]] m){
	if(stat in m) m[stat] += name;
	else m[stat] = {name};
	return m;
}

public map[int, set[str]] mergeMaps(list[map[int, set[str]]] maps){
	map[int, set[str]] result = ();
	for(m <- maps){
		for(key <- m, m[key] != {}){
			if(key in result) result[key] += m[key];
			else result[key] = m[key];
		}
	}
	return result;
}

//m1 - m2
public map[int, set[str]] subtractMaps(map[int, set[str]] m1, map[int, set[str]] m2){
	map[int, set[str]] result = ();
	for(key <- m1){
		if(key notin m2) result[key] = m1[key];
		else if(m1[key] != m2[key]) result[key] = m1[key] - m2[key];
	}
	return result;
}