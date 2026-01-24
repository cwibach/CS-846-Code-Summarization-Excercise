function [newBases, newCosts, newBreakPoints, result, objVals] = mergeBases(branchBases, branchCosts, breakPoints)
    newBases = [];
    newCosts = [];
    objVals = [];
    
    numModels = size(breakPoints,2) - 1;
    newBreakPoints = zeros(1,size(numModels,2) + 1);
    % set up for new breakpoints
    for i = 1:(numModels/2)
        break1 = breakPoints(i*2 - 1)+1;
        break2 = breakPoints(i*2+1);
        newBasis = branchBases(:, break1:break2);
        newCost = branchCosts(1, break1:break2);
        % combine costs & pairings from 2 previous models
        
        % run model
        result = runModel2(newBasis, newCost);
        
        % get key results from model
        if (result.status == "OPTIMAL")
            alpha = result.x;
            objVals = [objVals, result.objval];
            
            for j = 1:size(alpha,1)
                if (alpha(j,1) > 0)
                    newBases = [newBases, newBasis(:,j)];
                    newCosts = [newCosts, newCost(:,j)];
                end
            end
            
            % set new break points
            newBreakPoints(1, i+1) = size(newCosts, 2);
        end
    end
end