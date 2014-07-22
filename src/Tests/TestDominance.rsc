module Tests::TestDominance

import ADT;
import ControlDependence::Dominance;

test bool testDominance1(){
	flow = [<5, 4>, <5, 3>, <4, 1>, <3, 2>, <1, 2>, <2, 1>];
	doms = buildDominance(flow, 5, 5);
	return (doms[5] == 5) && (doms[4] == 5) && (doms[3] == 5) && (doms[2] == 5) && (doms[1] == 5);
}

test bool testDominance2(){
	flow = [<6, 5>, <6, 4>, <4, 3>, <4, 2>, <5, 1>, <1, 2>, <2, 1>, <2, 3>, <3, 2>];
	doms = buildDominance(flow, 6, 6);
	return (doms[6] == 6) && (doms[5] == 6) && (doms[4] == 6) && (doms[3] == 6) && (doms[2] == 6) && (doms[1] == 6);
}

test bool testDominance3(){
	flow = [<0, 1>, <1, 2>, <0, 2>, <2, 3>, <1, 3>, <1, 5>, <3, 4>, <5, 6>, <4, 6>, <6, 5>, <0, 7>, <7, 8>, <7, 9>, <8, 10>, <9, 10>, <9, 11>, <11 ,10>, <10, 12>, <12, 10>, <6, 12>, <12, 0>];
	doms = buildDominance(flow, 0, 13);
	return (doms[0] == 0) && (doms[1] == 0) && (doms[2] == 0) &&
			(doms[3] == 0) && (doms[4] == 3) && (doms[5] == 0) &&
			(doms[6] == 0) && (doms[7] == 0) && (doms[8] == 7) &&
			(doms[9] == 7) && (doms[10] == 0) && (doms[11] == 9) && (doms[12] == 0);
}