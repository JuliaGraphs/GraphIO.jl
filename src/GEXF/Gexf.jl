module GEXF

using Requires
using Graphs
using Graphs: AbstractGraph, AbstractGraphFormat

import Graphs: savegraph

export GEXFFormat 

# TODO: implement readgexf
struct GEXFFormat <: AbstractGraphFormat end

function __init__()
    @require EzXML="8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615" begin
        include("Gexf_conditional.jl")
    end
end

end #module
