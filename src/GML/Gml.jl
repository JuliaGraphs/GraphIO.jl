module GML

using Requires
using Graphs
using Graphs: AbstractGraphFormat

import Graphs: loadgraph, loadgraphs, savegraph

export GMLFormat

struct GMLFormat <: AbstractGraphFormat end

function __init__()
    @require ParserCombinator="fae87a5f-d1ad-5cf0-8f61-c941e1580b46" begin
        include("Gml_conditional.jl")
    end
end

end # module
