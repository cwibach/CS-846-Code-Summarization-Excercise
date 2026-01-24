function [pairings, costs] = makePairings(numData, strData, combinations, MFU, MBW, deadheads)
    pairings = [];
    costs = [];
    num_legs = size(numData, 1);
    flightUsage = zeros(num_legs, 1);
    
    % go through and use possible starting flights
    for i=1:size(strData,1)
        if (strData(i,1) == "ATL")
            % flight starts in Atlanta
            init_pairing = zeros(num_legs,1);
            init_pairing(i) = 1;
            % use this as starting flight
            [pairs, new_costs, flightUsage] = buildBranches(i, flightUsage, numData, strData, init_pairing, 0, combinations, MFU, MBW, deadheads);

            pairings = [pairings, pairs];
            costs = [costs, new_costs];
        elseif ((numData(i,1)==1) && (numData(i,2) < 720))
            % use this as starting point with overnight flight before
            init_pairing = zeros(num_legs,1);
            init_pairing(i) = 1;
            [pairs, new_costs] = buildBranches(i, flightUsage, numData, strData, init_pairing, 200 + 4*9, combinations, MFU, MBW, deadheads);

            pairings = [pairings, pairs];
            costs = [costs, new_costs];
        elseif (deadheads > 0)
            % use this as starting point with overnight flight before
            init_pairing = zeros(num_legs,1);
            init_pairing(i) = 1;
            [pairs, new_costs] = buildBranches(i, flightUsage, numData, strData, init_pairing, 3000, combinations, MFU, MBW, deadheads);

            pairings = [pairings, pairs];
            costs = [costs, new_costs];
        end
    end
    fprintf('Pairings Made\n')
    % now that max set is generated, cut some out that now violate stuff
end