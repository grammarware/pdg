package PDG.ControlFlow;

public class This {
	private int i;
	
	public This() {
		this(2);
		i += 4;
		System.out.println(i);
		
	}
	
	public This(int x) {
		i = x;
		System.out.println(i);
	}
}
