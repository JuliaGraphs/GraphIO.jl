using Aqua
using GraphIO
using Graphs
using JuliaFormatter
using Test

testdir = dirname(@__FILE__)

modules = [
    "CDF", "Edgelist", "GML", "NET", "DOT", "GEXF", "Graph6", "GraphML", "LGCompressed"
]

include("graphio.jl")

# write your own tests here
@testset verbose = true "GraphIO" begin
    @testset "Code quality" begin
        Aqua.test_all(GraphIO)
    end
    @testset "Code formatting" begin
        @test JuliaFormatter.format(GraphIO; verbose=true, overwrite=false)
    end
    for name in modules
        path = joinpath(testdir, name, "runtests.jl")
        include(path)
    end
end
