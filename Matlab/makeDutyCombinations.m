function combinations = makeDutyCombinations(dutyData)
    numDuties = size(dutyData,1);
    combinations = dictionary;

    for i = 1:numDuties
        nextDuties = [];
        for j = 1:numDuties
            % check if is feasible combo
            if (i ~=j) && (isFeasibleDutyCombo(dutyData(i,:), dutyData(j,:)))
                nextDuties(end+1) = j;
            end
        end
        if (size(nextDuties,1) > 0)
            combinations(i) = {nextDuties};
        end
    end
end