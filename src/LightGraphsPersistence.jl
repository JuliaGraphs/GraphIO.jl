__precompile__ = true
module LightGraphsPersistence

using LightGraphs
using EzXML
using ParserCombinator: Parsers.DOT, Parsers.GML


# package code goes here

include("common.jl")
include("jld.jl")
include("dot.jl")
include("gexf.jl")
include("gml.jl")
include("graph6.jl")
include("graphml.jl")
include("net.jl")

end # module
