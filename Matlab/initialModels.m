function [optiBasis, basisCosts, optiBreakPoints, objVals] = initialModels(pairings, costs, breakPoints)
    numBatches = size(breakPoints,2) - 1;
    optiBasis = []; % all optimal basis from all models
    basisCosts = []; % costs for optimal basis from all models
    optiBreakPoints = zeros(size(breakPoints)); % where each model begins in basis
    objVals = zeros(size(1, numBatches)); % objective values
    num_legs = size(pairings,1); 
    numBatches = size(breakPoints,2) - 1;
    

    for i = 1:numBatches
        % get set of pairings & costs for each batch
        startPoint = breakPoints(1,i);
        endPoint = breakPoints(1, i+1);
        batchPairings = pairings(:, startPoint:endPoint-1);
        batchCosts = costs(1, startPoint:endPoint-1);
        
        % add 3000 cost for each leg in each pairing
        num_pairings = size(batchPairings,2);
        for (j = 1:num_pairings)
            legs = dot(ones(num_legs,1), pairings(:,j));
            batchCosts(j) = batchCosts(j) + 3000*legs;
        end
        
        % add identity matrix to coefficients with costs of 9000
        batchPairings = [batchPairings, eye(num_legs)];
        batchCosts = [batchCosts, 9000*ones(1,num_legs)];
        
        % run Model
        result = runModel2(batchPairings, batchCosts);

        % if model succeeds . . .
        if (result.status == "OPTIMAL")
            % extract optimal basis
            objVals(1,i) = result.objval;
            alpha = result.x;
            optiPairings = [];
            optiCosts = [];
            
            for (pairing = 1:size(alpha,1))
                if (alpha(pairing,1)>0)
                    optiPairings = [optiPairings, batchPairings(:, pairing)];
                    optiCosts = [optiCosts, batchCosts(1, pairing)];
                end
            end
            
            % add to optimal basis with breakpoint
            optiBasis = [optiBasis, optiPairings];
            basisCosts = [basisCosts, optiCosts];
            optiBreakPoints(1, i+1) = size(optiBasis, 2);
        end
    end
end