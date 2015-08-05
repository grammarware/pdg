#Detecting Refactored Clone with RASCAL
#### [UvA](http://www.uva.nl/en/home) [Software Engineering Master](http://www.software-engineering-amsterdam.nl/) [Project](http://grammarware.net/edits/#Zhang2014)

### Contributors:
* [René Bulsing] (https://github.com/RB-Develop)
* [Lulu Zhang](http://github.com/lulu516)
* [Vadim Zaytsev](http://github.com/grammarware)

----------

##Project contains:
* Control Flow Graph module. (Unit-tests)
* Post Dominator Tree module. (Unit-tests)
* Control Dependence Graph module. (Unit-tests)
* Data Dependence Graph module. (Unit-tests)
* Program Dependence Graph module.
* System Dependence Graph module.
* Flow creator (based on Cider matching algorithm).
* Flow matcher (and thus detecting refactored, interprocedural clones).

The contained project called JavaTest has simple unit tests to cover basic graph creation.

```
@misc{PDGHub,
        author = "René Bulsing and Lulu Zhang and Vadim Zaytsev",
        title = "{Program Dependence Graph library in Rascal\footnote{The authors are given according to the list of contributors at \url{http://github.com/grammarware/pdg/graphs/contributors}.}}",
        note = "\url{https://github.com/grammarware/pdg}",
        year = 2015
}
```
