# GraphIO

[![Build Status](https://travis-ci.org/JuliaGraphs/GraphIO.jl.svg?branch=master)](https://travis-ci.org/JuliaGraphs/GraphIO.jl)

[![Coverage Status](https://coveralls.io/repos/JuliaGraphs/GraphIO.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaGraphs/GraphIO.jl?branch=master)

[![codecov.io](http://codecov.io/github/JuliaGraphs/GraphIO.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/GraphIO.jl?branch=master)

GraphIO provides support to [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl) for reading/writing graphs in various formats.

Currently, the following functionality is provided:

Format        | Read | Write
--------------|------|------
[GML]         |   ✓  |  ✓
[Graph6]      |   ✓  |  ✓
[GraphML]     |   ✓  |  ✓
[Pajek NET]   |   ✓  |  ✓
[GEXF]        |      |  ✓
[DOT]         |   ✓  |

[GML]: https://en.wikipedia.org/wiki/Graph_Modelling_Language
[Graph6]: https://users.cecs.anu.edu.au/~bdm/data/formats.html
[GraphML]: https://en.wikipedia.org/wiki/GraphML
[Pajek NET]: https://gephi.org/users/supported-graph-formats/pajek-net-format/
[GEXF]: https://gephi.org/gexf/format/
[DOT]: https://en.wikipedia.org/wiki/DOT_(graph_description_language)
