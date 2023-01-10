module GraphML

using Requires
using Graphs
using Graphs: AbstractGraphFormat

import Graphs: loadgraph, loadgraphs, savegraph

export GraphMLFormat

# TODO: implement writing a dict of graphs

struct GraphMLFormat <: AbstractGraphFormat end

function __init__()
    @require EzXML="8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615" begin
        include("GraphML_conditional.jl")
    end
end

end # module
