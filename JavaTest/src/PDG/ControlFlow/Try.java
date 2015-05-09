package PDG.ControlFlow;

public class Try {
	public void testTry1() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(Exception exception) { // 3
			i = 10; // 4
		}
	}
	
	public void testTry2() {
		int i = 0; // 0
		
		try { // 1
			i = i + 1; // 2
		} catch(Exception exception) { // 3
			i = 10; // 4
		}
		
		i = i * 2; // 5
	}
	
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
