using Test
using GraphIO.Graph6

@testset "Graph6" begin
    n1 = (30, UInt8.([93]))
    n2 = (12345, UInt8.([126; 66; 63; 120]))
    n3 = (460175067, UInt8.([126; 126; 63; 90; 90; 90; 90; 90]))
    ns = [n1; n2; n3]
    for n in ns
        @test Graph6._g6_N(n[1]) == n[2]
        @test Graph6._g6_Np(n[2])[1] == n[1]
    end

    for g in values(graphs)
        readback_test(Graph6Format(), g, "graph1")
    end

    f = gettempname()
    write_test(Graph6Format(), graphs, f; remove=false, silent=true)
    read_test_mult(Graph6Format(), graphs, f)
    rm(f)
end

