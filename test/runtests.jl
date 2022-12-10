using PkgGraph
using PkgGraph: depgraph, depgraph_url, rendering_urls, set_rendering_url,
                deps_as_DOT, create_depgraph, to_DOT_str,
                depgraph_local, is_dot_available
using Test

@testset "PkgGraph.jl" begin

    @test create_depgraph("TOML") == [
        "TOML" => "Dates",
        "Dates" => "Printf",
        "Printf" => "Unicode"
    ]

    dotstr =
    """
    digraph {
        TOML -> Dates
        Dates -> Printf
        Printf -> Unicode
    }
    """

    @test deps_as_DOT(:TOML) == dotstr

    urlencoded = "digraph%20%7B%0A%20%20%20%20TOML%20-%3E%20Dates%0A%20%20%20%20" *
                 "Dates%20-%3E%20Printf%0A%20%20%20%20Printf%20-%3E%20Unicode%0A%7D%0A"

    @test depgraph_url("TOML") == "https://dreampuf.github.io/GraphvizOnline/#" * urlencoded

    set_rendering_url(last(rendering_urls))

    @test depgraph_url("TOML") == "https://edotor.net/?engine=dot#" * urlencoded


    if VERSION ≥ v"1.8"  # Julia v1.7 does not support error string matching
        @test_throws(
            "The given package (DinnaeExist) must be installed in the active project",
            depgraph("DinnaeExist")
        )
    end

    @test is_dot_available() isa Bool
end
