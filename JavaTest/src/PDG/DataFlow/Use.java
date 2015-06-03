package PDG.DataFlow;

public class Use {
	/*
	 * DDG: { <0,1>, <1,2>, <2,2>, <0,4>, <1,4>, <2,4> }
	 */
	public void testUse1(){
		int i = 0; // 0
		int j = i + 1; // 1
		
		for(int m = 0; m < j; m++) { // 2
			System.out.println(m + i + j); // 3. Expands to 4.
		}
	}
	
	/*
	 * DDG: { <0,2>, <1,2>, <0,3>, <1,3>, <3,2>, <3,3>, <0,5>, <5,5>, <5,7>, <5,2>, <5,3>, <0,7>, <1,7>, <3,7>, <7,8> }
	 */
	public int testUse2() { // Expands to 8.
		int i = 0; // 0
		int j = 4; // 1
		
		while(i < j) { // 2
			j = j - i - 1; // 3
			System.out.println(i++); // 4. Expands to 5.
		}
		
		return i + j; // 6. Expands to 7.
	}
	
	/*
	 * DDG: { <0,1>, <1,5>, <2,6>, <3,5>, <3,6>, <4,5>, <4,6>, <5,6>, <1,6> }
	 */
	public void testUse3() {
		int arraySize = 10; // 0
		int[] arr1 = new int[arraySize]; // 1
		int[] arr2 = new int[10]; // 2
		int i = 3; // 3
		int x = 5; // 4
		
		arr1[i] = i * x; // 5
		arr2[x] = arr1[i] * i; // 6
		
	}
	
	/*
	 * DDG: { <0,1>, <0,2>, <0,3>, <1,2> }
	 */
	public void testUse4() {
		int[] arr1 = new int[10]; // 0
		
		arr1[2] = 4; // 1
		arr1[3] = arr1[2]; // 2
		arr1[4] = 3 + arr1[5]; // 3
	}
	
	int[] globalArray = new int[10];

	public void testUse5() {
		globalArray[4] = 5;
		globalArray[5] = globalArray[3];
	}
	
	public void testUse6() {
		int i = Integer.MAX_VALUE;
		
		System.out.println(i + Integer.BYTES);
	}
}
