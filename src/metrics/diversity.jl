"""
Compute the diversity value following `Def. 3.3`.

Input
=====
    - g::Graph
    - ps::MultiPath{T}
    - d::AbstractMatrix

Output
=====
    - div(ps)::Float64

"""
function diversity(g::Graph, ps::MultiPath{T}, d::AbstractMatrix=weights(g)) where {T <: Real}
    # Check (s, t) constraint
    path = collect(ps)[begin]
    allS = Set{T}(path[begin] for path in ps)
    allE = Set{T}(path[end] for path in ps)
    @assert length(allS) == 1
    @assert length(allE) == 1
    
    # denom (length of shortest path)
    s, t = path[begin], path[end]
    state = dijkstra_shortest_paths(g, s, d)
    path_st = enumerate_paths(state, t)
    @assert !isempty(path_st) && path_st[begin] == s && path_st[end] == t
    denom = shortest_path_distance(g, path_st, d)

    # numer
    allEdge = Set{Tuple{T, T}}()
    for path in ps
        for i in 1:num_edge(path)
            push!(allEdge, (path[i], path[i + 1]))
        end
    end
    numer = sum(d[u, v] for (u, v) in allEdge)

    # diversity: numer / denom - 1
    numer / denom - 1
end