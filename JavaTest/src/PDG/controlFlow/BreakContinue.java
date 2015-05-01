package PDG.controlFlow;

public class BreakContinue {
	public void testBreak1(){
		for(int i = 0; i < 9; i++){
			if(i== 6){
				System.out.println("break");
				break;
			}
			System.out.println(i);
		}
		System.out.println("end");
	}
	
	
	public void testContinue1(){
		for(int i = 0; i < 9; i++){
			if(i== 6){
				System.out.println("continue");
				continue;
			}
			System.out.println(i);
		}
		System.out.println("end");
	}
	
	public void testBreakContinue1(){
		int i = 0; // 0
		while(i < 9){ // 1
			if(i == 3){ // 2
				i = 5; // 3
				continue; // 4 
			}else if(i == 5) { // 5
				break; // 6
			}
			i++; // 7
		}
		System.out.println("while"); // 8
	}
	
	public void testBreakContinue2(){
		for(int i = 0; i < 6; i++){
			int j = 3;
			while(i < j){
				if(i == j) break;
				j--;
			}
			if(i == 1){
				System.out.println("continue");
				continue;
			}
			else if(i == 4) break;
			System.out.println("loop2");
		}
	}
	
	public void testBreakContinue7(){
		for(int i = 0; i < 5; i++){
			if(i == 3) break;
			else continue;
		}
		System.out.println("while");
	}
}
