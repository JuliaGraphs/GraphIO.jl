# GraphIO

[![Build Status](https://github.com/JuliaGraphs/GraphIO.jl/workflows/CI/badge.svg)](https://github.com/JuliaGraphs/GraphIO.jl/actions?query=workflow%3ACI+branch%3Amaster)
[![codecov.io](http://codecov.io/github/JuliaGraphs/GraphIO.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaGraphs/GraphIO.jl?branch=master)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

GraphIO provides support to [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl) for reading/writing graphs in various formats.

Currently, the following functionality is provided:

| Format        | Read | Write | Multiple Graphs | Format Name    | Simple(Di)Graph | MetaGraphs.jl |
| -----------   | ---- | ----- | --------------- | -------------- | --------------- | ------------- |
| EdgeList [^1] | ✓    | ✓     |                 | EdgeListFormat |  ✓              |               |
| [GML]         | ✓    | ✓     | ✓               | GMLFormat      |  ✓              |               |
| [Graph6]      | ✓    | ✓     | ✓               | Graph6Format   |  ✓              |               |
| [GraphML]     | ✓    | ✓     | ✓               | GraphMLFormat  |  ✓              |  ✓            |
| [Pajek NET]   | ✓    | ✓     |                 | NETFormat      |  ✓              |               |
| [GEXF]        |      | ✓     |                 | GEXFFormat     |  ✓              |               |
| [DOT]         | ✓    |       | ✓               | DOTFormat      |  ✓              |               |
| [CDF]         | ✓    |       |                 | CDFFormat      |  ✓              |               |


[^1]: a simple list of sources and dests separated by whitespace and/or comma, one pair per line.

Graphs are read using either the `loadgraph` function or, for formats that support multiple graphs in a single file,
the `loadgraphs` functions. `loadgraph` returns a Graph object, while `loadgraphs` returns a dictionary of Graph objects.

For example, an edgelist file could be loaded as:

```julia
graph = loadgraph("path_to_graph/my_edgelist.txt", "graph_key", EdgeListFormat())
``` 

## Reading different graph types

All `*Format` types are readily accessible.
However, in order to use some of them with `loadgraph`, additional packages are required.
You may thus need to install and load the following dependencies before using parts of GraphIO.jl:
- Reading [DOT] or [GML] files: do `using ParserCombinator`
- Reading [GEXF] or [GraphML] files: do `using EzXML`
- Reading [GML] files: do `using CodecZlib`

The current design avoids populating your environment with unnecessary dependencies.

> **_IMPLEMENTATION NOTE:_**
> The current design uses package extensions, introduced in Julia v1.9.
> At the moment, package extensions cannot conditionally load types, that is one of the main reasons why all `*Format` types are readily accessible. 
> However, the functionality of `loadgraph` is extended for the various types only when the appropriate dependencies are available.
> We are searching for more intuitive ways to design this interface.

[CDF]: http://www2.ee.washington.edu/research/pstca/formats/cdf.txt
[GML]: https://en.wikipedia.org/wiki/Graph_Modelling_Language
[Graph6]: https://users.cecs.anu.edu.au/~bdm/data/formats.html
[GraphML]: https://en.wikipedia.org/wiki/GraphML
[Pajek NET]: https://gephi.org/users/supported-graph-formats/pajek-net-format/
[GEXF]: https://gephi.org/gexf/format/
[DOT]: https://en.wikipedia.org/wiki/DOT_(graph_description_language)
