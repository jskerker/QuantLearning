# Quantifying the value of learning for flexible water infrastructure planning (Mwache_Dam Repository)

Matlab implementation of a stochastic dynamic program (SDP) for replicating the results in:
* Skerker, J.B., Zaniolo, M., Willebrand, K., Lickley, M., and Fletcher, S.M., Quantifying the value of learning for flexible water infrastructure planning, Journal of Water Resources Planning and Management, accepted. 

Code documentation by: Jenny Skerker, Stanford University
Last updated: April 2023

## Main components

1. Bayes' formulation to create the transition matrices through setting high/low learning parameters
2. The optimization simulation model determines the optimal static and flexible dam sizes and policies

## Detailed model components and data

1. Precipitation transition matrices: These are saved under Mwache_Dam/Synthetic_TransMatrices/Bayes_July2022
* They are .mat files with 71 x 71 x 5 matrices (# precipitation states used = 71, # time periods = 5)

2. TPs_create_VERSION2.m: The precipitation transition matrices can also be recreated using this file, and the input parameters can be changed as needed.

3. Multiflex_OptimizeSimulate.m: This file is a wrapper function that takes in the precipitation transition matrices (high/low learning) (the user needs to update the file locations and scenarios being run), finds the optimal flexible and static dam designs, and then runs the multiflex SDP with the optimal dam sizes to obtain the optimal policy.

4. multiflex_sdp_climate_StaticFlex_DetT_StateSpace.m: This file runs the stochastic dynamic program that is called in Multiflex_OptimizeSimulate.m. The parameter setup for the file explicitly defines some parameters and inputs others from Multiflex_OptimizeSimulate.m. The run parameters can be used to run or not run different components of the model. The main model components include: 
* a Bayesian model (set to False)
* a stochastic weather generator using k-nearest neighbors based on GCM results (set to False)
* CLIRUN-II, a hydrological model (set to False)
* a reservoir operations model that can be adaptive (set to True) or non-adaptive (False) (set calcShortage parameter to False)
* the SDP using backwards recursion (set based on Multiflex_OptimizeSimulate.m)
* Monte Carlo forward simulations (set based on Multiflex_OptimizeSimulate.m)

5. multiflex_sdp_climate_StaticFlex_DetT_RainRunoff.m: this file is a copy of 4., but the parameters are configured differently to only run the stochastic weather generator and the rainfall-runoff model. Then, this data is saved, and can be used to save time when running the wrapper function. This component was run on a supercomputing cluster.

5. PostProcess_SDP_ReservoirResults: this folder contains the adaptive and non-adaptive shortage costs. The model can be run to determine the non-adaptive shortage costs, but loading in the files directly saves computation time.

## How to obtain the high and low learning optimization and simulation results

1. Download the Github repository
2. Change the file paths and run the line: 
```
addpath(genpath('repo location/Mwache_Dam'))
```
3. Use the pre-made transition matrices in the Bayes_July2022 folder or run TPs_create_VERSION2.m and update/edit the parameters as needed.
4. Use the multiflex_sdp_climate_StaticFlex_DetT_RainRunoff.m file to obtain monthly time series for runoff using the transition matrices created in 3.
5. Either use the pre-made shortage cost results or run the non-adaptive reservoir operations model to obtain them.
6. Use the Multiflex_OptimizeSimulate.m wrapper function to run the optimization and simulation to determine the optimal static and flexible dam sizes and policies.
7. Plot the results (and recreate the paper figures) using Plots/PaperFigures
