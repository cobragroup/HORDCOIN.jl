
module EntropyMaximisation

    # Optimize sampling in examples by creating only parts of the long matrixes
    # benchmark and compare memory and time @benchmark

    using Pkg
    using SCS
    using MathOptInterface

    export Cone
    export Gradient
    export Ipfp
    export maximize_entropy
    export connected_information

    export SCSOptimizer
    export MosekOptimizer

    include("Utils.jl")
    include("IPFP.jl")
    include("Cone.jl")
    include("MatlabParser.jl")
    include("Gradient.jl")

    abstract type AbstractMethod end

    struct Cone <: AbstractMethod
        optimizer::AbstractOptimizer
    end

    Cone() = Cone(SCSOptimizer())

    struct Gradient <: AbstractMethod
        iterations::Int
    end

    Gradient() = Gradient(1000)

    struct Ipfp <: AbstractMethod
        iterations::Int
    end

    Ipfp() = Ipfp(1000)    

    function maximize_entropy(joined_probability::Array{Float64}, marginal_size; method = Cone())

        marginal_size > ndims(joined_probability) && throw(DomainError("Marginal size cannot be greater than number of dimensions of joined probability"))
        marginal_size < 1 && throw(DomainError("Marginal size has to be possitive"))

        marginals = permutations_of_length(marginal_size, ndims(joined_probability))

        if method isa Cone
            # TODO: output is not the same as in IPFP or Gradient - list
            return cone_over_probabilities(joined_probability, marginals; solver = method.optimizer)
        elseif method isa Gradient
            return descent(joined_probability, marginals, iterations = method.iterations)
        elseif method isa Ipfp
            return ipfp(joined_probability, marginals, iterations = method.iterations)
        else
            error("Unknown method of type $(typeof(method))")
        end
    end


    function connected_information(joined_probability::Array{Float64}, marginal_size; method = Cone(MosekOptimizer()))

        marginal_size > ndims(joined_probability) && throw(DomainError("Marginal size cannot be greater than number of dimensions of joined probability"))
        marginal_size < 2 && throw(DomainError("Marginal size for connected information cannot be less than 2"))

        entropy1 = maximize_entropy(joined_probability, marginal_size - 1; method)[1]
        entropy2 = maximize_entropy(joined_probability, marginal_size; method)[1]
        return entropy1 - entropy2
    end

end
