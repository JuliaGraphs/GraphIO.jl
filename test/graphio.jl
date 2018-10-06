# This file contains helper functions for testing the various 
# GraphIO formats

using LightGraphs

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
        @test_throws Union{ArgumentError, ErrorException} loadgraph(fname, "badgraphXXX", format)
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
        @test_throws Union{ArgumentError, ErrorException} loadgraph(fname, "badgraphXXX", format)
    end
    if remove
        rm(fname)
    else
        info("graphio/readback_test: Left temporary file at: $fname")
    end
end
