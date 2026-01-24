function [finalPairings, finalCosts, result, objVals] = findOptimal(branchBases, branchCosts, breakPoints)
    modelCount = size(breakPoints,2) - 1;
    % count how many models results exist
    objVals = [];

    while modelCount > 1
        % while at least 1 model, merge results
        [newBases, newCosts, newBreakPoints, newResult, newObjVals] = mergeBases(branchBases, branchCosts, breakPoints);
        modelCount = size(newBreakPoints, 2) - 1;
        % get current results
        result = newResult;
        branchBases = newBases;
        branchCosts = newCosts;
        breakPoints = newBreakPoints;
        objVals = [objVals, newObjVals];
    end
    
    % get final results
    finalPairings = branchBases;
    finalCosts = branchCosts;
    fprintf('Models Complete\n')
end