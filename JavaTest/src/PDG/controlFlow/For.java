package PDG.controlFlow;

public class For {
	public void testFor(){
		int m = 2;
		
		for(int i = 0; i <= m; i++){
			System.out.println("FOR");
			System.out.println("FOR");
		}
		
		System.out.println("END");
	}

	public void testFor2(){
		int m = 2;
		for(int i = 0, j = 7; i <= j; i++, j--){
			System.out.println("For" + m);
		}
	}
}
