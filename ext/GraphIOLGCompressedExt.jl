module GraphIOLGCompressedExt

using Graphs
import Graphs: loadgraph, loadgraphs, savegraph, LGFormat

@static if isdefined(Base, :get_extension)
    using GraphIO
    using CodecZlib
    import GraphIO.LGCompressed.LGCompressedFormat
else # not required for julia >= v1.9
    using ..GraphIO
    using ..CodecZlib
    import ..GraphIO.LGCompressed.LGCompressedFormat
end


function savegraph(fn::AbstractString, g::AbstractGraph, gname::AbstractString,
    format::LGCompressedFormat)
    io = open(fn, "w")
    try
        io = GzipCompressorStream(io)
        return savegraph(io, g, gname, LGFormat())
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
        return savegraph(io, d, LGFormat())
    catch
        rethrow()
    finally
        close(io)
    end
end

# savegraph(fn::AbstractString, d::Dict; compress) = savegraph(fn, d, LGCompressedFormat())

loadgraph(fn::AbstractString, gname::AbstractString, format::LGCompressedFormat) =
    loadgraph(fn, gname, LGFormat())

loadgraph(fn::AbstractString, format::LGCompressedFormat) = loadgraph(fn, "graph", LGFormat())

loadgraphs(fn::AbstractString, format::LGCompressedFormat) = loadgraphs(fn, LGFormat())

end
