using Test
using ParserCombinator
using GraphIO.DOT
using LightGraphs.Experimental

@testset "DOT" begin
    g = complete_graph(6)
    dg = DiGraph(4)
    for e in [Edge(1,2), Edge(1,3), Edge(2,2), Edge(2,3), Edge(4,1), Edge(4,3)]
        add_edge!(dg, e)
    end
    fname = joinpath(testdir, "testdata", "twographs.dot")
    read_test(DOTFormat(), g, "g1", fname, testfail=true)
    read_test(DOTFormat(), dg, "g2", fname)
    read_test_mult(DOTFormat(), Dict{String,AbstractGraph}("g1"=>g, "g2"=>dg), fname)
	
	#tests for multiple graphs

	fname = joinpath(testdir, "testdata", "saved3graphs.dot")
	#connected graph
	g1 = SimpleGraph(5,10)	
	#disconnected graph
	g2 = SimpleGraph(5,2)
	#directed graph
	dg = SimpleDiGraph(5,8)
	GraphDict = Dict("g1" => g1, "g2" => g2, "dg" => dg)
	write_test(DOTFormat(), GraphDict, fname, remove = false, silent = true)

	#adding this test because currently the Parser returns unordered vertices
	@test has_isomorph(loadgraph(fname, "g1", DOTFormat()), g1)
	@test has_isomorph(loadgraph(fname, "g2", DOTFormat()), g2)
	@test has_isomorph(loadgraph(fname, "dg", DOTFormat()), dg)

	rm(fname)

	#tests for single graph

	fname1 = joinpath(testdir, "testdata", "saved1graph.dot")
	write_test(DOTFormat(), g1, "g1", fname1, remove = false, silent = true)
	@test has_isomorph(loadgraph(fname1, "g1", DOTFormat()), g1)
	fname2 = joinpath(testdir, "testdata", "saved1digraph.dot")
	write_test(DOTFormat(), dg, "dg", fname2, remove = false, silent = true)
	@test has_isomorph(loadgraph(fname2, "dg", DOTFormat()), dg)	

	rm(fname1)
	rm(fname2)	
end
