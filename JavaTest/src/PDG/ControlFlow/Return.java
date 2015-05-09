package PDG.ControlFlow;

public class Return {
	public void testReturn1(){
		int i = 0; // 0
		
		if(i == 2) { // 1
			return; // 2
		}
		
		return; // 3
	}
	
	public void testReturn1Alternate(){
		int i = 0; // 0
		
		if(i == 2) /* 1 */ return; // 2
		
		return; // 3
	}
	
	public void testReturn2(){
		int i = 2; // 0
		
		if(i == 2) { // 1
			return; // 2
		}
		else {
			i += 5; // 3
		}
		
		i = 4; // 4
		
		return; // 5
	}
	
	public void testReturn2Alternate(){
		int i = 2; // 0
		
		if(i == 2) /* 1 */ return; // 2
		else i += 5; // 3
		
		i = 4; // 4
		
		return; // 5
	}
}
