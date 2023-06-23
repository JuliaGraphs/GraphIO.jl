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
        Aqua.test_all(GraphIO; stale_deps=false, project_toml_formatting=false)
        Aqua.test_stale_deps(GraphIO; ignore=[:Requires])
        if VERSION >= v"1.9"
            Aqua.test_project_toml_formatting(GraphIO)
        end
    end
    @testset "Code formatting" begin
        @test JuliaFormatter.format(GraphIO; verbose=false, overwrite=false)
    end
    for name in modules
        path = joinpath(testdir, name, "runtests.jl")
        include(path)
    end
end
