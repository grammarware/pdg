module legacy::Utils::Map

import Map;
import List;
import legacy::Utils::List;

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

public map[int, map[str, set[int]]] reverseKeyValue(map[int, map[int, set[str]]] m){
	map[int, map[str, set[int]]] reversedMap = ();
	for(key <- m){
		reversedMap[key] = ();
		for(key2 <- m[key]){
			for(v <- m[key][key2]){
				if(v notin reversedMap[key]) reversedMap[key][v] = {key2};
				else reversedMap[key][v] += {key2};
			}
		}
	}
	return reversedMap;
}