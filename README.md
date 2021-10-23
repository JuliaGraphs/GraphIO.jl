# GraphIO

[![Build Status](https://github.com/JuliaGraphs/GraphIO.jl/workflows/CI/badge.svg)](https://github.com/JuliaGraphs/GraphIO.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![codecov.io](http://codecov.io/github/JuliaGraphs/GraphIO.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/GraphIO.jl?branch=master)

GraphIO provides support to [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) for reading/writing graphs in various formats.

The current version of GraphIO works with Julia version >= 1.6.

Currently, the following functionality is provided:

Format        | Read | Write | Multiple Graphs| Format Name  |
--------------|------|-------|----------------|--------------|
[EdgeList]    |   ✓  |  ✓    |                |EdgeListFormat|
[GML]         |   ✓  |  ✓    | ✓              |GMLFormat     |
[Graph6]      |   ✓  |  ✓    | ✓              |Graph6Format  |
[GraphML]     |   ✓  |  ✓    | ✓              |GraphMLFormat |
[Pajek NET]   |   ✓  |  ✓    |                |NETFormat     |
[GEXF]        |      |  ✓    |                |GEXFFormat    |
[DOT]         |   ✓  |       | ✓              |DOTFormat     |
[CDF]         |   ✓  |       |                |CDFFormat     |

[EdgeList]: a simple list of sources and dests separated by whitespace and/or comma, one pair per line.
[GML]: https://en.wikipedia.org/wiki/Graph_Modelling_Language
[Graph6]: https://users.cecs.anu.edu.au/~bdm/data/formats.html
[GraphML]: https://en.wikipedia.org/wiki/GraphML
[Pajek NET]: https://gephi.org/users/supported-graph-formats/pajek-net-format/
[GEXF]: https://gephi.org/gexf/format/
[DOT]: https://en.wikipedia.org/wiki/DOT_(graph_description_language)

Graphs are read using either the `loadgraph` function or, for formats that support multiple graphs in a single file,
the `loadgraphs` functions. `loadgraph` returns a Graph object, while `loadgraphs` returns a dictionary of Graph objects.

For example, an edgelist file could be loaded as:

```
graph = loadgraph("path_to_graph/my_edgelist.txt", "graph_key", EdgeListFormat())
``` 


