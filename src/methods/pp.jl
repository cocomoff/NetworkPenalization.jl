"""
Algorithm 2: Path Penalization

Input
=====
    - g::Graph
    - s::Int, source vertex
    - t::Int, target vertex
    - k::Int=3, number of paths
    - p::Float64=0.1, penalization factor
    - d::AbstractMatrix=weights(g), distance matrix if given.

Output
=====
    - ps::MultiPath, set of k s-t paths.
"""
function path_penalization(
    g::Graph, s::Int, t::Int, k::Int=3,
    p::Float64=0.1, d::AbstractMatrix=weights(g))

    returnset = Path[]

    # Weights for computation
    W = zeros(nv(g), nv(g))
    W .= Inf
    for n in vertices(g)
        for m in neighbors(g, n)
            W[n, m] = d[n, m]
        end
    end

    
    for _ in 1:k
        state_i = dijkstra_shortest_paths(g, s, W)
        path_i = enumerate_paths(state_i, t)
        push!(returnset, path_i)

        for i in 1:num_edge(path_i)
            u, v = path_i[i], path_i[i + 1]
            new_wuv = W[u, v] * (1 + p)
            W[u, v] = W[v, u] = new_wuv
        end
    end

    returnset
end