using LightGraphs
using GraphIO

graphs = Dict{String,Graph}(
    "graph1"    => CompleteGraph(5), 
    "graph2"    => PathGraph(6),
    "graph3"    =>WheelGraph(4)
    )
digraphs = Dict{String,DiGraph}(
    "digraph1"   => CompleteDiGraph(5), 
    "digraph2"   => PathDiGraph(6),
    "digraph3"   => WheelDiGraph(4)
)
allgraphs = merge(graphs, digraphs)

function gettempname()
    (f, fio) = mktemp()
    close(fio)
    return f
end 
        
function read_test(format::LightGraphs.AbstractGraphFormat, g::LightGraphs.AbstractGraph, gname::String="g",
    fname::AbstractString=""; testfail=false)
    @test loadgraph(fname, gname, format) == g
    if testfail
        @test_throws ErrorException loadgraph(fname, "badgraphXXX", format)
    end
    @test loadgraphs(fname, format)[gname] == g
end

function read_test_mult(format::LightGraphs.AbstractGraphFormat, d::Dict{String,G}, fname::AbstractString="") where G<: AbstractGraph
    rd = loadgraphs(fname, format)
    @test rd == d
    
end

function write_test(format::LightGraphs.AbstractGraphFormat, g::LightGraphs.AbstractGraph, gname::String="g",
    fname::AbstractString=gettempname(); remove=true, silent=false)
    @test savegraph(fname, g, gname, format) == 1
    if remove
        rm(fname)
    elseif !silent
        info("graphio/write_test: Left temporary file at: $fname")
    end
end

function write_test(format::LightGraphs.AbstractGraphFormat, d::Dict{String,G},
    fname::AbstractString=gettempname(); remove=true, silent=false) where G <: LightGraphs.AbstractGraph
    @test savegraph(fname, d, format) == length(d)
    if remove
        rm(fname)
    elseif !silent
        info("graphio/write_test: Left temporary file at: $fname")
    end
end

function readback_test(format::LightGraphs.AbstractGraphFormat, g::LightGraphs.AbstractGraph, gname="graph",
                        fname=gettempname(); remove=true, testfail=false)
    @test savegraph(fname, g, format) == 1
    @test loadgraphs(fname, format)[gname] == g
    @test loadgraph(fname, gname, format) == g
    if testfail
        @test_throws ErrorException loadgraph(fname, "badgraphXXX", format)
    end
    if remove
        rm(fname)
    else
        info("graphio/readback_test: Left temporary file at: $fname")
    end
end


@testset "EdgeList" begin
    for g in values(digraphs)
        readback_test(EdgeListFormat(), g)
    end
end

@testset "GraphML" begin
    for g in values(allgraphs)
        readback_test(GraphMLFormat(), g, testfail=true)
    end
    fname = joinpath(testdir, "testdata", "warngraph.graphml")
    
    @test_logs (:warn, "Skipping unknown node 'warnnode' - further warnings will be suppressed") match_mode=:any loadgraphs(fname, GraphMLFormat())
    @test_logs (:warn, "Skipping unknown XML element 'warnelement' - further warnings will be suppressed") match_mode=:any loadgraph(fname, "graph", GraphMLFormat())
    d = loadgraphs(fname, GraphMLFormat())
    write_test(GraphMLFormat(), d)
end

@testset "GML" begin
    # test GMLFormat()
    for g in values(allgraphs)
        readback_test(GMLFormat(), g, testfail=true)
    end
    write_test(GMLFormat(), allgraphs)
end

@testset "DOT" begin
    g = CompleteGraph(6)
    dg = DiGraph(4)
    for e in [Edge(1,2), Edge(1,3), Edge(2,2), Edge(2,3), Edge(4,1), Edge(4,3)]
        add_edge!(dg, e)
    end
    fname = joinpath(testdir, "testdata", "twographs.dot")
    read_test(DOTFormat(), g, "g1", fname, testfail=true)
    read_test(DOTFormat(), dg, "g2", fname)
    read_test_mult(DOTFormat(), Dict{String,AbstractGraph}("g1"=>g, "g2"=>dg), fname)
end

@testset "GEXF" begin
    # test GEXFFormat()
    for g in values(allgraphs)
        write_test(GEXFFormat(), g)
    end
end

@testset "Graph6" begin
    #test Graph6Format()
    n1 = (30, UInt8.([93]))
    n2 = (12345, UInt8.([126; 66; 63; 120]))
    n3 = (460175067, UInt8.([126; 126; 63; 90; 90; 90; 90; 90]))
    ns = [n1; n2; n3]
    for n in ns
        @test GraphIO._g6_N(n[1]) == n[2]
        @test GraphIO._g6_Np(n[2])[1] == n[1]
    end

    for g in values(graphs)
        readback_test(Graph6Format(), g, "graph1")
    end

    f = gettempname()
    write_test(Graph6Format(), graphs, f; remove=false, silent=true)
    read_test_mult(Graph6Format(), graphs, f)
    rm(f)
end

@testset "Pajek NET" begin
#test NETFormat()
    for g in values(allgraphs)
        readback_test(NETFormat(), g)
    end
    fname = joinpath(testdir, "testdata", "kinship.net")
    @test length(loadgraphs(fname, NETFormat())) == 1
end

@testset "LGCompressed" begin
    using CodecZlib
    for g in values(allgraphs)
        readback_test(LGCompressedFormat(), g)
    end
end
#=
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

    for (i,g) in enumerate(values(graphs))
        f = gettempname()
        path = "f.$i.jld"
        testjldio(path, g)
        #delete the file (it gets left on test failure so you could debug it)
        rm(path)
    end

    for (i,g) in enumerate(values(graphs))
        eprop = Dict{LightGraphs.Edge, Char}([(e, Char(i)) for e in LightGraphs.edges(g)])
        net = GraphIO.Network{LightGraphs.Graph, Int, Char}(g, 1:nv(g), eprop)
        f = gettempname()
        path = "f.$i.jld"
        nsaved = write_readback(path, net)
        @test GraphIO.Network(nsaved) == net
        #delete the file (it gets left on test failure so you could debug it)
        rm(path)
    end
end
=#

@testset "CDF" begin
#test CDFFormat()
    g = loadgraph(joinpath(testdir, "testdata", "30bus.jlg"))
    read_test(CDFFormat(), g, "graph", joinpath(testdir, "testdata", "30bus.cdf"))
end

