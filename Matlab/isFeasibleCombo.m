function possible = isFeasibleCombo(nData1, sData1, nData2, sData2, overnights, maxLayover)


    possible = false;
    if (nData1(2) > nData1(3))
        % if flight goes over midnight, increase day (end matters more)
        nData1(1) = nData1(1) + 1;
    end
    
    % ensure airport is same
    if (not(strcmp(sData1(2), sData2(1))))
        return
    end
    
    if (nData1(1) == nData2(1))
        % same day
        % ensure sufficient time gap if same day
        if (nData1(3) + 20 >= nData2(2))
            return
        end
    
        if (nData1(3) + maxLayover < nData2(2))
            % if too long of same day layover
            return
        end
    
        if (nData1(4) + nData2(4) > 480)
            % if these two together are too much flight time
            return
        end
    elseif (nData1(1) > nData2(1))
        return
    elseif (nData1(1) + overnights >= nData2(1))
        % later day that is legal
        timeBetween = 1440*(nData2(1) - nData1(1)) - nData1(3) + nData2(2);
        if (timeBetween < 540)
            % if less than 9 hour overnight layover
            return
        end
    else
        % if would be overnight layover
        return
    end
    % no criteria indicates impossible
    possible=true;
end


