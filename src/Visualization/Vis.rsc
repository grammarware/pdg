module Visualization::Vis

import Visualization::CDGvis;
import Visualization::CFvis;
import Visualization::DDGvis;
import Visualization::PDGvis;
import Visualization::PDTvis;

data GraphType = PDG() | CDG() | CFG() | DDG() | PDT();

//display(|project://JavaTest/src/PDG/Sum.java|, CDG());
public void display(loc project, PDG()) = displayPDG(project);
public void display(loc project, CDG()) = displayCDG(project);
public void display(loc project, CFG()) = displayCFG(project);
public void display(loc project, DDG()) = displayDDG(project);
public void display(loc project, PDT()) = displayPDT(project);

