module GraphIODOTExt

using Graphs
import Graphs: loadgraph, loadgraphs, savegraph

@static if isdefined(Base, :get_extension)
    using GraphIO
    using ParserCombinator
    import GraphIO.DOT.DOTFormat
else # not required for julia >= v1.9
    using ..GraphIO
    using ..ParserCombinator
    import ..GraphIO.DOT.DOTFormat
end

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

end
