package PDG.ControlFlow;

public class Compounds {
	/*
	 * PDT: { <EXITNODE,ENTRYNODE>, <EXITNODE,8>, <5,7>, <7,6>, <8,5>, <8,4>, <2,3>, <4,2>, <8,1>, <1,0>, <0,STARTNODE> }
	 */
	public void testCompound1(){
		int i = 0; // 0
		
		if(i > 3) { // 1
			for(int j = 0; j <= i; j++) { // 2
				i++; // 3
			}
			
			i = i - 2; // 4
		} else {
			while(i < 9) { // 5
				i = i * 2; // 6
				i += 3; // 7
			}
		}
		
		i = 42; // 8
	}
	
	/*
	 * PDT: { <EXITNODE,ENTRYNODE>, <EXITNODE,18>, <18,17>, <17,16>, <16,15>, <15,14>, <18,13>, <13,12>, <12,11>, 
	 * 			<18,10>, <10,9>, <9,8>, <8,7>, <18,6>, <6,5>, <18,4>, <4,3>, <18,2>, <1,0>, <2,1>, <0,STARTNODE> }
	 */
	public int testCompound2(){ // Expands to 18 for return.
		int i = 3; // 0
		int j = 4; // 1
		
		switch(i+1) { // 2
			case 4: { // 3
				if(j == 4) { // 4
					return 4; // 5. Expands to 6 too.
				}
				else {
					System.out.println("-4"); // 7. Expands to 8 too.
					return -4; // 9. Expands to 10 too.
				}
			}
			case 5: { // 11
				return 5; // 12. Expands to 13 too.
			}
			default: { // 14 
				i++; // 15
				return 6; // 16. Expands to 17 too.
			}
		}
	}
}
