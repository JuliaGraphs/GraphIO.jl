using Base: depwarn

function GEXFFormat()
    depwarn("""
            `GraphIO.GEXFFormat`  has been moved to submodule `GraphIO.GEXF` and needs `EzXML.jl` to be imported first. I.e use.
                using EzXML
                GraphIO.GEXF.GEXFFormat()
            """, :GEXFFormat)
    return GraphIO.GEXF.GEXFFormat()
end
export GEXFFormat

function GraphMLFormat()
    depwarn("""
            `GraphIO.GraphMLFormat`  has been moved to submodule `GraphIO.GraphML` and needs `EzXML.jl` to be imported first. I.e. use
                using EzXML
                GraphIO.GraphML.GraphMLFormat()
            """, :GraphMLFormat)
    return GraphIO.GraphML.GraphMLFormat()
end
export GraphMLFormat

function DOTFormat()
    depwarn("""
            `GraphIO.DOTFormat`  has been moved to submodule `GraphIO.DOT` and needs `ParserCombinator.jl` to be imported first. I.e. use
                using ParserCombinator
                GraphIO.DOT.DOTFormat()
            """, :DOTFormat)
    return GraphIO.DOT.DOTFormat()
end
export DOTFormat

function GMLFormat()
    depwarn("""
            `GraphIO.GMLFormat`  has been moved to submodule `GraphIO.GML` and needs `ParserCombinator.jl` to be imported first. I.e. use
                using ParserCombinator
                GraphIO.GML.GMLFormat()
            """, :GMLFormat)
    return GraphIO.GML.GMLFormat()
end
export GMLFormat

function Graph6Format()
    depwarn("""
            `GraphIO.Graph6Format`  has been moved to submodule `GraphIO.Graph6`. I.e. use
                GraphIO.Graph6.Graph6Format()
            """, :Graph6Format)
    return GraphIO.Graph6.Graph6Format()
end
export Graph6Format

function NETFormat()
    depwarn("""
            `GraphIO.NETFormat`  has been moved to submodule `GraphIO.NET`. I.e. use
                GraphIO.NET.NETFormat()
            """, :NETFormat)
    return GraphIO.NET.NETFormat()
end
export NETFormat

function EdgeListFormat()
    depwarn("""
            `GraphIO.EdgeListFormat`  has been moved to submodule `GraphIO.EdgeList`. I.e. use
                GraphIO.EdgeList.EdgeListFormat()
            """, :EdgeListFormat)
    return GraphIO.EdgeList.EdgeListFormat()
end
export EdgeListFormat

function CDFFormat()
    depwarn("""
            `GraphIO.CDFFormat`  has been moved to submodule `GraphIO.CDF`. I.e. use
                GraphIO.CDF.CDFFormat()
            """, :CDFFormat)
    return GraphIO.CDF.CDFFormat()
end
export CDFFormat
