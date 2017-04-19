__precompile__(true)
module GraphIO

using LightGraphs

#### Remove this after LightGraphs v0.9
if isdefined(LightGraphs, :AbstractGraphFormat)
    import LightGraphs: AbstractGraphFormat
else
    abstract type AbstractGraphFormat end
end

import LightGraphs: loadgraph, loadgraphs, savegraph
using EzXML
using ParserCombinator: Parsers.DOT, Parsers.GML

export DOTFormat, GEXFFormat, GMLFormat, Graph6Format, GraphMLFormat, NETFormat
# package code goes here

include("jld.jl")
include("dot.jl")
include("gexf.jl")
include("gml.jl")
include("graph6.jl")
include("graphml.jl")
include("net.jl")

end # module
