"""
Path consists of vertices of type T.
"""
const Path{T} = Array{T, 1} where T

"""
PathSet consists of multiple paths of Path{T}.
"""
const MultiPath{T} = Vector{Path{T}} where T