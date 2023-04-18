# QuantLearning Repository: Quantifying the value of learning for flexible water infrastructure planning

Matlab implementation of a stochastic dynamic program (SDP) for replicating the results in:
* Skerker, J.B., Zaniolo, M., Willebrand, K., Lickley, M., and Fletcher, S.M., Quantifying the value of learning for flexible water infrastructure planning, Water Resources Research, 2023. 

DOI badge: [![DOI](https://zenodo.org/badge/626448634.svg)](https://zenodo.org/badge/latestdoi/626448634)

Code documentation by: Jenny Skerker, Stanford University
Last updated: April 2023

## Main components

1. Bayes' formulation to create the transition matrices through setting high/low learning parameters
2. The infrastructure planning stochastic dynamic program (SDP) that determines the optimal static and flexible dam policies for given dam sizes and expansions
3. The primary model that uses the infrastructure SDP to determine the optimal static and flexible dam sizes and policies in one integrated model

## Detailed model components and data

1. Precipitation transition matrices: These are saved under Mwache_Dam/Synthetic_TransMatrices/Bayes_July2022
* They are .mat files with 71 x 71 x 5 matrices (# precipitation states used = 71, # time periods = 5)

2. `TPs_create_VERSION2.m`: The precipitation transition matrices can also be recreated using this file, and the input parameters can be changed as needed.

3. `multiflex_sdp_climate_StaticFlex_DetT_StateSpace.m`: This file runs the infrastructure planning SDP that is called in `Multiflex_OptimizeSimulate.m`. This file is the primary script for interacting with and running the code as a user. The parameter setup for the file explicitly defines some parameters and inputs others from `Multiflex_OptimizeSimulate.m`. The run parameters can be used to run or not run different components of the model. The main model components include: 
* a Bayesian model (set runParam.calcTmat to False)
* a stochastic weather generator using k-nearest neighbors based on GCM results (set runParam.TPts to False)
* CLIRUN-II, a hydrological model (set runParam.runRunoff to False)
* a reservoir operations model that can be adaptive or non-adaptive (set runParam.optReservoir = True/False) (set runParam.calcShortage parameter to False). The adaptive reservoir operations model updates every 20 years based on updated climate state information.
* the SDP using backwards recursion (set runParam.runSDP based on `Multiflex_OptimizeSimulate.m`)
* Monte Carlo forward simulations (set runParam.forwardSim based on `Multiflex_OptimizeSimulate.m`)

4. `Multiflex_OptimizeSimulate.m`: This file is the primary optimization model code that takes in the precipitation transition matrices (high/low learning) (the user needs to update the file locations and scenarios being run), finds the optimal flexible and static dam designs (using the infrastructure planning SDP in 3.), and then determines the optimal policies using the optimal dam designs. The model iterates through each candidate dam design and selects the one that performs best by minimizing the expected total discounted costs. 

5. `multiflex_sdp_climate_StaticFlex_DetT_RainRunoff.m`: this file is a copy of 4., but the parameters are configured differently to only run the stochastic weather generator and the rainfall-runoff model. Then, this data is saved, and can be used to save time when running the wrapper function. This component was run on a supercomputing cluster. The output data from this include time series for precipitation, temperature, and runoff. For precipitation and temperature, there are time series for each time period (5) and each climate state. For runoff, there are time series for each combination of precipitation and temperature for each time period. The currently used data is saved in two files within the CLIRUN subfolder: `PT_by_state_06Oct2021.mat` and `runoffOnly_by_state_06Oct2021.mat`.

6. PostProcess_SDP_ReservoirResults: this folder contains the adaptive and non-adaptive shortage costs. The model parameter runParam.calcShortage must be set to False so that the pre-saved data is loaded. 

## How to obtain the high and low learning optimization and simulation results

1. Download the Github repository
2. Change the file paths and run the line: 
```
addpath(genpath('repo location/QuantLearning'))
```
3. Use the pre-made transition matrices in the Bayes_July2022 folder or run `TPs_create_VERSION2.m` and update/edit the parameters as needed.
4. Use the `multiflex_sdp_climate_StaticFlex_DetT_RainRunoff.m` file to obtain monthly time series for runoff using the transition matrices created in 3 or use the pre-run data in `PT_by_state_06Oct2021.mat` and `runoffOnly_by_state_06Oct2021.mat`.
5. Use the pre-made adaptive or non-adaptive shortage cost results obtained previously from the reservoir operations model.
6. Use the `Multiflex_OptimizeSimulate.m` wrapper function to run the optimization and simulation to determine the optimal static and flexible dam sizes and policies.
7. Plot the results (and recreate the paper figures) using Plots/PaperFigures
