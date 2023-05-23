"""
Algorithm 1': Path Randomization

Input
=====
    - g::Graph
    - s::Int, source vertex
    - t::Int, target vertex
    - k::Int=3, number of paths
    - delta::Float64=0.1, noise parameter
    - tau::Float64=1, tolerence parameter
    - d::AbstractMatrix=weights(g), distance matrix if given.

Output
=====
    - ps::MultiPath, set of k s-t paths.
"""
function path_randomization(
    g::Graph, s::Int, t::Int, k::Int=3,
    delta::Float64=0.1, tau::Float64=1.0, d::AbstractMatrix=weights(g))

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
            new_wuv = W[u, v] + randn() * W[u, v] ^ 2 * delta ^ 2
            we = max(tau, new_wuv)
            W[u, v] = W[v, u] = we
        end
    end

    returnset
end