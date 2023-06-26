using Test
using EzXML
using GraphIO.GraphML
using MetaGraphs

@testset "GraphML" begin
    for g in values(allgraphs)
        readback_test(GraphMLFormat(), g; testfail=true)
    end
    fname = joinpath(testdir, "testdata", "warngraph.graphml")

    @test_logs (
        :warn, "Skipping unknown node 'warnnode' - further warnings will be suppressed"
    ) match_mode = :any loadgraphs(fname, GraphMLFormat())
    @test_logs (
        :warn,
        "Skipping unknown XML element 'warnelement' - further warnings will be suppressed",
    ) match_mode = :any loadgraph(fname, "graph", GraphMLFormat())
    d = loadgraphs(fname, GraphMLFormat())
    write_test(GraphMLFormat(), d)
end

function test_read_metagraph(dmg)
    for v in vertices(dmg)
        if get_prop(dmg, v, :id) == "N6"
            @test get_prop(dmg, v, :VertexLabel) == "N6"
            @test get_prop(dmg, v, :xcoord) == 170
            @test get_prop(dmg, v, :ycoord) == 0
        end
    end
    for e in edges(dmg)
        if get_prop(dmg, e, :id) == "N0-N3"
            @test get_prop(dmg, e, :LinkCapacity) == 100
        end
    end
end

@testset "MetaGraphsGraphML" begin
    # single graph
    fname = joinpath(testdir, "testdata", "mlattrs.graphml")
    mg = open(fname, "r") do io
        loadgraph(io, "main-graph", GraphMLFormat(), MGFormat())
    end
    test_read_metagraph(mg)

    # re-read must be equal
    ftname = joinpath(testdir, "testdata", "mlattrs_main-graph_write.graphml")
    savegraph(ftname, mg, "main-graph", GraphMLFormat())
    mg2 = open(ftname, "r") do io
        loadgraph(io, "main-graph", GraphMLFormat(), MGFormat())
    end
    @test mg == mg2 && mg.vprops == mg2.vprops && mg.eprops == mg2.eprops
    rm(ftname)

    # multiple graphs
    dmg = open(fname, "r") do io
        loadgraphs(io, GraphMLFormat(), MGFormat())
    end

    @test length(dmg) == 2
    test_read_metagraph(dmg["main-graph"])

    # re-read must be equal
    ftname = joinpath(testdir, "testdata", "mlattrs_write.graphml")
    open(ftname, "w") do io
        savegraph(io, dmg, GraphMLFormat(), MGFormat())
    end
    dmg2 = open(ftname, "r") do io
        loadgraphs(io, GraphMLFormat(), MGFormat())
    end
    for (dmg_g, dmg2_g) in zip(values(dmg), values(dmg2))
        @test dmg_g == dmg2_g &&
            dmg_g.vprops == dmg2_g.vprops &&
            dmg_g.eprops == dmg2_g.eprops
    end
    rm(ftname)
end
