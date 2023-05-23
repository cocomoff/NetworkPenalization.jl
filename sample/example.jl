using Graphs
using Random
using NetworkPenalization
using Measures
using Colors
using Plots
gr()


function visualize(g, locations, pathset, dictC=weights(g))

    xmin = minimum(minimum(locations[path, 1]) for path in pathset)
    xmax = maximum(maximum(locations[path, 1]) for path in pathset)
    ymin = minimum(minimum(locations[path, 2]) for path in pathset)
    ymax = maximum(maximum(locations[path, 2]) for path in pathset)
    delta = 1e-5
    xlim = (xmin - delta, xmax + delta)
    ylim = (ymin - delta, ymax + delta)


    f = plot(figsize=(600, 600), xlims=xlim, ylims=ylim)
    
    # edges
    for n in vertices(g)
        for m in neighbors(g, n)
            (n > m) && continue
            pX = locations[[n, m], 1]
            pY = locations[[n, m], 2]
            plot!(f, pX, pY, linewidth=1, color=:black, label=nothing)
        end
    end

    # nodes
    scatter!(f, locations[:, 1], locations[:, 2], color=:tomato, label=nothing)

    # paths
    colors = distinguishable_colors(length(pathset))
    for (ip, path) in enumerate(pathset)
        for i in 1:num_edge(path)
            pX = locations[[path[i], path[i + 1]], 1]
            pY = locations[[path[i], path[i + 1]], 2]
            plot!(f, pX, pY, linewidth=1, color=colors[ip], lw=5, alpha=0.5, label=nothing)
        end
    end

    savefig(f, "output.png")


    # metric trace plot
    pK = 1:length(pathset)
    pY1, pY2, pY3 = [], [], []
    for k in pK
        rK = pathset[1:k]
        eval_ent = edge_load_entropy(rK)
        eval_red = redundancy(g, rK, dictC)
        eval_div = diversity(g, rK, dictC)
        push!(pY1, eval_ent)
        push!(pY2, eval_red)
        push!(pY3, eval_div)
    end

    f = plot(size=(600, 300))
    plot!(f, pK, pY1, marker=:v, label="ELE")
    plot!(f, pK, pY2, marker=:o, label="Redundancy")
    plot!(f, pK, pY3, marker=:^, label="Div")
    savefig(f, "output-metric-trace.png")
end

function main(;city="nihonbashi", K=30)
    fn_loc = "$city-loc.txt"
    fn_road = "$city-road.txt"

    # read (lon, lat) array
    locations = nothing
    open(fn_loc, "r") do f
        files = readlines(f)
        files = files[2:end]

        nv = length(files)
        locations = zeros(nv, 2)

        for line in files
            sp = split(line)
            nid = parse(Int, sp[1])
            lon = parse(Float64, sp[2])
            lat = parse(Float64, sp[3])
            locations[nid, :] = [lon, lat]
        end
    end

    (locations === nothing) && let 
        @warn "Input file is invalid."
        return
    end

    # build G
    g = nothing
    dictC = zeros(size(locations, 1), size(locations, 1))
    open(fn_road, "r") do f
        files = readlines(f)
        files = files[2:end]

        g = Graph(size(locations, 1))

        for line in files
            sp = split(line)
            u = parse(Int, sp[2])
            v = parse(Int, sp[3])
            wuv = parse(Float64, sp[4])
            add_edge!(g, u, v)
            dictC[u, v] = wuv
        end
    end


    # random problem
    s, t = rand(1:nv(g), 2)
    while s == t
        s, t = rand(1:nv(g), 2)
    end
    println("(s,t)=($s,$t)")

    state_st = dijkstra_shortest_paths(g, s, dictC)
    dist_st = state_st.dists[t]
    path_st = enumerate_paths(state_st, t)
    println(dist_st)
    println(path_st)

    # penalization and K routes
    res = path_penalization(g, s, t, K, 0.5, dictC)
    for path in res
        dp = shortest_path_distance(g, path, dictC)
        dp = round(dp, digits=3)
        println(dp, " ", path[1:5])
    end

    # evaluate
    eval_ent = edge_load_entropy(res)
    eval_red = redundancy(g, res, dictC)
    eval_div = diversity(g, res, dictC)

    println("ELE(res):=$(eval_ent)")
    println("Red(res):=$(eval_red)")
    println("Div(res):=$(eval_div)")

    # visualize
    visualize(g, locations, res, dictC)
end

main()