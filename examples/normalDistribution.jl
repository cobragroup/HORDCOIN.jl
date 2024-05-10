# normalDistribution.jl: Multivariate normal distribution example 

using EntropyMaximisation

using Distributions, LinearAlgebra, Random
using Mosek # Can be changed for SCS


function discretize(val)::Int
    if val < -10
        return 1
    elseif val < -6
        return 2
    elseif val < -3
        return 3
    elseif val < -1
        return 4
    elseif val < 0
        return 5
    elseif val < 1
        return 6
    elseif val < 3
        return 7
    elseif val < 6
        return 8
    elseif val < 10
        return 9
    else
        return 10
    end
end

# distribtution setup
A = [0.0  0.5  1.0  1.5  2.0;
     1.5  0.0 -1.0 -0.5  1.5;
     1.0 -1.0  0.5  3.0 -2.5;
     0.5  1.0  2.0  0.0  1.5;
     2.5 -2.0 -2.5 -1.5  2.5];
Σ = A * A' 
d = MvNormal(zeros(5), Σ)

# distribution generation
Random.seed!(15);
samples_10m = rand(d, 10_000_000);
samples_1k = rand(d, 1_000);

discrete_10m = discretize.(samples_10m)
distribution_10m = zeros(Int, 10, 10, 10, 10, 10);

discrete_1k = discretize.(samples_1k)
distribution_1k = zeros(Int, 10, 10, 10, 10, 10);

for x in eachcol(discrete_10m);
    distribution_10m[x...] += 1;
end
normalised_10m = distribution_10m ./ sum(distribution_10m);

for x in eachcol(discrete_1k);
    distribution_1k[x...] += 1;
end
normalised_1k = distribution_1k ./ sum(distribution_1k);

# Calculation of connected information:
# 1. fixing the marginal distribtutions
connected_information(normalised_10m, [2, 3, 4, 5])
connected_information(normalised_1k, [2, 3, 4, 5])

# 2. fixing the marginal entropies using polymatroid method
# a) using entropy estimate from empirical distribution
method = RawPolymatroid(0.0, false, Mosek.Optimizer())

ci_raw_10m, ent_raw_10m = connected_information(distribution_10m, collect(2:5); method)
ci_raw_1k, ent_raw_1k = connected_information(distribution_1k, collect(2:5); method)

# b) using NSB estimator (tooks approx 2 minutes)
method = NsbPolymatroid(false, Mosek.Optimizer(), 0.01)

ci_nsb_10m, ent_nsb_10m = connected_information(distribution_10m, collect(2:5); method)
ci_nsb_1k, ent_nsb_1k = connected_information(distribution_1k, collect(2:5); method)

# Computing results - normalized (and sorted) connected information
function normalise_and_sort_dict(dictionary)
    return sort(collect(map(x -> (x[1] => round(x[2]./sum(values(dictionary)), digits = 3)), collect(dictionary))), by = x -> x[1])
end

normalise_and_sort_dict(ci_raw_10m)
normalise_and_sort_dict(ci_raw_1k)

normalise_and_sort_dict(ci_nsb_10m)
normalise_and_sort_dict(ci_nsb_1k)