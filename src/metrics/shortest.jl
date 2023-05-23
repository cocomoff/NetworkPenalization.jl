num_edge(path::Path) = length(path) - 1

function shortest_path_distance(g::Graph, path::Path, d::AbstractMatrix=weights(g))
    cost = 0.0
    for i in 1:num_edge(path)
        cost += d[path[i], path[i + 1]]
    end
    cost
end


