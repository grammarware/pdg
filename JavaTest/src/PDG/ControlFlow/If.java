package PDG.ControlFlow;

public class If {
	public void testIf1(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		}
		
		i = 5; // 3
	}
	
	public void testIf1Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		
		i = 5; // 3
	}
	
	public void testIf2(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		} else {
			i = 4; // 3
		}
		
		i = 5; // 4
	}
	
	public void testIf2Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		else i = 4; // 3
		
		i = 5; // 4
	}
	
	public void testIf3(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		} else if (i < 0) { // 3
			i = 4; // 4
		}
		
		i = 5; // 5
	}
	
	public void testIf3Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		else if (i < 0) /* 3 */ i = 4; /* 4 */
		
		i = 5; // 5
	}
	
	public void testIf4(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		} else if (i < 0) { // 3
			i = 4; // 4
		} else {
			i = 7; // 5
		}
		
		i = 5; // 6
	}
	
	public void testIf4Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		else if (i < 0) /* 3 */ i = 4; /* 4 */
		else i = 7; // 5
		
		i = 5; // 6
	}
	
	public void testIf5(){
		int i = 0; // 0
		
		if(i > 1) { // 1
			i = 2; // 2
			i = 3; // 3
		} else if (i < 4) { // 4
			i = 5; // 5
			i = 6; // 6
		} else {
			i = 7; // 7
			i = 8; // 8
		}
		
		i = 9; // 9
	}
}
