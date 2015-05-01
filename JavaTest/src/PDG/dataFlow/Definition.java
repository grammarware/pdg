package PDG.dataFlow;

public class Definition {
	public void testDef(){
		int i = 0;
		int j= 3, m = 1;
		i = m + 2;
		m++;
		i--;
		i += 1;
		for(int p = 0, q = 2; j < 5; q++){
			System.out.println(i + " " + p + " " + q);
		}

	}
}
