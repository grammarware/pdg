package PDG.ControlFlow;

public class Break {
	public void testBreak1(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			if(i == 6) { // 2
				break; // 3
			}
			
			i = 10; // 4
		}
	}
	
	public void testBreak2(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			if(i == 6) { // 2
				break; // 3
			}
			
			i = 10; // 4
		}
		
		i = i * 10; // 5
	}
	
	public void testBreak3(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			while (i < 7) { // 2
				if(i == 6) { // 3
					break; // 4
				}
				
				i = 5; // 5
			}
			
			i = 10; // 6
		}
	}
	
	public void testBreak4(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			while (i < 7) { // 2
				if(i == 6) { // 3
					break; // 4
				}
				
				i = 5; // 5
			}
			
			i = 10; // 6
		}
		
		i = i * 10; // 7
	}
}
