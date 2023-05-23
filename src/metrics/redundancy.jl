"""
Compute the redundancy (`Def. 5.3`)

Input
=====
    - g::Graph
    - ps::MultiPath
    - d::AbstractMatrix

Output
=====
    - red(ps)::Float64
"""
function redundancy(g::Graph, ps::MultiPath, d::AbstractMatrix=weights(g))
    # numer
    numer = sum(shortest_path_distance(g, path, d) for path in ps)

    # denom
    allEdge = Set()
    for path in ps
        for i in 1:num_edge(path)
            push!(allEdge, (path[i], path[i + 1]))
        end
    end
    denom = sum(d[u, v] for (u, v) in allEdge)

    # redundancy
    numer / denom
end