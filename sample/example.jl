using Graphs
using Random
using NetworkPenalization

function main(;city="nihonbashi", K=5)
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
        println(path)
    end

    # evaluate
    eval_ent = edge_load_entropy(res)
    eval_red = redundancy(g, res, dictC)
    eval_div = diversity(g, res, dictC)

    println("ELE(res):=$(eval_ent)")
    println("Red(res):=$(eval_red)")
    println("Div(res):=$(eval_div)")
end

main()