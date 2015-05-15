package PDG.ControlFlow;

public class Try {
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 4>, <4,3>, <EXITNODE, 2>, <2,1>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4> }
	 */
	public void testTry1() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(Exception exception) { // 3
			i = 10; // 4
		}
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <ENTRYNODE, 5> }
	 */
	public void testTry2() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(Exception exception) { // 3
			i = 10; // 4
		}
		
		i = i * 2; // 5
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <ENTRYNODE, 5> }
	 */
	public void testTry3() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(Exception exception) { // 3
			i = 10; // 4
		} finally {
			i = 10 + i; // 5
		}
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 6>, <6,5>, <5,4>, <4,3>, <5, 2>, <2,1>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <ENTRYNODE, 5>, <ENTRYNODE, 6> }
	 */
	public void testTry4() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(Exception exception) { // 3
			i = 10; // 4
		} finally { 
			i = 10 + i; // 5
		}
		
		i = i * 2; // 6
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 7>, <7,6>, <6,5>, <7,4>, <4,3>, <7,2>, <2,1>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <2,5>, <2,6>, <ENTRYNODE, 7> }
	 */
	public void testTry5() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(UnsupportedOperationException exception) { // 3
			i = i * 2; // 4
		} catch(NullPointerException exception) { // 5
			i = i * 3; // 6
		} finally {
			i = i + 1; // 7
		}
	}
	
	/*
	 * PDT: { <EXITNODE, ENTRYNODE>, <EXITNODE, 8>, <8,7>, <7,6>, <6,5>, <7,4>, <4,3>, <7,2>, <2,1>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <ENTRYNODE, 2>, <2,3>, <2,4>, <2,5>, <2,6>, <ENTRYNODE, 7>, <ENTRYNODE, 8> }
	 */
	public void testTry6() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(UnsupportedOperationException exception) { // 3
			i = i * 2; // 4
		} catch(NullPointerException exception) { // 5
			i = i * 3; // 6
		} finally {
			i = i + 1; // 7
		}
		
		i = 100 + i; // 8
	}
}
