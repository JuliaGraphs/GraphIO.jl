using MetaGraphs

function idandtypes(prs)
    k2id = Dict{Symbol,Int}()
    k2type = Dict{Symbol,Type}()
    i = 1
    for vs in values(prs)
        for (k,v) in (vs)
            if haskey(k2id, k)
                if k2type[k] != typeof(v)
                    k2type[k] = promote_type(k2type[k],typeof(v))
                end
            else
                k2id[k] = i 
                i += 1
                k2type[k] = typeof(v)
            end 
        end
    end
    return(k2id, k2type)
end

type2string(::Type{T}) where {T<:Integer} = "integer"
type2string(::Type{T}) where {T<:AbstractFloat} = "double"
type2string(::Type{T}) where {T<:Char} = "string"
type2string(::Type{T}) where {T<:AbstractString} = "string"

function exportattributes(xg, prs, element_type)
    (k2id, k2type) = idandtypes(prs)
    if !isempty(k2id)
        xattrs = addelement!(xg, "attributes")
        xattrs["class"] = element_type
        for (k,i) in k2id
            xat=addelement!(xattrs, "attribute")
            xat["id"] = i
            xat["title"] = k
            xat["type"] = type2string(k2type[k])
        end
    end
    k2id
end

function add_properties!(xv, ks, prs)
    isempty(prs) && return
    av = addelement!(xv, "attvalues")
    for (k,v) in prs
        av = addelement!(av, "attvalue")
        av["for"] = ks[k]
        av["value"] = v
    end
end

function savegexf(io::IO, g::MetaGraph, gname::String)
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("gexf"))
    xroot["xmlns"] = "http://www.gexf.net/1.2draft"
    xroot["version"] = "1.2"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://www.gexf.net/1.2draft/gexf.xsd"

    xmeta = addelement!(xroot, "meta")
    addelement!(xmeta, "description", gname)
    xg = addelement!(xroot, "graph")
    strdir = is_directed(g) ? "directed" : "undirected"
    xg["defaultedgetype"] = strdir


    vks = exportattributes(xg, g.vprops, "node")
    eks = exportattributes(xg, g.eprops, "edge")

    xnodes = addelement!(xg, "nodes")
    for v in vertices(g)
        xv = addelement!(xnodes, "node")
        xv["id"] = "$(v-1)"
        add_properties!(xv, vks, props(g, v))
    end

    xedges = addelement!(xg, "edges")
    m = 0
    for e in LightGraphs.edges(g)
        xe = addelement!(xedges, "edge")
        xe["id"] = "$m"
        xe["source"] = "$(src(e)-1)"
        xe["target"] = "$(dst(e)-1)"
        add_properties!(xe, eks, props(g, e))
        m += 1
    end

    prettyprint(io, xdoc)
    return 1
end