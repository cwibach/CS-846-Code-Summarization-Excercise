function combinations = findCombinations(numData, strData, overnights, maxLayover)

    combinations = dictionary;
    for i=1:size(numData,1)
        % get list of possible connections for each
        destinations = [];
        for j=1:size(numData,1)
            % check if each other flight is a feasible connection
            if (isFeasibleCombo(numData(i,:), strData(i, :), numData(j,:), strData(j,:), overnights, maxLayover))
                destinations(end+1) = j;
            end
        end
        if size(destinations,1) > 0
            % add to dictionary if has at least 1 feasible
            combinations(i) = {destinations};
        end
    end
    fprintf('Combinations Done\n')
end