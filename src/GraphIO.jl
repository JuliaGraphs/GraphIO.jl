module GraphIO

#=
    NOTE: Requires.jl is a temporary fix until we can have multiple sub-packages with their own 
    requirements in a single repository.
=#

include("LGCompressed/LGCompressed.jl")
include("GEXF/Gexf.jl")
include("GraphML/GraphML.jl")
include("DOT/Dot.jl")
include("GML/Gml.jl")
include("Graph6/Graph6.jl")
include("NET/Net.jl")
include("Edgelist/Edgelist.jl")
include("CDF/Cdf.jl")

include("deprecations.jl")

end # module
