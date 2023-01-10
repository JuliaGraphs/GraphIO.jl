module LGCompressed

using Requires
using Graphs
using Graphs: AbstractGraphFormat

import Graphs: loadgraph, loadgraphs, savegraph

export LGCompressedFormat

struct LGCompressedFormat <: AbstractGraphFormat end

function __init__()
    @require CodecZlib="944b1d66-785c-5afd-91f1-9de20f533193" begin
        include("LGCompressed_conditional.jl")
    end
end

end # module
