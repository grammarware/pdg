package PDG.ControlFlow;

public class Throw {
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3> }
	 * DDG: { <0,1> }
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
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3> }
	 * DDG: { <0,1> }
	 */
	public void testThrow1Alternate(){
		int i = 0; // 0
		
		if(i == 2) /* 1 */ throw new NullPointerException(); // 2
		
		throw new NullPointerException(); // 3
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <EXITNODE, 2>, <EXITNODE,1>, <1,0>, <0, STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5> }
	 * DDG: { <0,1>, <0,3> }
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
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <1,5> }
	 * DDG: { <0,1>, <0,3> }
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
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <1,7> }
	 * DDG: { <0,1>, <0,4> }
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
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <4,6>, <4,7>, <4,8> }
	 * DDG: { <0,1>, <0,4> }
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
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <1,3>, <1,4>, <4,5>, <1,6>, <1,7>, <1,8> }
	 * DDG: { <0,1>, <0,4> }
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
	
	public void testThrow6() throws Exception {
		int i = 0; // 0
		
		if(i > 1) { // 1
			throw new NullPointerException(); // 2
		}
		
		try { // 3
			i = i * 3; // 4
			throw new NullPointerException(); // 5
		} catch(Exception exception) { // 6
			i = 10; // 7
			throw exception;
		} finally {
			i = 11;
		}
	}
	
	public void testThrow7() throws Exception {
		int i = 0; // 0
		
		if(i > 1) { // 1
			throw new NullPointerException(); // 2
		}
		
		try { // 3
			i = i * 3; // 4
			throw new NullPointerException(); // 5
		} catch(NoClassDefFoundError exception) { // 6
			i = 10; // 7
		} catch(NullPointerException exception) { // 6
			throw exception;
		} catch(UnsupportedOperationException exception) { // 6
			throw exception;
		} catch(Exception exception) { // 6
			throw exception;
		} finally {
			i = 11;
		}
	}
	
	public void testThrow8() {
		for(int i = 10; i > 0; i --) {
			if(i == 5) {
				throw new NullPointerException();
			}
		}
		
		System.out.println("Whatever mate.");
	}
	
	public void testThrow9() throws Exception {
		int i = 0; // 0
		
		if(i > 1) { // 1
			throw new NullPointerException(); // 2
		}
		
		try { // 3
			i = i * 3; // 4
			throw new NullPointerException(); // 5
		} catch(Exception exception) { // 6
		} finally {
			i = 11;
		}
	}
	
	public void testThrow10() throws Exception {
		int i = 0; // 0
		
		try { // 3
			i = i * 3; // 4
			throw new NullPointerException(); // 5
		} finally {
			i = 11;
		}
	}
	
	public void testThrow11() throws Exception {
	    int i = 0;
		
	    if(i > 1) {
	        throw new NullPointerException();
	    }
		
	    try {
	        i = i * 2;
	        throw new NullPointerException();
	    } catch(NoClassDefFoundError exception) {
	        i = 10;
	    } catch(Exception exception) {
	        i = 12;
	        throw exception;
	    } finally {
	        i = 11;
	        i = i * 3;
	    }
	}
	
	public void testThrow12() throws Exception {
		int i = 10;
		
		if(i == 5) {
			if(i == 2) {
				throw new NullPointerException();
			}
			
			try {
				i = 2;
			} catch(Exception ex) {
				i = 5;
			}
		}
	}
}
