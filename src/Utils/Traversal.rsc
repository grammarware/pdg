module Utils::Traversal

import List;
import IO;

public list[int] toPostOrder(map[int, list[int]] flow, int first, int numbers){
	int current = first;
	list[int] postOrder = [];
	list[int] visitStack = [current]; 
	map[int, bool] visited = (current: true);
	for(i <- [1..numbers]){
		visited[i] = false;
	}
	
	return DFS(flow, postOrder, visitStack, visited);
}

private list[int] DFS(map[int, list[int]] flow, list[int] postOrder, list[int] visitStack, map[int, bool] visited){	
	if(size(visitStack) == 0){
		return postOrder;
	}else{
		current = visitStack[0];
		if(current notin flow){
			println(current);
			postOrder += current;
			visitStack = tail(visitStack);
			return DFS(flow, postOrder, visitStack, visited);
		}else if(all(int n <- flow[current], visited[n] == true)){
			println(current);
			postOrder += current;
			visitStack = tail(visitStack);
			return DFS(flow, postOrder, visitStack, visited);
		}else{
			for(n <- flow[current] && visited[n] == false){
				visited[n] = true;
				visitStack = insertAt(visitStack, 0, n);
				return DFS(flow, postOrder, visitStack, visited);
			}
		}
	}
}