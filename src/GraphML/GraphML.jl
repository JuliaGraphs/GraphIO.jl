module GraphML

using GraphIO.EzXML
using Graphs
using Graphs: AbstractGraphFormat

import Graphs: loadgraph, loadgraphs, savegraph

using MetaGraphs

export GraphMLFormat


# TODO: implement writing a dict of graphs

struct GraphMLFormat <: AbstractGraphFormat end

@enum GraphMLAttributesDomain atgraph atnode atedge atall
const graphMLAttributesDomain = Dict("graph" => atgraph,
                                      "node" => atnode,
                                      "edge" => atedge,
                                      "all" => atall)

@enum GraphlMLAttributesType atboolean atint atlong atfloat atdouble atstring
const graphMLAttributesType = Dict("int" => Int,
                                   "boolean" => Bool,
                                   "long" => Int128,
                                   "float" => Float64,
                                   "double" => Float64,
                                   "string" => String)

struct AttrKey{T}
    id::String
    name::String
    domain::GraphMLAttributesDomain
    type::Type{T}
    default::Union{T,Nothing}
end

function _get_key_props(doc::EzXML.Document)
    ns = namespace(doc.root)
    keynodes = findall("//x:key", doc.root, ["x"=>ns])
    keyprops = Dict{String,AttrKey}()
    for keynode in keynodes
        attrtype = graphMLAttributesType[strip(keynode["attr.type"])]
        keyadded = false
        for childnode in EzXML.eachnode(keynode)
            if EzXML.nodename(childnode) == "default"
                defaultcontent = strip(nodecontent(childnode))
                keyprops[keynode["id"]] = AttrKey(keynode["id"], keynode["attr.name"], graphMLAttributesDomain[keynode["for"]], attrtype, attrtype == String ? defaultcontent : parse(attrtype, defaultcontent) )
                keyadded = true
            end
        end
        if !keyadded
            keyprops[keynode["id"]] = AttrKey(keynode["id"], keynode["attr.name"], graphMLAttributesDomain[keynode["for"]], attrtype, nothing )
        end
    end
    return keyprops
end

function _loadmetagraph_fromnode(graphnode::EzXML.Node, keyprops::Dict{String, AttrKey})
    ns = namespace(graphnode)
    gr = graphnode["edgedefault"] == "directed" ? MetaDiGraph() : MetaGraph()
    set_indexing_prop!(gr, :id)
    defaults = [v for v in values(keyprops) if getfield(v,:default) !== nothing && getfield(v,:domain) == atnode]
    for (i,node) in enumerate(findall("x:node", graphnode, ["x"=>ns]))
        add_vertex!(gr)
        set_prop!(gr, i, :id, node["id"])
        for def in defaults
            set_prop!(gr, i, Symbol(def.name), def.default)
        end
        for data in findall("x:data", node, ["x"=>ns])
            set_prop!(gr, i, Symbol(keyprops[data["key"]].name), keyprops[data["key"]].type == String ? nodecontent(data) : parse(keyprops[data["key"]].type, nodecontent(data)))
        end
    end

    defaults = [v for v in values(keyprops) if getfield(v,:default) !== nothing && getfield(v,:domain) == atedge]
    for edge in findall("x:edge", graphnode, ["x"=>ns])
        srcnode = gr[edge["source"],:id]
        trgnode = gr[edge["target"],:id]
        add_edge!(gr, srcnode, trgnode)
        set_prop!(gr, srcnode, trgnode, :id, edge["id"])
        for def in defaults
            set_prop!(gr, srcnode, trgnode, Symbol(def.name), def.default)
        end
        for data in findall("x:data", edge, ["x"=>ns])
            set_prop!(gr, srcnode, trgnode, Symbol(keyprops[data["key"]].name), keyprops[data["key"]].type == String ? strip(nodecontent(data)) : parse(keyprops[data["key"]].type, nodecontent(data)))
        end
    end
    return gr
end

function loadmetagraphml(io::IO, gname::String)
    doc = readxml(io)
    ns = namespace(doc.root)
    keyprops = _get_key_props(doc)


    graphnodes = findall("//x:graph", doc.root, ["x"=>ns])
    for graphnode in graphnodes
        if graphnode["id"] == gname
            return _loadmetagraph_fromnode(graphnode, keyprops)
        end
    end
end
function loadmetagraphml_mult(io::IO)
    doc = readxml(io)
    ns = namespace(doc.root)
    keyprops = _get_key_props(doc)

    graphnodes = findall("//x:graph", doc.root, ["x"=>ns])

    graphs = Dict(graphnode["id"] => _loadmetagraph_fromnode(graphnode, keyprops)
                for graphnode in graphnodes)
end

function _graphml_read_one_graph(reader::EzXML.StreamReader, isdirected::Bool)
    nodes = Dict{String,Int}()
    xedges = Vector{Graphs.Edge}()
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
                push!(xedges, Graphs.Edge(nodes[src], nodes[tar]))
            else
                @warn "Skipping unknown node '$(elname)' - further warnings will be suppressed" maxlog=1 _id=:unknode
            end
        end
    end
    g = (isdirected ? Graphs.DiGraph : Graphs.Graph)(length(nodes))
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
                directed = edgedefault == "directed"   ? true :
                           edgedefault == "undirected" ? false :
                           error("Unknown value of edgedefault: $edgedefault")
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
                @warn "Skipping unknown XML element '$(elname)' - further warnings will be suppressed" maxlog=1 _id=:unkel
            end
        end
    end
    error("Graph $gname not found")
end

function loadgraphml_mult(io::IO)
    reader = EzXML.StreamReader(io)
    graphs = Dict{String,Graphs.AbstractGraph}()
    for typ in reader
        if typ == EzXML.READER_ELEMENT
            elname = EzXML.nodename(reader)
            if elname == "graphml"
                # ok
            elseif elname == "graph"
                edgedefault = reader["edgedefault"]
                directed = edgedefault == "directed"   ? true :
                           edgedefault == "undirected" ? false :
                           error("Unknown value of edgedefault: $edgedefault")
                if haskey(reader, "id")
                    graphname = reader["id"]
                else
                    graphname = directed ? "digraph" : "graph"
                end
                graphs[graphname] = _graphml_read_one_graph(reader, directed)
            else
                @warn "Skipping unknown XML element '$(elname)' - further warnings will be suppressed" maxlog=1 _id=:unkelmult
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
        for e in Graphs.edges(g)
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

savegraphml(io::IO, g::Graphs.AbstractGraph, gname::String) =
    savegraphml_mult(io, Dict(gname => g))

function _get_attr_type(mg::AbstractMetaGraph, attr, forel)
    if forel == atnode
        els = vertices(mg)
    elseif forel == atedge
        els = edges(mg)
    end
    for el in els
        has_prop(mg, el, attr) && return typeof(get_prop(mg, el, attr))
    end
end

function savemetagraphml_mult(io::IO, dgr::Dict{String, T}) where T<:AbstractMetaGraph
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("graphml"))
    xroot["xmlns"] = "http://graphml.graphdrawing.org/xmlns"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"

    #adds keys
    attrforellist = Vector{Tuple{Symbol, GraphMLAttributesDomain}}()
    for mg in values(dgr)
        vattrs = Set(v for keyset in keys.(values(mg.vprops)) for v in keyset)
        eattrs = Set(v for keyset in keys.(values(mg.eprops)) for v in keyset)
        for (attr, forel) in Iterators.flatten([zip(vattrs, Iterators.cycle([atnode])),
                                                zip(eattrs, Iterators.cycle([atedge]))])
            (attr, forel) in attrforellist && continue
            push!(attrforellist, (attr, forel))
            xkey = addelement!(xroot, "key")
            xkey["attr.name"] = string(attr)
            xkey["attr.type"] = first(Iterators.filter(x -> x.second == _get_attr_type(mg, attr, forel), graphMLAttributesType)).first
            xkey["for"] = first(Iterators.filter(x -> x.second == forel, graphMLAttributesDomain)).first
            xkey["id"] = string(attr)
        end
    end

    for (gname, mg) in dgr
        xg = addelement!(xroot, "graph")
        xg["id"] = gname
        xg["edgedefault"] = is_directed(mg) ? "directed" : "undirected"

        for i in 1:nv(mg)
            xv = addelement!(xg, "node")
            if has_prop(mg, i, :id)
                xv["id"] = get_prop(mg, i, :id)
            else
                xv["id"] = "n$(i-1)"
            end
            for (k,v) in props(mg, i)
                k == :id && continue
                xel = addelement!(xv, "data", string(v))
                xel["key"] = k
            end
        end

        m = 0
        for e in Graphs.edges(mg)
            xe = addelement!(xg, "edge")

            if has_prop(mg, e, :id)
                xe["id"] = get_prop(mg, e, :id)
            else
                xe["id"] = "e$(m)"
            end

            if has_prop(mg, src(e), :id)
                xe["source"] = get_prop(mg, src(e), :id)
            else
                xe["source"] = "n$(src(e)-1)"
            end
            if has_prop(mg, dst(e), :id)
                xe["target"] = get_prop(mg, dst(e), :id)
            else
                xe["target"] = "n$(dst(e)-1)"
            end

            for (k,v) in props(mg, e)
                k == :id && continue
                xel = addelement!(xe, "data", string(v))
                xel["key"] = k
            end
            m += 1
        end
    end
    prettyprint(io, xdoc)
    return 1
end

loadgraph(io::IO, gname::String, ::GraphMLFormat, ::MGFormat) = loadmetagraphml(io, gname)
loadgraphs(io::IO, ::GraphMLFormat, ::MGFormat) = loadmetagraphml_mult(io)
loadgraph(io::IO, gname::String, ::GraphMLFormat) = loadgraphml(io, gname)
loadgraphs(io::IO, ::GraphMLFormat) = loadgraphml_mult(io)

savegraph(io::IO, g::AbstractMetaGraph, gname::String, ::GraphMLFormat) = savemetagraphml_mult(io, Dict(gname => g))
savegraph(io::IO, g::AbstractGraph, gname::String, ::GraphMLFormat) = savegraphml(io, g, gname)
savegraph(io::IO, d::Dict, ::GraphMLFormat) = savegraphml_mult(io, d)
savegraph(io::IO, d::Dict{String, T}, ::GraphMLFormat) where T<:AbstractMetaGraph = savemetagraphml_mult(io, d)

end # module
