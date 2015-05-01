package PDG.controlFlow;

public class ComStatements {
	public void test1(){
		int i = 0;
		if(i > 3){
			for(int j = 0; j <= i; j++){
				System.out.println(j);
			}
			System.out.println("end for");
		}else{
			while(i < 9){
				System.out.println(i);
				i += 3;
			}
		}
		System.out.println("End");
	}
	
	public int test2(){
		int i = 3;
		int j = 4;
		switch(i+1){
			case 4: {
				if(j == 4) return 4;
				else{
					System.out.println("-4");
					return -4;
				}
			}
			case 5: return 5;
			default:{
				i++;
				return 6;
			}
		}
	}
}
