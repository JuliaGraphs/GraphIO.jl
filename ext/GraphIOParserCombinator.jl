module GraphIOParserCombinator

using Graphs
import Graphs: loadgraph, loadgraphs, savegraph

using GraphIO
using ParserCombinator
import GraphIO.DOT.DOTFormat
import GraphIO.GML.GMLFormat

function savedot(io::IO, g::AbstractGraph, gname::String="")
    isdir = is_directed(g)
    println(io, (isdir ? "digraph " : "graph ") * gname * " {")
    for i in vertices(g)
        println(io, "\t" * string(i))
    end
    if isdir
        for u in vertices(g)
            out_nbrs = outneighbors(g, u)
            length(out_nbrs) == 0 && continue
            println(io, "\t" * string(u) * " -> {" * join(out_nbrs, ',') * "}")
        end
    else
        for e in edges(g)
            source = string(src(e))
            dest = string(dst(e))
            println(io, "\t" * source * " -- " * dest)
        end
    end
    println(io, "}")
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
    nodedict = Dict(zip(collect(Parsers.DOT.nodes(pg)), 1:nvg))
    if isdir
        g = DiGraph(nvg)
    else
        g = Graph(nvg)
    end
    for es in Parsers.DOT.edges(pg)
        s = nodedict[es[1]]
        d = nodedict[es[2]]
        add_edge!(g, s, d)
    end
    return g
end

function _name(pg::Parsers.DOT.Graph)
    return if pg.id !== nothing
        pg.id.id
    else
        Parsers.DOT.StringID(pg.directed ? "digraph" : "graph")
    end
end

function loaddot(io::IO, gname::String)
    p = Parsers.DOT.parse_dot(read(io, String))
    for pg in p
        _name(pg) == gname && return _dot_read_one_graph(pg)
    end
    return error("Graph $gname not found")
end

function loaddot_mult(io::IO)
    p = Parsers.DOT.parse_dot(read(io, String))
    graphs = Dict{String,AbstractGraph}()

    for pg in p
        graphs[_name(pg)] = _dot_read_one_graph(pg)
    end
    return graphs
end

loadgraph(io::IO, gname::String, ::DOTFormat) = loaddot(io, gname)
loadgraphs(io::IO, ::DOTFormat) = loaddot_mult(io)
savegraph(io::IO, g::AbstractGraph, gname::String, ::DOTFormat) = savedot(io, g, gname)
savegraph(io::IO, d::Dict, ::DOTFormat) = savedot_mult(io, d)

function _gml_read_one_graph(gs, dir)
    nodes = [x[:id] for x in gs[:node]]
    if dir
        g = DiGraph(length(nodes))
    else
        g = Graph(length(nodes))
    end
    mapping = Dict{Int,Int}()
    for (i, n) in enumerate(nodes)
        mapping[n] = i
    end
    sds = [(Int(x[:source]), Int(x[:target])) for x in gs[:edge]]
    for (s, d) in (sds)
        add_edge!(g, mapping[s], mapping[d])
    end
    return g
end

function loadgml(io::IO, gname::String)
    p = Parsers.GML.parse_dict(read(io, String))
    for gs in p[:graph]
        dir = Bool(get(gs, :directed, 0))
        graphname = get(gs, :label, dir ? "digraph" : "graph")

        (gname == graphname) && return _gml_read_one_graph(gs, dir)
    end
    return error("Graph $gname not found")
end

function loadgml_mult(io::IO)
    p = Parsers.GML.parse_dict(read(io, String))
    graphs = Dict{String,AbstractGraph}()
    for gs in p[:graph]
        dir = Bool(get(gs, :directed, 0))
        graphname = get(gs, :label, dir ? "digraph" : "graph")
        graphs[graphname] = _gml_read_one_graph(gs, dir)
    end
    return graphs
end

"""
  savegml(f, g, gname="graph")

Write a graph `g` with name `gname` to an IO stream `io` in the
[GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language) format. Return 1.
"""
function savegml(io::IO, g::AbstractGraph, gname::String="")
    println(io, "graph")
    println(io, "[")
    length(gname) > 0 && println(io, "label \"$gname\"")
    is_directed(g) && println(io, "directed 1")
    for i in 1:nv(g)
        println(io, "\tnode")
        println(io, "\t[")
        println(io, "\t\tid $i")
        println(io, "\t]")
    end
    for e in edges(g)
        s, t = Tuple(e)
        println(io, "\tedge")
        println(io, "\t[")
        println(io, "\t\tsource $s")
        println(io, "\t\ttarget $t")
        println(io, "\t]")
    end
    println(io, "]")
    return 1
end

"""
  savegml_mult(io, graphs)
Write a dictionary of (name=>graph) to an IO stream `io` Return number of graphs written.
"""
function savegml_mult(io::IO, graphs::Dict)
    ng = 0
    for (gname, g) in graphs
        ng += savegml(io, g, gname)
    end
    return ng
end
loadgraph(io::IO, gname::String, ::GMLFormat) = loadgml(io, gname)
loadgraphs(io::IO, ::GMLFormat) = loadgml_mult(io)
savegraph(io::IO, g::AbstractGraph, gname::String, ::GMLFormat) = savegml(io, g, gname)
savegraph(io::IO, d::Dict, ::GMLFormat) = savegml_mult(io, d)

end
