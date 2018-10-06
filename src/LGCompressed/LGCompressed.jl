module LGCompressed

using GraphIO.CodecZlib
using LightGraphs
using LightGraphs: AbstractGraphFormat

import LightGraphs: loadgraph, loadgraphs, savegraph

export LGCompressedFormat

struct LGCompressedFormat <: AbstractGraphFormat end

function savegraph(fn::AbstractString, g::AbstractGraph, gname::AbstractString,
    format::LGCompressedFormat)
    io = open(fn, "w")
    try
        io = GzipCompressorStream(io)
        return savegraph(io, g, gname, LightGraphs.LGFormat())
    catch
        rethrow()
    finally
        close(io)
    end
end

savegraph(fn::AbstractString, g::AbstractGraph, format::LGCompressedFormat) =
    savegraph(fn, g, "graph", format)

function savegraph(fn::AbstractString, d::Dict{T,U},
    format::LGCompressedFormat) where T <: AbstractString where U <: AbstractGraph
    io = open(fn, "w")
    try
        io = GzipCompressorStream(io)
        return savegraph(io, d, LightGraphs.LGFormat())
    catch
        rethrow()
    finally
        close(io)
    end
end

# savegraph(fn::AbstractString, d::Dict; compress) = savegraph(fn, d, LGCompressedFormat())

loadgraph(fn::AbstractString, gname::AbstractString, format::LGCompressedFormat) =
    loadgraph(fn, gname, LightGraphs.LGFormat())

loadgraph(fn::AbstractString, format::LGCompressedFormat) = loadgraph(fn, "graph", LightGraphs.LGFormat())

loadgraphs(fn::AbstractString, format::LGCompressedFormat) = loadgraphs(fn, LGFormat())

end # module
