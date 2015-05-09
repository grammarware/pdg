package PDG.ControlFlow;

public class Switch {
	public void testSwitch1(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2 
				i = 2; // 3
			case 1: // 4 
				i = 3; // 5
			default: // 6 
				i = 4; // 7
		}
	}
	
	public void testSwitch2(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2 
				i = 2; // 3
			case 1: // 4 
				i = 3; // 5
			default: // 6 
				i = 4; // 7
		}
		
		i = 5; // 8
	}
	
	public void testSwitch3(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2
				i = 2; // 3
				break; // 4
			case 1: // 5
				i = 3; // 6
				break; // 7
			default: // 8
				i = 4; // 9
				break; // 10
		}
	}
	
	public void testSwitch4(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2
				i = 2; // 3
				break; // 4
			case 1: // 5
				i = 3; // 6
				break; // 7
			default: // 8
				i = 4; // 9
				break; // 10
		}
		
		i = 5; // 11
	}
	
	public void testSwitch5(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2
				i = 2; // 3
				break; // 4
			case 1: // 5
				i = 3; // 6
			default: // 7
				i = 4; // 8
				break; // 9
		}	
	}
	
	public void testSwitch6(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2
				i = 2; // 3
				break; // 4
			case 1: // 5
				i = 3; // 6
			default: // 7
				i = 4; // 8
				break; // 9
		}
		
		i = 5; // 10
	}
	
	public void testSwitch7(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2 
				i = 2; // 3
			case 1: // 4 
				i = 3; // 5
			case 2: // 6 
				i = 4; // 7
		}
	}
	
	public void testSwitch8(){
		int i = 0; // 0
		
		switch(i) { // 1
			case 0: // 2 
				i = 2; // 3
			case 1: // 4 
				i = 3; // 5
			case 2: // 6 
				i = 4; // 7
		}
		
		i = 5; // 8
	}
}
