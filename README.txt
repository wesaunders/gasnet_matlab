# GasNet MATLAB Toolbox
## Introduction
This toolbox was developed for my Computing and Artificial Intelligence degree dissertation at Sussex University.

## Comments
The toolbox was arranged to provide a flexible implementation which users run gasnet simulations and a steady state genetic algorithm to train the networks for different scenarios.

It also includes a GUIDE gui (I didn't know any better), to allow users to explore the GasNets.

Known limitations:
* GA training was a little slow, the steady state implementation was not ideal for multithreading.
* Limited optimisations, lots of on-the-fly allocations, poor use of memory management.
* GUIDE GUI.

## References
These tools are developed from the GasNet model described in: P Husbands, T Smith, N Jakobi, and M O'Shea. (1998) Better Living Through Chemistry: Evolving GasNets for Robot Control. Connection Science, 10(3-4):185-210.
