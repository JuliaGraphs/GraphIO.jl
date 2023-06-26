module GraphIOMetaGraphsGraphMLExt

using Graphs
import Graphs: loadgraph, loadgraphs, savegraph

@static if isdefined(Base, :get_extension)
    using GraphIO
    using EzXML, MetaGraphs
    import GraphIO.GraphML.GraphMLFormat
    import MetaGraphs: AbstractMetaGraph, MGFormat
else # not required for julia >= v1.9
    using ..GraphIO
    using ..EzXML, ..MetaGraphs
    import ..GraphIO.GraphML.GraphMLFormat
    import ..MetaGraphs: AbstractMetaGraph, MGFormat
end

@enum GraphlMLAttributesDomain atgraph atnode atedge atall
const graphlMLAttributesDomain = Dict(
    "graph" => atgraph, "node" => atnode, "edge" => atedge, "all" => atall
)

@enum GraphlMLAttributesType atboolean atint atlong atfloat atdouble atstring
const graphMLAttributesType = Dict(
    "int" => Int,
    "boolean" => Bool,
    "long" => Int128,
    "float" => Float64,
    "double" => Float64,
    "string" => String,
)

const graphMLAttributesType_rev = Dict(
    Bool => "boolean", Integer => "long", Real => "float", AbstractString => "string"
)

struct AttrKey{T}
    id::String
    name::String
    domain::GraphlMLAttributesDomain
    type::Type{T}
    default::Union{T,Nothing}
end

#
## probably better to put in another file
#

getvectortype(::Vector{T}) where {T} = T

function getnodekeys(dmg::Dict)
    return _getelementkeys([
        Pair(k, v) for vpg in getfield.(values(dmg), :vprops) for (k, v) in vpg
    ])
end
getnodekeys(mg::AbstractMetaGraph) = _getelementkeys([Pair(k, v) for (k, v) in mg.vprops])

function getedgekeys(dmg::Dict)
    return _getelementkeys([
        Pair(k, v) for vpg in getfield.(values(dmg), :eprops) for (k, v) in vpg
    ])
end
getedgekeys(mg::AbstractMetaGraph) = _getelementkeys([Pair(k, v) for (k, v) in mg.eprops])

function _getelementkeys(dprops)
    pairs = [Pair(x, y) for d in getfield.(dprops, :second) for (x, y) in d]
    nodefieldset = Set(getfield.(pairs, :first))
    nodefieldsettypes = [
        getvectortype([p.second for p in pairs if p.first == nfs]) for nfs in nodefieldset
    ]
    return nodefieldset, nodefieldsettypes
end

function getcompatiblesupertype(elementtype)
    if elementtype <: Bool
        return Bool
    elseif elementtype <: Integer
        return Integer
    elseif elementtype <: Real
        return Real
    else
        return AbstractString
    end
end

function savemetagraphkeys(mg::Dict{String,T}, xroot) where {T<:AbstractMetaGraph}
    for (ndf, nt) in zip(getnodekeys(mg)...)
        xk = addelement!(xroot, "key")
        xk["attr.name"] = string(ndf)
        xk["attr.type"] = graphMLAttributesType_rev[getcompatiblesupertype(nt)]
        xk["for"] = "node"
        xk["id"] = string(ndf)
    end
    for (ndf, nt) in zip(getedgekeys(mg)...)
        xk = addelement!(xroot, "key")
        xk["attr.name"] = string(ndf)
        xk["attr.type"] = graphMLAttributesType_rev[getcompatiblesupertype(nt)]
        xk["for"] = "node"
        xk["id"] = string(ndf)
    end
end

function startgraphmlroot(xdoc)
    xroot = setroot!(xdoc, ElementNode("graphml"))
    xroot["xmlns"] = "http://graphml.graphdrawing.org/xmlns"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"
    return xroot
end

function addallvertswithid(ig, xg)
    for v in vertices(ig)
        xv = addelement!(xg, "node")
        xv["id"] = get_prop(ig, v, :id)
        for (k, v) in props(ig, v)
            k == :id && continue
            xel = addelement!(xv, "data", string(v))
            xel["key"] = k
        end
    end
end
function addalledgeswithid(ig, xg)
    for e in edges(ig)
        xe = addelement!(xg, "edge")
        xe["id"] = get_prop(ig, e, :id)
        xe["source"] = get_prop(ig, src(e), :id)
        xe["target"] = get_prop(ig, dst(e), :id)
        for (k, v) in props(ig, e)
            k == :id && continue
            xel = addelement!(xe, "data", string(v))
            xel["key"] = k
        end
    end
end
#
## another file
#

function instantiatemetagraph(graphnode::EzXML.Node)
    return graphnode["edgedefault"] == "directed" ? MetaDiGraph() : MetaGraph()
end
function metagraphtype(graphnode::EzXML.Node)
    return if graphnode["edgedefault"] == "directed"
        MetaDiGraph{Int,Float64}
    else
        MetaGraph{Int,Float64}
    end
end

function nodedefaults(keyprops::Dict{String,AttrKey})
    return collect(
        Iterators.filter(
            v -> getfield(v, :default) !== nothing && getfield(v, :domain) == atnode,
            values(keyprops),
        ),
    )
end
function edgedefaults(keyprops::Dict{String,AttrKey})
    return collect(
        Iterators.filter(
            v -> getfield(v, :default) !== nothing && getfield(v, :domain) == atedge,
            values(keyprops),
        ),
    )
end

function addmetagraphmlnode!(
    gr::AbstractGraph,
    node::EzXML.Node,
    defaults::Vector{AttrKey},
    keyprops::Dict{String,AttrKey},
    ns::String,
)
    add_vertex!(gr)
    i = length(vertices(gr))
    set_prop!(gr, i, :id, node["id"])
    for def in defaults
        set_prop!(gr, i, Symbol(def.name), def.default)
    end
    for data in findall("x:data", node, ["x" => ns])
        set_prop!(
            gr,
            i,
            Symbol(keyprops[data["key"]].name),
            if keyprops[data["key"]].type == String
                strip(nodecontent(data))
            else
                parse(keyprops[data["key"]].type, nodecontent(data))
            end,
        )
    end
end

function addmetagraphmledge!(
    gr::AbstractGraph,
    edge::EzXML.Node,
    defaults::Vector{AttrKey},
    keyprops::Dict{String,AttrKey},
    ns::String,
)
    srcnode = gr[edge["source"], :id]
    trgnode = gr[edge["target"], :id]
    add_edge!(gr, srcnode, trgnode)
    set_prop!(gr, srcnode, trgnode, :id, edge["id"])
    for def in defaults
        set_prop!(gr, srcnode, trgnode, Symbol(def.name), def.default)
    end
    for data in findall("x:data", edge, ["x" => ns])
        set_prop!(
            gr,
            srcnode,
            trgnode,
            Symbol(keyprops[data["key"]].name),
            if keyprops[data["key"]].type == String
                strip(nodecontent(data))
            else
                parse(keyprops[data["key"]].type, nodecontent(data))
            end,
        )
    end
end

function _get_key_props(doc::EzXML.Document)
    ns = namespace(doc.root)
    keynodes = findall("//x:key", doc.root, ["x" => ns])
    keyprops = Dict{String,AttrKey}()
    for keynode in keynodes
        attrtype = graphMLAttributesType[strip(keynode["attr.type"])]
        keyadded = false
        for childnode in EzXML.eachnode(keynode)
            if EzXML.nodename(childnode) == "default"
                defaultcontent = strip(nodecontent(childnode))
                keyprops[keynode["id"]] = AttrKey(
                    keynode["id"],
                    keynode["attr.name"],
                    graphlMLAttributesDomain[keynode["for"]],
                    attrtype,
                    attrtype == String ? defaultcontent : parse(attrtype, defaultcontent),
                )
                keyadded = true
            end
        end
        if !keyadded
            keyprops[keynode["id"]] = AttrKey(
                keynode["id"],
                keynode["attr.name"],
                graphlMLAttributesDomain[keynode["for"]],
                attrtype,
                nothing,
            )
        end
    end
    return keyprops
end

function _loadmetagraph_fromnode(graphnode::EzXML.Node, keyprops::Dict{String,AttrKey})
    ns = namespace(graphnode)
    gr = instantiatemetagraph(graphnode)
    set_prop!(gr, :id, graphnode["id"])
    set_indexing_prop!(gr, :id)
    for (i, node) in enumerate(findall("x:node", graphnode, ["x" => ns]))
        addmetagraphmlnode!(gr, node, nodedefaults(keyprops), keyprops, ns)
    end

    for edge in findall("x:edge", graphnode, ["x" => ns])
        addmetagraphmledge!(gr, edge, edgedefaults(keyprops), keyprops, ns)
    end
    return gr
end

#TODO carefull if graphml format is nested
function loadmetagraphml(io::IO, gname::String)
    doc = readxml(io)
    ns = namespace(doc.root)
    keyprops = _get_key_props(doc)

    for graphnode in findall("//x:graph", doc.root, ["x" => ns])
        if graphnode["id"] == gname
            return _loadmetagraph_fromnode(graphnode, keyprops)
        end
    end
end
function loadmetagraphml_mult(io::IO)
    doc = readxml(io)
    ns = namespace(doc.root)
    keyprops = _get_key_props(doc)

    graphnodes = findall("//x:graph", doc.root, ["x" => ns])

    graphs = Dict{String,AbstractMetaGraph}()
    for graphnode in graphnodes
        graphs[graphnode["id"]] = _loadmetagraph_fromnode(graphnode, keyprops)
    end
    return graphs
end

function savemetagraphml_mult(io::IO, dmg::Dict{String,T}) where {T<:AbstractMetaGraph}
    xdoc = XMLDocument()
    xroot = startgraphmlroot(xdoc)
    savemetagraphkeys(dmg, xroot)

    # add graph
    for (gname, mg) in dmg
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
            for (k, v) in props(mg, i)
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

            for (k, v) in props(mg, e)
                k == :id && continue
                xel = addelement!(xe, "data", string(v))
                xel["key"] = k
            end
            m += 1
        end
    end

    prettyprint(io, xdoc)
    return nothing
end

loadgraph(io::IO, gname::String, ::GraphMLFormat, ::MGFormat) = loadmetagraphml(io, gname)
loadgraphs(io::IO, ::GraphMLFormat, ::MGFormat) = loadmetagraphml_mult(io)
function savegraph(io::IO, g::AbstractMetaGraph, gname::String, ::GraphMLFormat)
    return savemetagraphml_mult(io, Dict(gname => g))
end
savegraph(io::IO, dg::Dict, ::GraphMLFormat, ::MGFormat) = savemetagraphml_mult(io, dg)

end
