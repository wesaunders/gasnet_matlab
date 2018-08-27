# GasNet MATLAB Toolbox
## Introduction
This toolbox was developed for my Computing and Artificial Intelligence degree dissertation at Sussex University.

GasNets are neural networks augmented with neuromodulating gases, causing excitory or inhibitory effects in nodes. These gases cause temporal effects in the networks introducing interesting and complex dynamics in their behaviour.

## Comments
The toolbox was arranged to provide a flexible implementation with which users can run gasnet simulations and train the networks for different scenarios with the provided steady state genetic algorithm.

It also includes a GUIDE gui (I didn't know any better), to allow users to explore the GasNets.

Known limitations:
* GA training was a little slow, the steady state implementation (derived from the literature) was not ideal for multithreading.
* Limited optimisations, lots of on-the-fly allocations, poor use of memory management.
* GUIDE GUI.

## References
These tools are developed from the GasNet model described in: P Husbands, T Smith, N Jakobi, and M O'Shea. (1998) Better Living Through Chemistry: Evolving GasNets for Robot Control. Connection Science, 10(3-4):185-210.
