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

public void showGraphs() = showGraphs(|project://JavaTest/src/PDG/Sum.java|, 0);

public void showGraphs(loc project, int methNum)
{
	render("Choose", vcat([
			box(text("Choose the graph to display:", font("GillSans"), fontSize(30), fontColor("white")), fillColor("black"), vresizable(false), vsize(75)),
			grid([[
					makeBox("Control Flow Graph", openGraph(project, methNum, CFG())),
					makeBox("Post-Dominator Tree", openGraph(project, methNum, PDT()))
				],[
					makeBox("Control Dependence Graph", openGraph(project, methNum, CDG())),
					makeBox("Data Dependence Graph", openGraph(project, methNum, DDG()))
				]], gap(20)),
			makeBox("Program Dependence Graph", openGraph(project, methNum, PDG()))
		], gap(20), resizable(false)));	
}

Figure makeBox(str title, Handler h)
	= box(text(title, font("GillSans"), fontSize(30), fontColor("white")), fillColor("darkblue"), onMouseDown(h), vresizable(false), vsize(75), gap(10));

private Handler openGraph(loc project, int methNum, KindOfGraph graphType) =
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

