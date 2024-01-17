# EntropyMaximisation.jl

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/B0B36JUL-FinalProjects-2023/Projekt_Kislinger/blob/main/LICENSE)

EntropyMaximisation provides methods for finding probability distribution with maximal Shannon entropy with marginal distribution constraints (according to different size of marginal distributions). Package implements various methods of optimization. Furthermore, it provides utilities to work with probability distributions.

This project was created as a part of the semestral project "Maximization of Shannon entropy under marginal constraints" at the Faculty of Electrical Engineering, Czech Technical University in Prague. Further information about the problem can be found there.

Methods used to maximize the entropy:
- Exponential Cone Programming (with different solvers)
- Iterative Proportional Fitting Procedure
- Projected Gradient Descent


## Installation
Package is not registered, but can be installed in the following way:
```julia
(@v1.9) pkg> add https://gitlab.com/kislijak/entropy-maximisation.git
```

## Usage
The main goal of this project is to implement methods to maximize Shannon entropy of probability distribution with marginal distribution constraints.

The package considers following:
- probability distribution are stored as multidimensional arrays
- probabilities are non-negative and sum up to 1
- size of marginal distributions can only be from 1 to n, where n is the number of dimensions of the probability distribution.

The main function is the `maximize_entropy` function. It takes as an input the probability distribution and the size of marginal distributions. Optional parameter is the method of optimization, which can have further specified parameters (like number of iterations, etc.). The function returns the probability distribution with maximal entropy in the form of type `EMResult`.

Basic usage of the function is the following:
```julia
using EntropyMaximisation

probability_distribution = [1/16; 3/16;; 3/16; 1/16;;; 1/16; 3/16;; 3/16; 1/16]
marginal_size = 2
maximize_entropy(probability_distribution, marginal_size)
```
Running the code with optional parameter `method`:
```julia
maximize_entropy(probability_distribution, marginal_size, method = Gradient(10, SCSOptimizer()))
```

Second function is the `connected_information` function. It takes as an input the probability distribution and the size of marginal distributions. When computing multiple connected information values for the same probability distribution, it is possible to pass the sizes as an array. This will even speed up the process, because it will reduce the number of computation. Furthermore, method used to compute the maximal entropy can be selected as well.

Basic usage of `connected_information` is the following:
```julia
connected_information(probability_distribution, 2)
connected_information(probability_distribution, [2, 3])
```
With optional parameters:
```julia
connected_information(probability_distribution, 2, method = Ipfp(15))
connected_information(probability_distribution, [2, 3], method = Cone(MosekOptimizer()))
```

Package also containts two utility functions. `distribution_entropy` computes the information entropy of probability distribution. `permutations_of_length` returns all permutations of given size from elements from 1 to dims. 

Usage of the functions:
```julia
distribution_entropy(probability_distribution)
permutations_of_length(3, 4)
```


## Recommendations

The most efficient method is the `Cone` method with `MosekOptimizer`. This requires license to use MOSEK solver. Without the license, it is possible to use `SCSOptimizer` instead, but it is less accurate and slower.

The method to use without MOSEK license is the `Ipfp`. It is accurate and not the slowest. It can also be parametrized with number of iterations, but it is not necessary. Default value is 10.

The `Gradient` method is the slowest and may fail during the execution due to limitations of Second Order Cone constraints in solvers.