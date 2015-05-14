package PDG.ControlFlow;

public class Throw {
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow1(){
		int i = 0; // 0
		
		if(i == 2) { // 1
			throw new NullPointerException(); // 2
		}
		
		throw new NullPointerException(); // 3
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow1Alternate(){
		int i = 0; // 0
		
		if(i == 2) /* 1 */ throw new NullPointerException(); // 2
		
		throw new NullPointerException(); // 3
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow2(){
		int i = 2; // 0
		
		if(i == 2) { // 1
			throw new NullPointerException(); // 2
		}
		else {
			i += 5; // 3
		}
		
		i = 4; // 4
		
		throw new NullPointerException(); // 5
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow2Alternate(){
		int i = 2; // 0
		
		if(i == 2) /* 1 */ throw new NullPointerException(); // 2
		else i += 5; // 3
		
		i = 4; // 4
		
		throw new NullPointerException(); // 5
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <7,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow3() {
		int i = 0; // 0
		
		if(i > 1) { // 1
			throw new NullPointerException(); // 2
		}
		
		try { // 3
			i = i * 3; // 4
		} catch(Exception exception) { // 5
			i = 10; // 6
		}
		
		i = 5; // 7
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <EXITNODE, 7>, <7,6>, <6,5>, <EXITNODE, 4>, <4,3>, <EXITNODE,2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow4() {
		int i = 0; // 0
		
		if(i > 1) { // 1
			throw new NullPointerException(); // 2
		}
		
		try { // 3
			i = i * 3; // 4
		} catch(Exception exception) { // 5
			i = 10; // 6
			throw new NullPointerException(); // 7
		}
		
		i = 5; // 8
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <6,4>, <4,3>, <EXITNODE,2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 */
	public void testThrow5() {
		int i = 0; // 0
		
		if(i > 1) { // 1
			throw new NullPointerException(); // 2
		}
		
		try { // 3
			i = i * 3; // 4
			throw new NullPointerException(); // 5
		} catch(Exception exception) { // 6
			i = 10; // 7
		}
		
		i = 5; // 8
	}
}
