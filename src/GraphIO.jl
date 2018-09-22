module GraphIO

using Requires

#=
    NOTE: This is a temporary fix until we can have multiple sub-packages with their own 
    requirements in a single repository.
=#
function __init__()
    @require EzXML="8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615" begin
        include("GEXF/Gexf.jl")
        include("GraphML/GraphML.jl")
    end
    @require ParserCombinator="fae87a5f-d1ad-5cf0-8f61-c941e1580b46" begin
        include("DOT/Dot.jl")
        include("GML/Gml.jl")
    end
end


include("Graph6/Graph6.jl")
include("NET/Net.jl")
include("Edgelist/Edgelist.jl")
include("CDF/Cdf.jl")

include("deprecations.jl")

end # module
