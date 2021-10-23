export IntEdgeListFormat

struct IntEdgeListFormat <: AbstractGraphFormat
    offset::Int64
end
IntEdgeListFormat(;offset = 0) = IntEdgeListFormat(offset)

function loadintedgelist(io::IO, gname::String, offset::Int64)
    elist = Vector{Tuple{Int64, Int64}}()
    nvg = 0
    neg = 0
    fadjlist = Vector{Vector{Int64}}()
    for x in eachline(io)
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
        s = s-offset
        d = d-offset
        if nvg < max(s, d)
            nvg = max(s, d)
            append!(fadjlist, [Vector{Int64}() for _ in 1:nvg-length(fadjlist)])
        end
        push!(fadjlist[s], d)
        neg += 1
    end
    sort!.(fadjlist)
    badjlist = [Vector{Int64}() for _ in 1:nvg]
    for u = 1:nvg
    	for v in fadjlist[u]
    		push!(badjlist[v], u)
    	end
    end
    return Graphs.DiGraph(neg, fadjlist, badjlist)
end

loadgraph(io::IO, gname::String, fmt::IntEdgeListFormat) = loadintedgelist(io, gname, fmt.offset)
loadgraphs(io::IO, fmt::IntEdgeListFormat) = Dict("graph" => loadintedgelist(io, "graph", fmt.offset))
savegraph(io::IO, g::AbstractGraph, gname::String, ::IntEdgeListFormat) = saveedgelist(io, g, gname)
