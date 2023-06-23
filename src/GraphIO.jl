module GraphIO

@static if !isdefined(Base, :get_extension)
    using Requires
end

@static if !isdefined(Base, :get_extension)
    function __init__()
        @require CodecZlib = "944b1d66-785c-5afd-91f1-9de20f533193" begin
            include("../ext/GraphIOLGCompressedExt.jl")
        end
        @require EzXML = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615" begin
            include("../ext/GraphIOGEXFExt.jl")
            include("../ext/GraphIOGraphMLExt.jl")
        end
        @require ParserCombinator = "fae87a5f-d1ad-5cf0-8f61-c941e1580b46" begin
            include("../ext/GraphIODOTExt.jl")
            include("../ext/GraphIOGMLExt.jl")
        end
    end
end

include("CDF/Cdf.jl")
include("DOT/Dot.jl")
include("Edgelist/Edgelist.jl")
include("GEXF/Gexf.jl")
include("GML/Gml.jl")
include("GraphML/GraphML.jl")
include("Graph6/Graph6.jl")
include("LGCompressed/LGCompressed.jl")
include("NET/Net.jl")

end
