module NetworkPenalization

using Graphs

include("./data.jl")
include("./metrics/shortest.jl")
include("./metrics/diversity.jl")
include("./metrics/load.jl")
include("./metrics/redundancy.jl")
include("./methods/gr.jl")
include("./methods/pr.jl")
include("./methods/pp.jl")

export Path,
       PathSet,
       num_edge,
       shortest_path_distance,

       # metrics
       edge_load,
       edge_load_entropy,
       redundancy,
       diversity,

       # methods
       graph_randomization,
       path_randomization,
       path_penalization

end