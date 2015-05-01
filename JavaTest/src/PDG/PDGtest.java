package PDG;

import java.util.Arrays;
import java.util.Scanner;

public class PDGtest {
	public void testPDG1(String[] args) {
		float[] arr ;
		Scanner scan = new Scanner(System.in);
		int len = scan.nextInt();
		int task = 0;
		double area = 0;
		for(int k=0;k<len;k++){
			int Num = scan.nextInt();
			arr=new float[Num];
			for (int i = 0; i < Num; i++) {
				float n = scan.nextFloat();
				arr[i] = n;
			}
			Arrays.sort(arr);
			double s = 0;
			for (int j = arr.length - 1; j >= 0; j--) {
				float r = arr[j];
				s = 2 * 2 * Math.sqrt(Math.pow(r, 2) - 1);
				area = area + s;
				task = task + 1;
				if (area >= 40) {
					System.out.println(task);
					break;
				}
			}
			task = 0;
			area = 0;
		}
		scan.close();
	}
	
	public void testPDG2() {
		int sum = 0;
		int i = 1;
		
		while(i < 11) {
			sum = sum + i;
			i = i + 1;
		}
	}
}