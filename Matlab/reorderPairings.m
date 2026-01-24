function [newPairings, newCosts, breakPoints] = reorderPairings(pairings, costs, newNumMatrices)
% reorder pairings into n new sets split evenly
% matrix for new pairings & costs, and break points for new matrices
    newPairings = zeros(size(pairings));
    newCosts = zeros(size(costs));
    numPairings = size(pairings,2);
    breakPoints = zeros(1, newNumMatrices+1);
    breakPoints(1,1) = 1;

    step = newNumMatrices;
    curIndex = 1;
    curStart = 1;
    % insert old pairings in new order to make new sets
    for i = 1:size(pairings,2)
        newPairings(:, i) = pairings(:, curIndex);
        newCosts(i) = costs(curIndex);

        curIndex = curIndex + step;
        if (curIndex > numPairings)
            % indicate new set of pairings has begun
            breakPoints(1,curStart+1) = i+1;
            curStart = curStart + 1;
            curIndex = curStart;
        end
    end
end
