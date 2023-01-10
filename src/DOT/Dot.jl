module DOT

using Requires
using Graphs
using Graphs: AbstractGraphFormat

import Graphs: loadgraph, loadgraphs, savegraph

export DOTFormat

struct DOTFormat <: AbstractGraphFormat end

function __init__()
    @require ParserCombinator="fae87a5f-d1ad-5cf0-8f61-c941e1580b46" begin
        include("Dot_conditional.jl")
    end
end

end #module
