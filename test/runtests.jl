using EntropyMaximisation
using Test

@testset "EntropyMaximisation.jl" begin

    d1 = [0.25 0.25; 0.25 0.25]
    d2 = [0 1; 0 0]
    d3 = [0.5 0.5; 0 0]
    d4 = [-0.5 0.5; 0.5 0.5]

    @testset "Distribution entropy" begin
        @test distribution_entropy(d1) == 2
        @test distribution_entropy(d2) == 0
        @test distribution_entropy(d3) == 1
        @test_throws DomainError distribution_entropy(d4)
    end
    @testset "Permutations of length" begin
        @test permutations_of_length(1, 1) == [(1,)]

        @test_throws DomainError permutations_of_length(0, 3)
        @test permutations_of_length(1, 3) == [(1,), (2,), (3,)]
        @test permutations_of_length(2, 3) == [(1, 2), (1, 3), (2, 3)]
        @test permutations_of_length(3, 3) == [(1, 2, 3)]
        @test_throws DomainError permutations_of_length(4, 3)

        @test permutations_of_length(2, 5) == [(1, 2), (1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5), (3, 4), (3, 5), (4, 5)]
    end
end
