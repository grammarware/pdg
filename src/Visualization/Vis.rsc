module Visualization::Vis

import Visualization::CDGvis;
import Visualization::CFGvis;
import Visualization::DDGvis;
import Visualization::PDGvis;
import Visualization::PDTvis;
import vis::Render;
import vis::Figure;
import vis::KeySym;
import Types;

//showGraphs(|project://JavaTest/src/PDG/Sum.java|, 0);
public void showGraphs(loc project, int methNum)
{
	Figure smile = box(overlay([ellipse(text("Program Dependence Graph", align(0.5, 0.94), fontSize(15)), shrink(0.6,0.9), fillColor("hotpink"), lineColor("white")),
					ellipse(shrink(0.7,0.83), fillColor("white"), align(0.5, 0.0), lineColor("white"))]), 
					hsize(600), vsize(200), resizable(false), lineColor("white"), onMouseDown(openGraph(project, methNum, PDG() )));
	render ("Choose Graph", vcat([text("Which one do you want to see? ^-^\n",font("monaco"),fontSize(20)), graphs(project, methNum), smile], gap(10), resizable(false)));	
}

private Figure graphs(loc project, int methNum)
{
	Figure ecliCFG = box(ellipse(text("Control Flow Graph", fontSize(15)), fillColor("lightskyblue"),lineColor("white"), onMouseDown(openGraph(project, methNum, CFG()))), lineColor("white"), vresizable(false), vsize(200));
	Figure ecliPDT = box(ellipse(text("Post-Dominator Tree", fontSize(15)), fillColor("lightskyblue"), lineColor("white"), onMouseDown(openGraph(project, methNum, PDT()))), lineColor("white"), vresizable(false), vsize(200));
	Figure ecliCDG = box(ellipse(text("Control Dependence Graph", fontSize(15)), fillColor("pink"), lineColor("white"), onMouseDown(openGraph(project, methNum, CDG())), vresizable(false), vsize(30)), lineColor("white"));
	Figure ecliDDG = box(ellipse(text("Data Dependence Graph", fontSize(15)), fillColor("pink"), lineColor("white"), onMouseDown(openGraph(project, methNum, DDG())), vresizable(false), vsize(30)), lineColor("white"));
	rows = grid([[ecliCFG, ecliPDT],[ecliCDG, ecliDDG]], lineColor("white"), vgap(10), hgap(50));
	return box(rows, hsize(600), hresizable(false), lineColor("white"));
}

private bool(int button, map[KeyModifier,bool] modifiers) openGraph(loc project, int methNum, KindOfGraph graphType) =
	bool(int button, map[KeyModifier,bool] modifiers)
	{ 
		if(button == 1) 
		{
			display(project, methNum, graphType);
			return true;
		}
		return false;	
	};
	
private void display(loc project, int methNum, PDG()) = displayPDG(project, methNum);
private void display(loc project, int methNum, CDG()) = displayCDG(project, methNum);
private void display(loc project, int methNum, CFG()) = displayCFG(project, methNum);
private void display(loc project, int methNum, DDG()) = displayDDG(project, methNum);
private void display(loc project, int methNum, PDT()) = displayPDT(project, methNum);

