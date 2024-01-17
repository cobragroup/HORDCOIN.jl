# comparison.jl:

using EntropyMaximisation

using Random, BenchmarkTools


function create_distribution(dims::Int, size::Int; examples::Int = 10_000_000)
    Random.seed!(15);
    discrete = rand(1:size, (examples, dims));

    distribution = zeros([size for i in 1:dims]...);

    for x in eachrow(discrete);
        distribution[x...] += 1;
    end

    distribution = distribution ./ sum(distribution);
    return distribution
end

for i in 2:4
    println(i)
    distribution = create_distribution(i, 10);
    for j in 1:i-1
        println("marginal size ", j)
        println("Cone Mosek")
        b = @benchmark maximize_entropy($distribution, $j, method = Cone(MosekOptimizer()))
        display(b)
        println("Cone SCS")
        b = @benchmark maximize_entropy($distribution, $j, method = Cone())
        display(b)
        println("ipfp 10 steps")
        b = @benchmark maximize_entropy($distribution, $j, method = Ipfp(10))
        display(b)
        try
            println("Gradient")
            b = @benchmark maximize_entropy($distribution, $j, method = Gradient(10))
            display(b)
        catch e
            println("DomainError")
        end
    end
end

i = 5;
distribution = create_distribution(i, 10);
for j in 1:i-1
    println("marginal size ", j)
    println("Cone Mosek")
    b = @benchmark maximize_entropy($distribution, $j, method = Cone(MosekOptimizer()))
    display(b)
end
