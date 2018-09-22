module Graph6

using SimpleTraits
using LightGraphs
using LightGraphs: AbstractGraphFormat

import LightGraphs: loadgraph, loadgraphs, savegraph

export Graph6Format

struct Graph6Format <: AbstractGraphFormat end

function _bv2int(x::BitVector)
  @assert(length(x) <= 8 * sizeof(Int))
  acc = 0
  for i = 1:length(x)
    acc = acc << 1 + x[i]
  end
  return acc
end

function _int2bv(n::Int, k::Int)
  bitstr = lstrip(bitstring(n), '0')
  l = length(bitstr)
  padding = k - l
  bv = falses(k)
  for i = 1:l
    bv[padding + i] = (bitstr[i] == '1')
  end
  return bv
end

function _g6_R(_x::BitVector)::Vector{UInt8}
  k = length(_x)
  padding = cld(k, 6) * 6 - k
  x = vcat(_x, falses(padding))
  nbytes = div(length(x), 6)
  bytevec = Vector{UInt8}(undef, nbytes)   # uninitialized data!
  for i = 1:nbytes
    xslice  = x[((i - 1) * 6 + 1):(i * 6)]

    intslice = 0
    for bit in xslice
      intslice = (intslice << 1) + bit
    end
    intslice += 63
    bytevec[i] = intslice
  end
  return UInt8.(bytevec)
end

_g6_R(n::Int, k::Int) = _g6_R(_int2bv(n, k))

function _g6_Rp(bytevec::Vector{UInt8})
  nbytes = length(bytevec)
  x = BitVector()
  for byte in bytevec
    bits = _int2bv(byte - 63, 6)
    x = vcat(x, bits)
  end
  return x
end

function _g6_N(x::Integer)::Vector{UInt8}
  if (x < 0) || (x > 68719476735) error("x must satisfy 0 <= x <= 68719476735")
  elseif (x <= 62) nvec = [x + 63]
  elseif (x <= 258047)
    nvec = vcat([0x7e], _g6_R(x, 18))
  else
    nvec = vcat([0x7e; 0x7e], _g6_R(x, 36))
  end
  return UInt8.(nvec)
end

function _g6_Np(N::Vector{UInt8})
  if N[1] < 0x7e return (Int(N[1] - 63), N[2:end])
  elseif N[2] < 0x7e return (_bv2int(_g6_Rp(N[2:4])), N[5:end])
  else return(_bv2int(_g6_Rp(N[3:8])), N[9:end])
  end
end


"""
    _graphToG6String(g)

Given a graph `g`, create the corresponding Graph6 string.
"""
function _graphToG6String(g::LightGraphs.Graph)
  A = adjacency_matrix(g, Bool)
  n = nv(g)
  nbits = div(n * (n - 1), 2)
  x  = BitVector(undef, nbits)

  ind = 0
  for col = 2:n, row = 1:(col - 1)
    ind += 1
    x[ind] = A[row, col]
  end
  return join([">>graph6<<", String(_g6_N(n)), String(_g6_R(x))])
end

function _g6StringToGraph(s::AbstractString)
  if startswith(s, ">>graph6<<")
    s = s[11:end]
  end
  V = Vector{UInt8}(s)
  (nv, rest) = _g6_Np(V)
  bitvec = _g6_Rp(rest)

  g = LightGraphs.Graph(nv)
  n = 0
  for i in 2:nv, j in 1:(i - 1)
    n += 1
    if bitvec[n]
      add_edge!(g, j, i)
    end
  end
  return g
end

function loadgraph6_mult(io::IO)
  n = 0
  graphdict = Dict{String,LightGraphs.Graph}()
  while !eof(io)
    n += 1
    line = strip(chomp(readline(io)))
    gname = "graph$n"
    if length(line) > 0
        g = _g6StringToGraph(line)
        graphdict[gname] = g
    end
  end
  return graphdict
end

"""
    loadgraph6(io, gname="graph")

Read a graph from IO stream `io` in the [Graph6](http://users.cecs.anu.edu.au/%7Ebdm/data/formats.txt)
format. Return the graph.
"""
loadgraph6(io::IO, gname::String="graph") = loadgraph6_mult(io)[gname]


"""
    savegraph6(io, g, gname="graph")

Write a graph `g` to IO stream `io` in the [Graph6](http://users.cecs.anu.edu.au/%7Ebdm/data/formats.txt)
format. Return 1 (number of graphs written).
"""
function savegraph6 end
@traitfn function savegraph6(io::IO, g::::(!LightGraphs.IsDirected), gname::String = "graph")
  str = _graphToG6String(g)
  println(io, str)
  return 1
end

function savegraph6_mult(io::IO, graphs::Dict)
  ng = 0
  sortkeys = sort(collect(keys(graphs)))
  for gname in sortkeys
    ng += savegraph6(io, graphs[gname], gname)
  end
  return ng
end

loadgraph(io::IO, gname::String, ::Graph6Format) = loadgraph6(io, gname)
loadgraphs(io::IO, ::Graph6Format) = loadgraph6_mult(io)
savegraph(io::IO, g::AbstractGraph, gname::String, ::Graph6Format) = savegraph6(io, g, gname)
savegraph(io::IO, d::Dict, ::Graph6Format) = savegraph6_mult(io, d)

end # module
