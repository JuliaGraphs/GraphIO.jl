# GraphIO

[![Build Status](https://travis-ci.org/JuliaGraphs/GraphIO.jl.svg?branch=master)](https://travis-ci.org/JuliaGraphs/GraphIO.jl)
[![codecov.io](http://codecov.io/github/JuliaGraphs/GraphIO.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/GraphIO.jl?branch=master)

GraphIO provides support to [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl) for reading/writing graphs in various formats.

Currently, the following functionality is provided:

Format        | Read | Write | Multiple Graphs
--------------|------|-------|----------------
[EdgeList]    |   ✓  |  ✓    |
[GML]         |   ✓  |  ✓    | ✓
[Graph6]      |   ✓  |  ✓    | ✓
[GraphML]     |   ✓  |  ✓    | ✓
[Pajek NET]   |   ✓  |  ✓    |
[GEXF]        |      |  ✓    |
[DOT]         |   ✓  |       | ✓
[PSF]         |   ✓  |       |
[CDF]         |   ✓  |       |

[EdgeList]: a simple list of sources and dests separated by whitespace and/or comma, one pair per line.
[GML]: https://en.wikipedia.org/wiki/Graph_Modelling_Language
[Graph6]: https://users.cecs.anu.edu.au/~bdm/data/formats.html
[GraphML]: https://en.wikipedia.org/wiki/GraphML
[Pajek NET]: https://gephi.org/users/supported-graph-formats/pajek-net-format/
[GEXF]: https://gephi.org/gexf/format/
[DOT]: https://en.wikipedia.org/wiki/DOT_(graph_description_language)
