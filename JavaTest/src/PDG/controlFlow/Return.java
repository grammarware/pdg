package PDG.controlFlow;

public class Return {
	public void testReturn1(){
		int i = 0;
		if(i == 2) return;
		System.out.println("i");
	}
	
	public void testReturn2(){
		for(int i = 0; i < 4; i++){
			if(i == 2) return;
			else if(i == 3){
				i += 5;
				System.out.println("else if");
			}
			System.out.println("end");
		}
	}
	
	public int testReturn3(){
		int i = 0;
		switch(i + 1){
			case 0: return 3;
			case 1:{
				int j = 2;
				return j;
			}
			default:{
				System.out.println("default");
				return 0;
			}
		}
	}
}
