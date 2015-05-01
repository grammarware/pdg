package PDG.controlFlow;

public class Switch {
	public void testSwitch1(){
		int i = 0;
		switch(i){
			case 0: System.out.println("0");
			case 1: System.out.println("1");
			default: System.out.println("default");
		}
	}
	
	public void testSwitch2(){
		int i = 0;
		switch(i){
			case 0:
				System.out.println("0");
				break;
			case 1: 
				System.out.println("1");
				break;
			default: 
				System.out.println("default");
				break;
		}
	}
	
	public void testSwitch3(){
		int i = 0;
		switch(i+1){
			case 0: 
				System.out.println("0");
				break;
			case 1:
				System.out.println("1");
			case 2:
				System.out.println("2");
				break;
			default:
				System.out.println("default");
		}	
	}
}
