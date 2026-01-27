function [finalPairings, finalCosts] = dutiestoPairings(duties, costs, numData)

    dutyData = zeros(size(duties,2),4);
    % start date, end date, start time, end time

    % get information about each current duty
    for i = 1:size(duties,2)
        duty = duties(:,i);
        startTime = 0;
        endTime = 0;
        startDate = 0;
        endDate = 0;
        for leg = 1:size(duty,1)
            if (duty(leg,1) == 1)
                legData = numData(leg,:);
                if ((legData(1) < startDate) || (startDate == 0))
                    startDate = legData(1);
                    startTime = legData(2);
                elseif (legData(1) == startDate)
                    if (legData(2) < startTime)
                        startTime = legData(2);
                    end
                end

                if ((legData(1) > endDate) || (endDate == 0))
                    endDate = legData(1);
                    endTime = legData(3);
                elseif (legData(1) == endDate)
                    if (legData(3) > endTime)
                        endTime = legData(3);
                    end
                end
            end
        end
        dutyData(i,:) = [startDate, endDate, startTime, endTime];
    end

    finalPairings = [];
    finalCosts = [];

    combinations = makeDutyCombinations(dutyData);
    dutiesCovered = [];
    index = 1;

    while index <= size(costs,2)
        dutiesCovered(end+1) = index;
        duty = duties(:, index);
        cost = costs(1, index);
        
        [pairing, cost, dutiesCovered] = combineDuties(duty, cost, index, combinations, duties, costs, dutiesCovered);
        finalPairings = [finalPairings, pairing];
        finalCosts = [finalCosts, cost];

        index = index + 1;
        while (ismember(index, dutiesCovered))
            index = index + 1;
        end
    end
end