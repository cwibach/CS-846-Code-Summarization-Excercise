function [newPairings, newCosts] = prunePairings(pairings, costs, numData)
    newPairings = [];
    newCosts = [];
    HOURLY_PAY = 45;
    
    for i = 1:size(pairings,2)
        % for each pairing get pairing & cost
        pairing = pairings(:,i);
        cost = costs(1,i);
        flightTime = zeros(5,1);
        
        % record flight time on each day in pairing
        for leg = 1:size(pairing,1)
            if (pairing(leg,1) == 1)
                day = numData(leg,1);
                time = numData(leg,4);
                flightTime(day,1) = flightTime(day,1) + time;
            end
        end

        legal = 1;
        if (flightTime(1,1) > 0) && (flightTime(5,1) > 0)
            % if has flights on both day 1 & 5: illegal
            legal = 0;
        elseif max(flightTime) > 480
            % if flies over 8 hours in single day: illegal
            legal = 0;
        else
            for day = 1:5
                if (flightTime(day,1) > 0)
                    % if flies under 5.5 hours in day, add extra pay
                    extraTime = max(0, 330 - flightTime(day,1));
                    cost = cost + extraTime*HOURLY_PAY/60;
                end
            end
        end

        if legal
            % return all legal pairings
            newPairings = [newPairings, pairing];
            newCosts = [newCosts, cost];
        end
    end
end