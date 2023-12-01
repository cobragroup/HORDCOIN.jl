
#module Utils
#
    export distribution_entropy
    export permutations_of_length


    function entropy(probability::Float64)
        if probability == 0
            return 0
        end
        return -probability * log2(probability)
    end

    function distribution_entropy(distribution::Array{Float64})
        return sum(entropy.(distribution))
    end

    function vecs2tuples(vectors::Array{Vector{T}})::Array{Tuple{Vararg{T}}} where {T}
        return [Tuple{Vararg{T}}(v) for v in vectors]
    end
    
    
    function permutations_of_array(arr::Array{Int64}, length::Int)::Vector{Vector{Int64}}
        if length == 1
            return [[i] for i in arr]
        end
        ret = []
        for i in eachindex(arr)
            for j in permutations_of_array(arr[i+1:end], length-1)
                push!(ret, [arr[i], j...])
            end
        end
        return ret
    end
    
    function permutations_of_length(length::Int, dims::Int)::Vector{Tuple}
        permutations_of_array(collect(1:dims), length) |> vecs2tuples
    end

#end