module DOT

using GraphIO.ParserCombinator.Parsers
using LightGraphs
using LightGraphs: AbstractGraphFormat

import LightGraphs: loadgraph, loadgraphs

export DOTFormat

struct DOTFormat <: AbstractGraphFormat end
# TODO: implement save

function _dot_read_one_graph(pg::Parsers.DOT.Graph)
    isdir = pg.directed
    nvg = length(Parsers.DOT.nodes(pg))
    nodedict = Dict(zip(collect(Parsers.DOT.nodes(pg)), 1:nvg))
    if isdir
        g = LightGraphs.DiGraph(nvg)
    else
        g = LightGraphs.Graph(nvg)
    end
    for es in Parsers.DOT.edges(pg)
        s = nodedict[es[1]]
        d = nodedict[es[2]]
        add_edge!(g, s, d)
    end
    return g
end

function loaddot(io::IO, gname::String)
    p = Parsers.DOT.parse_dot(read(io, String))
    for pg in p
        isdir = pg.directed
        possname = isdir ? Parsers.DOT.StringID("digraph") : Parsers.DOT.StringID("graph")
        name = get(pg.id, possname).id
        name == gname && return _dot_read_one_graph(pg)
    end
    error("Graph $gname not found")
end

function loaddot_mult(io::IO)
    p = Parsers.DOT.parse_dot(read(io, String))

    graphs = Dict{String,AbstractGraph}()

    for pg in p
        isdir = pg.directed
        possname = isdir ? Parsers.DOT.StringID("digraph") : Parsers.DOT.StringID("graph")
        name = get(pg.id, possname).id
        graphs[name] = _dot_read_one_graph(pg)
    end
    return graphs
end

loadgraph(io::IO, gname::String, ::DOTFormat) = loaddot(io, gname)
loadgraphs(io::IO, ::DOTFormat) = loaddot_mult(io)

end #module
