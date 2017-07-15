struct NETFormat <: AbstractGraphFormat end
"""
    savenet(io, g, gname="g")

Write a graph `g` to an IO stream `io` in the [Pajek NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/)
format. Return 1 (number of graphs written).
"""
function savenet(io::IO, g::LightGraphs.AbstractGraph, gname::String = "g")
    println(io, "*Vertices $(nv(g))")
    # write edges
    if is_directed(g)
        println(io, "*Arcs")
    else
        println(io, "*Edges")
    end
    for e in LightGraphs.edges(g)
        println(io, "$(src(e)) $(dst(e))")
    end
    return 1
end


"""
    loadnet(io::IO, gname="graph")

Read a graph from IO stream `io` in the [Pajek NET](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/)
format. Return the graph.
"""
function loadnet(io::IO, gname::String = "graph")
    line = readline(io)
    # skip comments
    while startswith(line, "%")
        line = readline(io)
    end
    n = parse(Int, matchall(r"\d+", line)[1])
    for ioline in eachline(io)
        line = ioline
        (ismatch(r"^\*Arcs", line) || ismatch(r"^\*Edges", line)) && break
    end
    if ismatch(r"^\*Arcs", line)
        g = LightGraphs.DiGraph(n)
    else
        g = LightGraphs.Graph(n)
    end
    while ismatch(r"^\*Arcs", line)
        for ioline in eachline(io)
            line = ioline
            m = matchall(r"\d+", line)
            length(m) < 2 && break
            add_edge!(g, parse(Int, m[1]), parse(Int, m[2]))
        end
    end
    while ismatch(r"^\*Edges", line) # add edges in both directions
        for ioline in eachline(io)
            line = ioline
            m = matchall(r"\d+", line)
            length(m) < 2 && break
            i1, i2 = parse(Int, m[1]), parse(Int, m[2])
            add_edge!(g, i1, i2)
            add_edge!(g, i2, i1)
        end
    end
    return g
end

loadgraph(io::IO, gname::String, ::NETFormat) = loadnet(io, gname)
loadgraphs(io::IO, ::NETFormat) = Dict("graph" => loadnet(io, "graph"))
savegraph(io::IO, g::AbstractGraph, gname::String, ::NETFormat) = savenet(io, g, gname)
