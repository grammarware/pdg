#Program Dependence Graph
####UvA Software Engineering Master Project
####Lulu Zhang (10630856)

This is the PDG library in Rascal. *PDG.rsc* is the main module which combines the information of control dependences and data dependences. Here are the packages/folders in this library:

  - *ControlDependence* : generates control flow of the source code and computes control dependences based on control flow and its post-dominator tree;
  
  - *DataDependence* : computes reaching definitions and definition-use pairs (which is data dependences) based on control flow;
  
  - *Statement* : There is only one module in this package/folder which extracts *DEF*, *GEN* and *USE* for the further use in *DataDependence*;
  
  - *Utils* : defines some functions for *List*, *Map*, etc. which are commonly used in this project;
  
  - *Tests* : The modules inside cover some common and uncommon statement combinations to test the correctness of this library. All the tests here expect *TestCDG* use Rascal testing framework;
  
  - *Visualization* : displays all the graphs. *Vis.rsc* is the main visualization module.
