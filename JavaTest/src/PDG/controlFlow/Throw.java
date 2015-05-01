package PDG.controlFlow;

public class Throw {
	public void testThrow() {
		int i = 10;
		
		System.out.println("Do something");
		
		if(i == 5) {
			System.out.println("MORAR");
		} else {
			throw new NullPointerException();
		}
		
		System.out.println("Waddap");
	}
}
