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
    elist = Vector{Tuple{Int64, Int64}}()
    nvg = 0
    neg = 0
    fadjlist = Vector{Vector{Int64}}()
    badjlist = Vector{Vector{Int64}}()
    while !eof(io)
        x = readline(io)
        i = 1
        while x[i] != ' ' && x[i] != ','
            i += 1
        end
        s = parse(Int64, x[1:i-1])
        while x[i] == ' ' || x[i] == ','
            i += 1
        end
        ii = i
        while i <= length(x) && x[i] != ' '
            i += 1
        end
        d = parse(Int64, x[ii:i-1])
        if nvg < max(s, d)
            nvg = max(s, d)
            append!(fadjlist, [Vector{Int64}() for _ in 1:nvg-length(fadjlist)])
            append!(badjlist, [Vector{Int64}() for _ in 1:nvg-length(badjlist)])
        end
        push!(fadjlist[s], d)
        push!(badjlist[d], s)
        neg += 1
    end
    sort!.(fadjlist)
    sort!.(badjlist)
    return LightGraphs.DiGraph(neg, fadjlist, badjlist)
end

function saveedgelist(io::IO, g::LightGraphs.AbstractGraph, gname::String)
    writedlm(io, ([src(e), dst(e)] for e in LightGraphs.edges(g)), ',')
    return 1
end

loadgraph(io::IO, gname::String, ::EdgeListFormat) = loadedgelist(io, gname)
loadgraphs(io::IO, ::EdgeListFormat) = Dict("graph" => loadedgelist(io, "graph"))
savegraph(io::IO, g::AbstractGraph, gname::String, ::EdgeListFormat) = saveedgelist(io, g, gname)

end
