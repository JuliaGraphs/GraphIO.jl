module GraphIOGraphMLExt

using Graphs
import Graphs: loadgraph, loadgraphs, savegraph

@static if isdefined(Base, :get_extension)
    using GraphIO
    using EzXML
    import GraphIO.GraphML.GraphMLFormat
else # not required for julia >= v1.9
    using ..GraphIO
    using ..EzXML
    import ..GraphIO.GraphML.GraphMLFormat
end

function _graphml_read_one_graph(reader::EzXML.StreamReader, isdirected::Bool)
    nodes = Dict{String,Int}()
    xedges = Vector{Edge}()
    nodeid = 1
    for typ in reader
        if typ == EzXML.READER_ELEMENT
            elname = EzXML.nodename(reader)
            if elname == "node"
                nodes[reader["id"]] = nodeid
                nodeid += 1
            elseif elname == "edge"
                src = reader["source"]
                tar = reader["target"]
                push!(xedges, Edge(nodes[src], nodes[tar]))
            else
                @warn "Skipping unknown node '$(elname)' - further warnings will be suppressed" maxlog =
                    1 _id = :unknode
            end
        end
    end
    g = (isdirected ? DiGraph : Graph)(length(nodes))
    for edge in xedges
        add_edge!(g, edge)
    end
    return g
end

function loadgraphml(io::IO, gname::String)
    reader = EzXML.StreamReader(io)
    for typ in reader
        if typ == EzXML.READER_ELEMENT
            elname = EzXML.nodename(reader)
            if elname == "graphml"
                # ok
            elseif elname == "graph"
                edgedefault = reader["edgedefault"]
                directed = if edgedefault == "directed"
                    true
                elseif edgedefault == "undirected"
                    false
                else
                    error("Unknown value of edgedefault: $edgedefault")
                end
                if haskey(reader, "id")
                    graphname = reader["id"]
                else
                    graphname = directed ? "digraph" : "graph"
                end
                if gname == graphname
                    return _graphml_read_one_graph(reader, directed)
                end
            elseif elname == "node" || elname == "edge"
                # ok
            else
                @warn "Skipping unknown XML element '$(elname)' - further warnings will be suppressed" maxlog =
                    1 _id = :unkel
            end
        end
    end
    return error("Graph $gname not found")
end

function loadgraphml_mult(io::IO)
    reader = EzXML.StreamReader(io)
    graphs = Dict{String,AbstractGraph}()
    for typ in reader
        if typ == EzXML.READER_ELEMENT
            elname = EzXML.nodename(reader)
            if elname == "graphml"
                # ok
            elseif elname == "graph"
                edgedefault = reader["edgedefault"]
                directed = if edgedefault == "directed"
                    true
                elseif edgedefault == "undirected"
                    false
                else
                    error("Unknown value of edgedefault: $edgedefault")
                end
                if haskey(reader, "id")
                    graphname = reader["id"]
                else
                    graphname = directed ? "digraph" : "graph"
                end
                graphs[graphname] = _graphml_read_one_graph(reader, directed)
            else
                @warn "Skipping unknown XML element '$(elname)' - further warnings will be suppressed" maxlog =
                    1 _id = :unkelmult
            end
        end
    end
    return graphs
end

function savegraphml_mult(io::IO, graphs::Dict)
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("graphml"))
    xroot["xmlns"] = "http://graphml.graphdrawing.org/xmlns"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"

    for (gname, g) in graphs
        xg = addelement!(xroot, "graph")
        xg["id"] = gname
        xg["edgedefault"] = is_directed(g) ? "directed" : "undirected"

        for i in 1:nv(g)
            xv = addelement!(xg, "node")
            xv["id"] = "n$(i-1)"
        end

        m = 0
        for e in edges(g)
            xe = addelement!(xg, "edge")
            xe["id"] = "e$m"
            xe["source"] = "n$(src(e)-1)"
            xe["target"] = "n$(dst(e)-1)"
            m += 1
        end
    end
    prettyprint(io, xdoc)
    return length(graphs)
end

function savegraphml(io::IO, g::AbstractGraph, gname::String)
    return savegraphml_mult(io, Dict(gname => g))
end

loadgraph(io::IO, gname::String, ::GraphMLFormat) = loadgraphml(io, gname)
loadgraphs(io::IO, ::GraphMLFormat) = loadgraphml_mult(io)
function savegraph(io::IO, g::AbstractGraph, gname::String, ::GraphMLFormat)
    return savegraphml(io, g, gname)
end
savegraph(io::IO, d::Dict, ::GraphMLFormat) = savegraphml_mult(io, d)

end
