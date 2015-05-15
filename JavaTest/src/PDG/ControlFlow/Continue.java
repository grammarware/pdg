package PDG.ControlFlow;

public class Continue {
	/*
	 * PDT: { <EXITNODE,ENTRYNODE>, <EXITNODE,1>, <1,4>, <1,3>, <1,2>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <2,4> }
	 */
	public void testContinue1(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			if(i == 6) { // 2
				continue; // 3
			}
			
			i = 10; // 4
		}
	}
	
	/*
	 * PDT: { <EXITNODE,ENTRYNODE>, <EXITNODE,5>, <5,1>, <1,4>, <1,3>, <1,2>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <2,4>, <ENTRYNODE, 5> }
	 */
	public void testContinue2(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			if(i == 6) { // 2
				continue; // 3
			}
			
			i = 10; // 4
		}
		
		i = i * 10; // 5
	}
	
	/*
	 * PDT: { <EXITNODE,ENTRYNODE>, <EXITNODE,1>, <2,5>, <2,4>, <2,3>, <6,2>, <1,6>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <3,4>, <3,5>, <1,6> }
	 */
	public void testContinue3(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			while (i < 7) { // 2
				if(i == 6) { // 3
					continue; // 4
				}
				
				i = 5; // 5
			}
			
			i = 10; // 6
		}
	}
	
	/*
	 * PDT: { <EXITNODE,ENTRYNODE>, <EXITNODE,7>, <7,1>, <6,2>, <2,5>, <2,4>, <2,3>, <1,6>, <1,0>, <0,STARTNODE> }
	 * CDG: { <ENTRYNODE, 0>, <ENTRYNODE, 1>, <1,2>, <2,3>, <3,4>, <3,5>, <1,6>, <ENTRYNODE, 7> }
	 */
	public void testContinue4(){
		int i = 0; // 0
		
		while(i < 10) { // 1
			while (i < 7) { // 2
				if(i == 6) { // 3
					continue; // 4
				}
				
				i = 5; // 5
			}
			
			i = 10; // 6
		}
		
		i = i * 10; // 7
	}
}
