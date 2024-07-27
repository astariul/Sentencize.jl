using Sentencize
using Test

using Sentencize
using Test
using Aqua

@testset "Sentencize.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(Sentencize)
    end
    include("Sentencize.jl")
end
