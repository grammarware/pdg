package PDG.ControlFlow;

public class For {
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> }
	 * DDG: { <2,2>, <0,2>, <1,1> }
	 */
	public void testFor1(){
		int m = 2; // 0
		
		for(int i = 0, j = 7; i <= j; i++, j--) { // 1
			m = m + 4; // 2
		}
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> }
	 * DDG: { <2,2>, <0,2>, <1,1> }
	 */
	public void testFor1Alternate(){
		int m = 2; // 0
		
		for(int i = 0, j = 7; i <= j; i++, j--) /* 1 */ m = m + 4; // 2
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	 * DDG: { <2,1>, <0,1>, <1,1> }
	 */
	public void testFor2(){
		int m = 2; // 0
		
		for(int i = 0; i <= m; i++) { // 1
			m = 3; // 2
		}
		
		m = 4; // 3
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	 * DDG: { <2,1>, <0,1>, <1,1> }
	 */
	public void testFor2Alternate(){
		int m = 2; // 0
		
		for(int i = 0; i <= m; i++) /* 1 */ m = 3; // 2
		
		m = 4; // 3
	}
	
	public void testFor3(){
		int m = 2; // 0
		
		for(int i = 0; i <= m; i++) { // 1
			if(m == 2) {
				continue;
			}
			
			m = 3; // 2
			m = 4; // 3
		}
		
		m = 4; // 4
	}
}
