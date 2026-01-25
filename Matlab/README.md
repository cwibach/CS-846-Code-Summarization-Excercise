# READ ME #

This series of Matlab files was used to create a set of flight duties for crews using a dataset of flights from Delta Airlines.

The flight data provided was read in, and then optimization techniques were used to create an algorithm which created a set of pairings to schedule a crew on each flight with the goals of minimizing costs and total cost of flight crews. It does not find the optimal solution, as the problem size is far too large for that to be feasible, even if larger computational power were used.

Some functions are omitted (initialModels, findOptimal) for brevity.

fullProgram.m runs through the program iteratively and improves step by step, and may be useful to understand at what stage each function is used