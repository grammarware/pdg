package PDG;

public class Main {
	public static void main(String[] args){
		int i = 1;
		
		while(i < 11) {
			i = A(i);
		}
	}
	
	public static int A(int y) {
		return Increment(y);
	}
	
	public static int Increment(int z) {
		return Add(z, 1);
	}
	
	public static int Add(int a, int b) {
		return a + b;
	}
}
