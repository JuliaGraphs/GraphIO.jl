# GraphIO

[![Build Status](https://github.com/JuliaGraphs/GraphIO.jl/workflows/CI/badge.svg)](https://github.com/JuliaGraphs/GraphIO.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![codecov.io](http://codecov.io/gh/JuliaGraphs/GraphIO.jl/branch/master/graph/badge.svg)](http://codecov.io/gh/JuliaGraphs/GraphIO.jl)

GraphIO provides support to [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl) for reading/writing graphs in various formats.

The current version of GraphIO works with Julia version >= 1.0.

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
the `loadgraphs` functions. `loadgraph` returns a LightGraph object, while `loadgraphs` returns a dictionary of LightGraph objects.

For example, an edgelist file could be loaded as:

```
graph = loadgraph("path_to_graph/my_edgelist.txt", "graph_key", EdgeListFormat())
```


