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

savegraph(fn::AbstractString, g::AbstractGraph; compress) = savegraph(fn, g, LGCompressedFormat())

function savegraph(fn::AbstractString, d::Dict{T,U},
    format::LGCompressedFormat) where T <: AbstractString where U <: AbstractGraph
    io = open(fn, "w")
    try
        if compress
            io = GzipCompressorStream(io)
        end
        return savegraph(io, d, LightGraphs.LGFormat())
    catch
        rethrow()
    finally
        close(io)
    end
end

savegraph(fn::AbstractString, d::Dict; compress) = savegraph(fn, d, LGCompressedFormat())

loadgraph(fn::AbstractString, gname::AbstractString, format::LGCompressedFormat) =
    loadgraph(fn, gname, LightGraphs.LGFormat())

loadgraph(fn::AbstractString, gname::AbstractString) = loadgraph(fn, gname, LGFormat())
loadgraph(fn::AbstractString, format::LGCompressedFormat) = loadgraph(fn, "graph", LightGraphs.LGFormat())

loadgraphs(fn::AbstractString, format::LGCompressedFormat) = loadgraphs(fn, LGFormat())