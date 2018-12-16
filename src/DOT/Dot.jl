module DOT

using GraphIO.ParserCombinator.Parsers
using LightGraphs
using LightGraphs: AbstractGraphFormat

import LightGraphs: loadgraph, loadgraphs, savegraph

export DOTFormat

struct DOTFormat <: AbstractGraphFormat end

function savedot(io::IO, g::LightGraphs.AbstractGraph, gname::String = "")
    isdir = LightGraphs.is_directed(g)
    head = (isdir ? "digraph " : "graph ") * gname * " {"
    nodes = ""
    for i in LightGraphs.vertices(g)
        nodes = nodes * "\n\t" * string(i) * " [label = " * string(i) * "]"
    end
    edg = ""
    if isdir
        for u in LightGraphs.vertices(g)
            n = LightGraphs.outneighbors(g, u)
            if length(n) == 0
                continue
            end
            s = string(n)
            edg = edg * "\n\t" * string(u) * " -> {" * s[2:length(s)-1] * "}"
        end
    else
        for e in LightGraphs.edges(g)
            source = string(LightGraphs.src(e))
            dest = string(LightGraphs.dst(e))
            edg = edg * "\n\t" * source * " -- " * dest
        end
    end
    dot_string = head * nodes * edg * "\n}\n"
    print(io, dot_string)
    return 1
end

function savedot_mult(io::IO, graphs::Dict)
    ng = 0
    for (gname, g) in graphs
        ng += savedot(io, g, gname)
    end
    return ng
end

function _dot_read_one_graph(pg::Parsers.DOT.Graph)
    isdir = pg.directed
    nvg = length(Parsers.DOT.nodes(pg))
    nodedict = try
            Dict(i => parse(Int64,string(i)) for i in Parsers.DOT.nodes(pg))
        catch
            Dict(zip(collect(Parsers.DOT.nodes(pg)), 1:nvg))
    end
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
savegraph(io::IO, g::AbstractGraph, gname::String, ::DOTFormat) = savedot(io, g, gname)
savegraph(io::IO, d::Dict, ::DOTFormat) = savedot_mult(io, d)

end #module
