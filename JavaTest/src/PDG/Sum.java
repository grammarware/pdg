package PDG;

public class Sum {
	public void testIO(){
		int n = 0;
		int i = 1;
		int sum = 0;
		while(i <= n){
			sum = 0;
			int j = 1;
			while(j <= i){
				sum = sum + j;
				j = j + 1;
			}
			System.out.println(sum + i);
			i = i + 1;
		}
		System.out.println(sum + i);
	}
	
	public void testPDT() {
		int i, pdtTest;
		
		i = pdtTest = 5;
		
		if(pdtTest != i) {
			while(pdtTest == 3) {
				if(pdtTest == 3) {
					i = 4;
					System.out.println("Then");
				} else {
					System.out.println("Else");
				}
				continue;
			}
			System.out.println("End if");
		}
		
		System.out.println("End");
	}
	
	public void testPDT2() {
		int i = 2;
		if(i != 3) {
			if(i == 2) {
				System.out.println("Then");
			} else {
				System.out.println("Else");
			}
			System.out.println("End if");
		}
		System.out.println("Waddap");
	}
	
	public void testCDG() {
		int i = 4;
		
		if(i == 5) {
			System.out.println("Print something bro.");
			System.out.println("Print something bro.");
		} else {
			System.out.println("Printing out shit.");
			System.out.println("Printing out shit.");
		}
		
		System.out.println("Merge");
		System.out.println("End");
	}
}