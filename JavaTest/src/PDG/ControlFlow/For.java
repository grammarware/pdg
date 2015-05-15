package PDG.ControlFlow;

public class For {
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> }
	 */
	public void testFor1(){
		int m = 2; // 0
		
		for(int i = 0, j = 7; i <= j; i++, j--) { // 1
			m = m + 4; // 2
		}
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> }
	 */
	public void testFor1Alternate(){
		int m = 2; // 0
		
		for(int i = 0, j = 7; i <= j; i++, j--) /* 1 */ m = m + 4; // 2
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
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
	 */
	public void testFor2Alternate(){
		int m = 2; // 0
		
		for(int i = 0; i <= m; i++) /* 1 */ m = 3; // 2
		
		m = 4; // 3
	}
}
