using Test
using GraphIO.CDF

@testset "CDF" begin
    g = loadgraph(joinpath(testdir, "testdata", "30bus.jlg"))
    read_test(CDFFormat(), g, "graph", joinpath(testdir, "testdata", "30bus.cdf"))
end
