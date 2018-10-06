using LightGraphs
using Test

testdir = dirname(@__FILE__)

modules = [
           "CDF", 
           "Edgelist", 
           "GML", 
           "NET", 
           "DOT", 
           "GEXF", 
           "Graph6", 
           "GraphML",
           "LGCompressed"
          ]

include("graphio.jl")

# write your own tests here
@testset "GraphIO" begin
    for name in modules
        path = joinpath(testdir, name, "runtests.jl")
        include(path)
    end
end
