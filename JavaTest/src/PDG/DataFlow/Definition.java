package PDG.DataFlow;

public class Definition {
	/*
	 * DDG: { <1,2>, <1,6>, <1,2>, <1,3>, <2,4>, <4,5>, <6,6>, <6,8>, <5,8> }
	 */
	public void testDef() {
		int i = 0; // 0
		int j = 3, m = 1; // 1
		
		i = m + 2; // 2
		m++; // 3
		i--; // 4
		i += 1; // 5
		
		for(int p = 0, q = 2; j < 5; q++) { // 6
			System.out.println(i + " " + p + " " + q); // 7. Expands to 8.
		}
	}
}
