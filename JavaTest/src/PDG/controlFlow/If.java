package PDG.controlFlow;

public class If {
	public void testIf(){
		int i = 0;
		if(i > 0){
			int j = 3;
			System.out.println("first " + i + j);
		}else if(i == -4){
			System.out.println("second");
		}else{
			System.out.println("third");
		}
		System.out.println("End");
	}
	
	public void testIf2(){
		int i = 0;
		if(i > 0){
			int j = 3;
			System.out.println("first " + i + j);
		}else if(i == -4){
			System.out.println("second");
		}else{
			System.out.println("third");
		}
	}
	
	public void testIf3(){
		int i = 0;
		if(i > 0) System.out.println("0");
		System.out.println("1");
	}
	
	public void testIf4(){
		int i = 0;
		if(i > 2){
			System.out.println("1");
			System.out.println("2");
		}
		System.out.println("3");
	}
	
	public void testIf5(){
		int i = 0;
		if(i > 2){
			if(i > 5) {
				System.out.println("1");
				System.out.println("1");
			}
			System.out.println("2");
		}
		System.out.println("3");
	}
	
	public void simpleIf() {
		int x = 0;
		if(x == 0) {
			x++;
		}
		System.out.println("Hello");
	}
	
	public char hardIf() {
		int x = 10;
		
		for(int i = 0; i < 10; i++) { // 0 
			System.out.println("Function"); // 1
	    	if (x < 10) { // 2
	    		boolean what = true; // 3
	    		System.out.println("Function" + what); // 4
	    		continue; // 5
	    	}
	    	else if(x != 10) { // 6
	    		while (x > 10) { // 7
					System.out.println("Function"); // 8
				}
	    		continue; // 9
	    	}
	    	return '/'; // 10
		}
		
		return 'l';
	}
}
