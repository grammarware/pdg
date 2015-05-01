package PDG.controlFlow;

public class Try {
	public void testTry() {
		try {
			int i = 3;
			System.out.println("Having a function");
			
			if(i < 2) {
				System.out.println("true");
			} else {
				System.out.println("false");
			}
			
			throw new Exception();
		} catch(Exception exception) {
			System.out.println("W");
			System.out.println("W");
			System.out.println("W");
			
			if(10 != 5) {
				System.out.println("W");
			}
		}
		
		System.out.println("After try");
	}
	
	public void testTry2() {
		try {
			int i = 3;
			System.out.println("Having a function");
			
			if(i < 2) {
				System.out.println("true");
			} else {
				System.out.println("false");
				throw new NullPointerException();
			}
		} catch(UnsupportedOperationException exception) {
			System.out.println("W");
		} catch(NullPointerException exception) {
			System.out.println("Catch 1");
			System.out.println("Catch 2");
			
			if(10 != 5) {
				System.out.println("If catch");
			}
			
			System.out.println("Catch end");
		} finally {
			System.out.println("Finally");
		}
	}
	
	public void testTry3() {
		try {
			System.out.println("Try");
		} catch(Exception exception) {
			throw new NullPointerException();
		}
		
		return;
	}
}
