function [numData2, strData2, goodPairings, goodCosts, indexes] = getBadLegs(pairings, costs, numData, strData)
    % take in current set of pairings with costs and all data
    % filter pairings to remove pairings that require flight crew to dead head both directions and only cover 1 leg
    % return new version of data with only uncovered legs, as well as fully covered pairings with costs, and indexes of uncovered legs
    num_pairings = size(costs,2);
    goodPairings = [];
    goodCosts = [];
    coveredLegs = zeros(size(pairings,1),1);
    % separate good and bad legs covered

    % for each pairing
    for i = 1:num_pairings
        pairing = pairings(:, i);
        % if it does not have the identity cost exactly
        if (costs(1,i) ~= 9000)
            % add to good pairings
            goodPairings = [goodPairings, pairing];
            goodCosts = [goodCosts, costs(1,i)];
            for j = 1:size(pairing,1)
                % mark legs as covered
                if (pairing(j,1) == 1)
                    leg = j;
                    coveredLegs(j,1) = 1;
                end
            end
        end
    end
    
    % find indexes of all not covered legs
    indexes = [];
    for i = 1:size(pairings,1)
        if (coveredLegs(i,1) == 0)
            indexes = [indexes;i];
        end
    end
    
    numData2 = zeros(size(indexes,1),4);
    % get num/str Data for all uncovered legs only
    for i = 1:size(indexes,1)
        numData2(i, :) = numData(indexes(i,1),:);
        strData2(i,:) = strData(indexes(i,1), :);
    end
end