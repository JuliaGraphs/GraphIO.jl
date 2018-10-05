module GraphIO

using LightGraphs
using SimpleTraits

import LightGraphs: loadgraph, loadgraphs, savegraph, AbstractGraphFormat
using EzXML
using ParserCombinator.Parsers.DOT
using ParserCombinator.Parsers.GML
using CodecZlib

export DOTFormat, GEXFFormat, GMLFormat, Graph6Format,
GraphMLFormat, NETFormat, EdgeListFormat, CDFFormat,
LGCompressedFormat
# package code goes here

#include("jld.jl")
include("lgcompressed.jl")
include("dot.jl")
include("gexf.jl")
include("gml.jl")
include("graph6.jl")
include("graphml.jl")
include("net.jl")
include("edgelist.jl")
include("cdf.jl")

end # module
