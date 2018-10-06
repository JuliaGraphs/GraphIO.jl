using Test
using CodecZlib
using GraphIO.LGCompressed

@testset "LGCompressed" begin
    for g in values(allgraphs)
        readback_test(LGCompressedFormat(), g; testfail=true)
    end
end
