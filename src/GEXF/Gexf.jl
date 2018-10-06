module GEXF

using GraphIO.EzXML
using LightGraphs
using LightGraphs: AbstractGraph, AbstractGraphFormat

import LightGraphs: savegraph

export GEXFFormat 

# TODO: implement readgexf
struct GEXFFormat <: AbstractGraphFormat end
"""
    savegexf(f, g, gname)

Write a graph `g` with name `gname` to an IO stream `io` in the
[Gexf](http://gexf.net/format/) format. Return 1 (number of graphs written).
"""
function savegexf(io::IO, g::LightGraphs.AbstractGraph, gname::String)
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

    xnodes = addelement!(xg, "nodes")
    for i in 1:nv(g)
        xv = addelement!(xnodes, "node")
        xv["id"] = "$(i-1)"
    end

    xedges = addelement!(xg, "edges")
    m = 0
    for e in LightGraphs.edges(g)
        xe = addelement!(xedges, "edge")
        xe["id"] = "$m"
        xe["source"] = "$(src(e)-1)"
        xe["target"] = "$(dst(e)-1)"
        m += 1
    end

    prettyprint(io, xdoc)
    return 1
end

savegraph(io::IO, g::AbstractGraph, gname::String, ::GEXFFormat) = savegexf(io, g, gname)

end #module
