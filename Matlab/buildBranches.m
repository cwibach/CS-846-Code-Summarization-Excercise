function [pairings, costs, flightUsage] = buildBranches(startIndex, flightUsage, numData, strData, ...
    pairing, cost, combinations, MFU, MBW, deadheads)
    pairings = [];
    costs = [];

    % start with one pairing that includes startIndex
    % start with one cost of up to this point, calculated previously
    numBranches = 0;
    branchLegs = [0];

    % for every possible branch
    if isKey(combinations, startIndex)
        canBranchLegs = combinations{startIndex};
        for i = 1:size(canBranchLegs,2)
            % get index of branch flight
            flightIndex = canBranchLegs(i);
            % ensure not overused flight & not branching too wide
            if ((flightUsage(flightIndex) < MFU) && (numBranches < MBW))
                % increase flight use, add branch, and add branch count
                flightUsage(flightIndex) = flightUsage(flightIndex) + 1;
                branchLegs(numBranches + 1) = flightIndex;
                numBranches = numBranches + 1;
            end
        end
    end

    if (branchLegs(1) > 0)
        % for each branch, add pairings that result from it
        % add cost of using that next flight before passing in
        for i = 1:size(branchLegs,2)
            nextFlight = branchLegs(i);
            newPairing = pairing;
            newPairing(nextFlight) = 1;
            newCost = cost;
            layoverNights = numData(nextFlight,1) - numData(startIndex,1);
            % calculate and add new cost
            layoverTime = numData(nextFlight,2) - numData(startIndex,3) + 1440*(layoverNights);
            newCost = newCost + 200*(layoverNights) + (4/60)*layoverTime;
            
            % recursively call this function with pairing up to point and cost
            [newPairings, newCosts, flightUsage] = buildBranches(nextFlight, flightUsage, numData, strData, ...
                newPairing, newCost, combinations, MFU, MBW, deadheads);
            pairings = [pairings, newPairings];
            costs = [costs, newCosts];
        end
    end

    if (strData(startIndex,2) == "ATL")
        % if this flight ends in ATL, add to pairings set
        pairings = [pairing, pairings];
        costs = [costs, cost];
    elseif ((numData(startIndex,1)==5) && numData(startIndex,3)>720)
        % ends in second half of last day, also add to pairings
        pairings = [pairing, pairings];
        costs = [costs, cost];
    elseif (deadheads > 0)
        % add return with deadhead
        pairings = [pairing, pairings];
        costs = [costs, cost+3000];
    end
end