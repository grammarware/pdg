package PDG.ControlFlow;

public class While {
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> }
	 */
	public void testWhile1(){
		int i = 3; // 0
		
		while(i > 1) { // 1
			i--; // 2
		}
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2> }
	 */
	public void testWhile1Alternate(){
		int i = 3; // 0
		
		while(i > 1) /* 1 */ i--; // 2
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	 */
	public void testWhile2(){
		int i = 3; // 0
		
		while(i > 1) { // 1
			i--; // 2
		}
		
		i = 4; // 3
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <ENTRYNODE, 3> }
	 */
	public void testWhile2Alternate(){
		int i = 3; // 0
		
		while(i > 1) /* 1 */ i--; // 2
		
		i = 4; // 3
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <1,2>, <ENTRYNODE, 1> }
	 */
	public void testDoWhile1() {
		int i = 3; // 0
		
		do {
			i--; // 2
		} while(i > 0); // 1
	}
	
	/*
	 * CDG: { <ENTRYNODE, 0>, <1,2>, <ENTRYNODE, 1>, <ENTRYNODE, 3> }
	 */
	public void testDoWhile2() {
		int i = 3; // 0
		
		do {
			i--; // 2
		} while(i > 0); // 1
		
		i = 4; // 3
	}
}
