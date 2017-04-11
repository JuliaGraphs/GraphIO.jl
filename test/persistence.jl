using LightGraphs
using LightGraphsPersistence

    pdict = loadgraphs(joinpath(testdir,"testdata","tutte-pathdigraph.jgz"))
    p1 = pdict["Tutte"]
    p2 = pdict["pathdigraph"]
    g3 = PathGraph(5)

    function readback_test(format::Type{T}, g::LightGraphs.Graph, gname="g",
                           remove=true, fnamefio=mktemp()) where T <: AbstractGraphFormat
        fname,fio = fnamefio
        close(fio)
        @test savegraph(fname, g, format) == 1
        @test loadgraphs(fname, format)[gname] == g
        @test loadgraph(fname, gname, format) == g
        if remove
            rm(fname)
        else
            info("persistence/readback_test: Left temporary file at: $fname")
        end
    end

    (f,fio) = mktemp()
@testset "GraphML" begin
    # test GraphMLFormat
    @test savegraph(f, p1, GraphMLFormat) == 1
    gs = loadgraphs(joinpath(testdir, "testdata", "grafo1853.13.graphml"), GraphMLFormat)
    @test length(gs) == 1
    @test haskey(gs, "G") #Name of graph
    graphml_g = gs["G"]
    @test nv(graphml_g) == 13
    @test ne(graphml_g) == 15
    gs = loadgraphs(joinpath(testdir, "testdata", "twounnamedgraphs.graphml"), GraphMLFormat)
    @test gs["graph"] == LightGraphs.Graph(gs["digraph"])
    @test savegraph(f, g3, GraphMLFormat) == 1
    @test_throws ErrorException loadgraph(joinpath(testdir, "testdata", "twounnamedgraphs.graphml"), "badname", GraphMLFormat)
    # test a graphml load that results in a warning
    # redirecting per https://thenewphalls.wordpress.com/2014/03/21/capturing-output-in-julia/
    origSTDERR = STDERR
    (outread, outwrite) = redirect_stderr()
    gs = loadgraphs(joinpath(testdir,"testdata","warngraph.graphml"), GraphMLFormat)
    gsg = loadgraph(joinpath(testdir,"testdata","warngraph.graphml"), "G", GraphMLFormat)
    @test_throws KeyError badgraph = loadgraphs(joinpath(testdir, "testdata", "badgraph.graphml"), GraphMLFormat)
    flush(outread)
    flush(outwrite)
    close(outread)
    close(outwrite)
    redirect_stderr(origSTDERR)
    @test gs["G"] == graphml_g == gsg
end

@testset "GML" begin
    # test GMLFormat
    gs = loadgraphs(joinpath(testdir,"testdata", "twographs-10-28.gml"), GMLFormat)
    gml1 = gs["gml1"]
    gml2 = gs["digraph"]
    gml1a = loadgraph(joinpath(testdir,"testdata", "twographs-10-28.gml"), "gml1", GMLFormat)
    @test gml1a == gml1
    @test nv(gml1) == nv(gml2) == 10
    @test ne(gml1) == ne(gml2) == 28
    gml1a = loadgraph(joinpath(testdir,"testdata", "twographs-10-28.gml"), "gml1", GMLFormat)
    @test gml1a == gml1
    gs = loadgraphs(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), GMLFormat)
    gml1 = gs["graph"]
    gml2 = gs["digraph"]
    @test nv(gml1) == 4
    @test ne(gml1) == 6
    @test nv(gml2) == 4
    @test ne(gml2) == 9
    @test_throws ErrorException loadgraph(joinpath(testdir, "testdata", "twounnamedgraphs.gml"), "badname", GMLFormat)

    @test savegraph(f, gml1, GMLFormat) == 1
    gml1 = loadgraphs(f, GMLFormat)["graph"]
    @test nv(gml1) == 4
    @test ne(gml1) == 6

    gs = loadgraphs(joinpath(testdir,"testdata", "twographs-10-28.gml"), GMLFormat)
    @test savegraph(f, gs, GMLFormat) == 2
    gs = loadgraphs(f, GMLFormat)
    gml1 = gs["gml1"]
    gml2 = gs["digraph"]
    @test nv(gml1) == nv(gml2) == 10
    @test ne(gml1) == ne(gml2) == 28
end

@testset "DOT" begin
    # test DOTFormat
    gs = loadgraphs(joinpath(testdir, "testdata", "twographs.dot"), DOTFormat)
    @test length(gs) == 2
    @test gs["g1"] == CompleteGraph(6)
    @test nv(gs["g2"]) == 4 && ne(gs["g2"]) == 6 && is_directed(gs["g2"])
    @test_throws ErrorException loadgraph(joinpath(testdir, "testdata", "twographs.dot"), "badname", DOTFormat)
end

@testset "GEXF" begin
    # test GEXFFormat
    @test savegraph(f, p1, GEXFFormat) == 1
end

@testset "Graph6" begin
    #test Graph6Format
    n1 = (30, UInt8.([93]))
    n2 = (12345, UInt8.([126; 66; 63; 120]))
    n3 = (460175067, UInt8.([126; 126; 63; 90; 90; 90; 90; 90]))
    ns = [n1; n2; n3]
    for n in ns
        @test LightGraphsPersistence._g6_N(n[1]) == n[2]
        @test LightGraphsPersistence._g6_Np(n[2])[1] == n[1]
    end

    gs = loadgraphs(joinpath(testdir,"testdata", "twographs.g6"), Graph6Format)
    @test length(gs) == 2
    @test nv(gs["g1"]) == 6 && ne(gs["g1"]) == 5
    @test nv(gs["g2"]) == 6 && ne(gs["g2"]) == 6


    graphs = [PathGraph(10), CompleteGraph(5), WheelGraph(7)]
    for g in graphs
        readback_test(Graph6Format, g, "g1")
    end

    (f,fio) = mktemp()
    close(fio)
    d = Dict{String, LightGraphs.Graph}("g1"=>CompleteGraph(10), "g2"=>PathGraph(5), "g3" => WheelGraph(7))
    @test savegraph(f,d, Graph6Format) == 3
    g6graphs = LightGraphsPersistence.loadgraph6_mult(fio)
    for (gname, g) in g6graphs
        @test g == d[gnames]
    end
    rm(f)
end

@testset "Pajek NET" begin
    #test NETFormat
    g10 = CompleteGraph(10)
    fname,fio = mktemp()
    close(fio)
    @test savegraph(fname, g10, NETFormat) == 1
    @test loadgraphs(fname,NETFormat)["g"] == g10
    rm(fname)

    g10 = PathDiGraph(10)
    @test savegraph(fname, g10, NETFormat) == 1
    @test loadgraphs(fname,NETFormat)["g"] == g10
    rm(fname)

    g10 = loadgraphs(joinpath(testdir, "testdata", "kinship.net"), NETFormat)["g"]
    @test nv(g10) == 6
    @test ne(g10) == 8
end

@testset "JLD" begin
    using JLD

    function write_readback(path::String, g)
        jldfile = jldopen(path, "w")
        jldfile["g"] = g
        close(jldfile)

        jldfile = jldopen(path, "r")
        gs = read(jldfile, "g")
        return gs
    end

    function testjldio(path::String, g::LightGraphs.Graph)
        gs = write_readback(path, g)
        gloaded = LightGraphs.Graph(gs)
        @test gloaded == g
    end

    graphs = [PathGraph(10), CompleteGraph(5), WheelGraph(7)]
    for (i,g) in enumerate(graphs)
        path = joinpath(testdir,"testdata", "test.$i.jld")
        testjldio(path, g)
        #delete the file (it gets left on test failure so you could debug it)
        rm(path)
    end

    for (i,g) in enumerate(graphs)
        eprop = Dict{LightGraphs.Edge, Char}([(e, Char(i)) for e in LightGraphs.edges(g)])
        net = LightGraphsPersistence.Network{LightGraphs.Graph, Int, Char}(g, 1:nv(g), eprop)
        path = joinpath(testdir,"testdata", "test.$i.jld")
        nsaved = write_readback(path, net)
        @test LightGraphsPersistence.Network(nsaved) == net
        #delete the file (it gets left on test failure so you could debug it)
        rm(path)
    end
end
