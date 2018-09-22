module CDF

# loads a graph from a IEEE CDF file.
# http://www2.ee.washington.edu/research/pstca/formats/cdf.txt
# http://www2.ee.washington.edu/research/pstca/pf30/ieee30cdf.txt

using LightGraphs
using LightGraphs: AbstractGraphFormat

import LightGraphs: loadgraph, loadgraphs, savegraph

export CDFFormat


struct CDFFormat <: AbstractGraphFormat end

function _loadcdf(io::IO)
    srcs = Vector{Int}()
    dsts = Vector{Int}()
    vertices = Vector{Int}()
    inbusdata = false
    inbranchdata = false
    while !eof(io)
        line = strip(chomp(readline(io)))
        if inbusdata
            if occursin("-999", line)
                inbusdata = false
            else
                v = parse(Int, split(line)[1])
                push!(vertices, v)
            end
        elseif inbranchdata
            if occursin("-999", line)
                inbranchdata = false
            else
                (src_s, dst_s) = split(line)[1:2]
                src = something(findfirst(isequal(parse(Int, src_s)), vertices), 0)
                dst = something(findfirst(isequal(parse(Int, dst_s)), vertices), 0)
                push!(srcs, src)
                push!(dsts, dst)
            end
        else
            inbusdata = startswith(line, "BUS DATA FOLLOWS")
            inbranchdata = startswith(line, "BRANCH DATA FOLLOWS")
        end
    end
    n_v = length(vertices)
    g = LightGraphs.Graph(n_v)
    for p in zip(srcs, dsts)
        add_edge!(g, p)
    end
    return g
end

loadcdf(io::IO, gname::String) = _loadcdf(io)
loadgraph(io::IO, gname::String, ::CDFFormat) = loadcdf(io, gname)
loadgraphs(io::IO, ::CDFFormat) = Dict("graph" => loadcdf(io, "graph"))

end # module
