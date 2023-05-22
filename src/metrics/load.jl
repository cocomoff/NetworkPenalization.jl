"""
Compute edge load (`Def. 5.1`).

Input
=====
    - ps::MultiPath{T}: a set of paths in G.

Output
=====
    - counter::Counter{Tuple{T, T}, Int}: the number of paths in ps that contains edges (i.e., Tuple{T, T}).
"""
function edge_load(ps::MultiPath{T}) where {T <: Real}
    counter = Dict()
    for path in ps
        for i in 1:num_edge(path)
            ei = (path[i], path[i + 1])
            counter[ei] = get(counter, ei, 0) + 1
        end
    end
    counter
end


"""
Compute edge load entropy (`Def. 5.2`).

Input
=====
    - ps::MultiPath{T}: a set of paths in G.

Output
=====
    - ele::Float64, the computed edge load entropy value.
"""
function edge_load_entropy(ps::MultiPath{T}) where {T <: Real}
    ele = 0.0
    counter = edge_load(ps)
    for (_, value) in counter
        p = value / length(ps)
        ele -= (p * log2(p))
    end
    ele
end