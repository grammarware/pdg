package PDG.ControlFlow;

public class Continue {
	public void testContinue1(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			if(i == 6) { // 2
				continue; // 3
			}
			
			i = 10; // 4
		}
	}
	
	public void testContinue2(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			if(i == 6) { // 2
				continue; // 3
			}
			
			i = 10; // 4
		}
		
		i = i * 10; // 5
	}
	
	public void testContinue3(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			while (i < 7) { // 2
				if(i == 6) { // 3
					continue; // 4
				}
				
				i = 5; // 5
			}
			
			i = 10; // 6
		}
	}
	
	public void testContinue4(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			while (i < 7) { // 2
				if(i == 6) { // 3
					continue; // 4
				}
				
				i = 5; // 5
			}
			
			i = 10; // 6
		}
		
		i = i * 10; // 7
	}
}
