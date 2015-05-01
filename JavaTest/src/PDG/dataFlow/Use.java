package PDG.dataFlow;

public class Use {
	public void testUse1(){
		int i = 0;
		int j = i + 1;
		for(int m = 0; m < j; m++){
			System.out.println(m + i + j);
		}
	}
	
	public int testUse2(){
		int i = 0;
		int j = 4;
		while(i < j){
			j = j - i - 1;
			System.out.println(i++);
		}
		return i + j;
	}
	
	public void testUse3() {
		int arraySize = 10;
		int[] arr1 = new int[arraySize];
		int[] arr2 = new int[10];
		int i = 3;
		int x = 5;
		
		arr1[i] = i * x;
		arr2[x] = arr1[i] * i;
		
	}
	
	public void testUse4() {
		int[] arr1 = new int[10];
		arr1[2] = 4;
		
		arr1[3] = arr1[2];
		
		arr1[4] = 3 + arr1[5];
	}
}
