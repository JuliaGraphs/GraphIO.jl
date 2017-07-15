using GraphIO
using LightGraphs
using Base.Test

testdir = dirname(@__FILE__)

# write your own tests here
@testset "GraphIO" begin
    include("graphio.jl")
end
