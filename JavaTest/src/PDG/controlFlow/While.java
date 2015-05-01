package PDG.controlFlow;

public class While {
	public void testWhile(){
		int i = 3;
		while(i > 1){
			System.out.println("While");
			i--;
		}
		System.out.println("End");
	}
	
	public void testWhile2(){
		int i = 3;
		while(i > 1){
			System.out.println("While");
			i--;
		}
	}
	
	public void testDoWhile() {
		int i = 3;
		
		do {
			System.out.println("Do while");
			i--;
		} while(i > 0);
		
		System.out.println("End");
	}
}
