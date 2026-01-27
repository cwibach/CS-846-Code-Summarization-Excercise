function [pairing, cost, dutiesCovered] = combineDuties(pairing, cost, curIndex, combinations, duties, costs, dutiesCovered)

    if (isKey(combinations, curIndex))
        considerDuties = combinations{curIndex};
        i = 1;

        while ismember(considerDuties(1,i), dutiesCovered)
            i = i+1;
            if i > size(considerDuties,2)
                return
            end
        end
        newIndex = considerDuties(i);
        
        % found legal next duty to add
        cost = cost + costs(1,newIndex);
        pairing = pairing + duties(:, newIndex);
        dutiesCovered(end+1) = newIndex;
        [pairing, cost, dutiesCovered] = combineDuties(pairing, cost, newIndex, combinations, duties, costs, dutiesCovered);
    end
end