package PDG.ControlFlow;

public class If {
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	 * DDG: { <0,1> }
	 */
	public void testIf1(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		}
		
		i = 5; // 3
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	 * DDG: { <0,1> }
	 */
	public void testIf1Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		
		i = 5; // 3
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <ENTRYNODE, 4> }
	 * DDG: { <0,1> }
	 */
	public void testIf2(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		} else {
			i = 4; // 3
		}
		
		i = 5; // 4
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <ENTRYNODE, 4> }
	 * DDG: { <0,1> }
	 */
	public void testIf2Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		else i = 4; // 3
		
		i = 5; // 4
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <ENTRYNODE, 5> }
	 * DDG: { <0,1>, <0,3> }
	 */
	public void testIf3(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		} else if (i < 0) { // 3
			i = 4; // 4
		}
		
		i = 5; // 5
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <ENTRYNODE, 5> }
	 * DDG: { <0,1>, <0,3> }
	 */
	public void testIf3Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		else if (i < 0) /* 3 */ i = 4; /* 4 */
		
		i = 5; // 5
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <3,5>, <ENTRYNODE, 6> }
	 * DDG: { <0,1>, <0,3> }
	 */
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
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <3,4>, <3,5>, <ENTRYNODE, 6> }
	 * DDG: { <0,1>, <0,3> }
	 */
	public void testIf4Alternate(){
		int i = 0; // 0
		
		if(i > 0) /* 1 */ i = 3; /* 2 */
		else if (i < 0) /* 3 */ i = 4; /* 4 */
		else i = 7; // 5
		
		i = 5; // 6
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <4,7>, <4,8>, <ENTRYNODE, 9> }
	 * DDG: { <0,1>, <0,4> }
	 */
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
	
	public void testIf6(){
		int i = 0; // 0
		
		if(i > 0) { // 1
			i = 3; // 2
		} else {
		}
		
		i = 5; // 4
	}
	
	public void testIf7(){
		int i = 0; // 0
		
		if(i > 0) { // 1
		} else {
			i = 4; // 3
		}
		
		i = 5; // 4
	}
	
	public void testIf8(){
		int i = 0; // 0
		
		if(i > 0) { // 1
		} else {
		}
		
		i = 5; // 4
	}
}
