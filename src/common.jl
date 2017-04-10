NI(x...) = error("This function is not implemented.")

# filemap is filled in the format specific source files
const filemap = Dict{Symbol, Tuple{Function, Function, Function, Function}}()
        # :gml        => (loadgml, loadgml_mult, savegml, savegml_mult)
        # :graphml    => (loadgraphml, loadgraphml_mult, savegraphml, savegraphml_mult)
        # :md         => (loadmatrixdepot, NOTIMPLEMENTED, NOTIMPLEMENTED, NOTIMPLEMENTED)

# load a single graph by name

"""
    loadgraph(file, t=:lg)

Read a graph from  `file` in the format `t`.
Supported formats are `:lg`, `:gml`, `:dot`, `:graphml`, `:gexf`, `:net`, `:jld`, and `:graph6`.
"""
function loadgraph(fn::String, x...)
    GZip.open(fn,"r") do io
        loadgraph(io, x...)
    end
end

function loadgraph(io::IO, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    d = filemap[t][2](io)
    return first(d)[2]
end


"""
    load(file, name, t=:lg)

Load a graph with name `name` from `file` in format `t`.

Currently supported formats are `:lg`, `:gml`, `:graphml`, `:gexf`, `:dot`, `:net`, and `graph6`.
"""
function load(io::IO, gname::String, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][1](io, gname)
end

"""
    load(file, t=:lg)

Load multiple graphs from  `file` in the format `t`. Return a dictionary
mapping graph name to graph.

For unnamed graphs the default names \"graph\" and \"digraph\" will be used.
"""

function load(io::IO, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][2](io)
end

# load from a file
function load(fn::String, x...)
    GZip.open(fn,"r") do io
        load(io, x...)
    end
end


"""
    savegraph(f, g, ...)

Save a graph to file. See [`save`](@ref).
"""
savegraph(f, g::LightGraphs.AbstractGraph, x...; kws...) = save(f, g, x...; kws...)

"""
    save(file, g, t=:lg)
    save(file, g, name, t=:lg)
    save(file, dict, t=:lg)

Saves a graph `g` with name `name` to `file` in the format `t`. If `name` is not given
the default names \"graph\" and \"digraph\" will be used. Return the number of graphs written.

Currently supported formats are `:lg`, `:gml`, :`graphml`, `:gexf`, `:dot`, `:net`, and `:graph6`.

For some graph formats, multiple graphs in a  `dict` `"name"=>g` can be saved in the same file.
"""
function save(io::IO, g::LightGraphs.AbstractGraph, gname::String, t::Symbol=:lg)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][3](io, g, gname)
end

# save a single graph without name
save(io::IO, g::LightGraphs.AbstractGraph, t::Symbol=:lg) =
  save(io, g, is_directed(g)? "digraph" : "graph", t)

# save a dictionary of graphs {"name" => graph}
function save(io::IO, d::Dict{T, U}, t::Symbol=:lg) where T<:AbstractString where U<:LightGraphs.AbstractGraph
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][4](io, d)
end

# save to a file
function save(fn::String, x...; compress::Bool=false)
    if compress
        io = GZip.open(fn,"w")
    else
        io = open(fn,"w")
    end
    retval = save(io, x...)
    close(io)
    return retval
end
