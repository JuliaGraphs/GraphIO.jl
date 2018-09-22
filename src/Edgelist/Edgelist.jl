module EdgeList

# loads a graph from an edge list format (list of srcs and dsts separated
# by commas or whitespace. Will only read the first two elements on
# each line. Will return a directed graph.

using DelimitedFiles: writedlm
using LightGraphs
using LightGraphs: AbstractGraphFormat

import LightGraphs: loadgraph, loadgraphs, savegraph

export EdgeListFormat


struct EdgeListFormat <: AbstractGraphFormat end

function loadedgelist(io::IO, gname::String)
    srcs = Vector{String}()
    dsts = Vector{String}()
    while !eof(io)
        line = strip(chomp(readline(io)))
        if !startswith(line, "#") && (line != "")
            # println("linelength = $(length(line)), line = $line")
            r = r"(\w+)[\s,]+(\w+)"
            src_s, dst_s = match(r, line).captures
            # println("src_s = $src_s, dst_s = $dst_s")
            push!(srcs, src_s)
            push!(dsts, dst_s)
        end
    end
    vxset = unique(vcat(srcs, dsts))
    vxdict = Dict{String,Int}()
    for (v, k) in enumerate(vxset)
        vxdict[k] = v
    end

    n_v = length(vxset)
    g = LightGraphs.DiGraph(n_v)
    for (u, v) in zip(srcs, dsts)
        add_edge!(g, vxdict[u], vxdict[v])
    end
    return g
end

function saveedgelist(io::IO, g::LightGraphs.AbstractGraph, gname::String)
    writedlm(io, ([src(e), dst(e)] for e in LightGraphs.edges(g)), ',')
    return 1
end

loadgraph(io::IO, gname::String, ::EdgeListFormat) = loadedgelist(io, gname)
loadgraphs(io::IO, ::EdgeListFormat) = Dict("graph" => loadedgelist(io, "graph"))
savegraph(io::IO, g::AbstractGraph, gname::String, ::EdgeListFormat) = saveedgelist(io, g, gname)

end
