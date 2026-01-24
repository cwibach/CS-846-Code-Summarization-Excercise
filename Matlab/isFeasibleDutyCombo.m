function possible = isFeasibleDutyCombo(dutyData1, dutyData2)
    possible = false;
    layoverNights = dutyData2(1) - dutyData1(2);
    if (layoverNights ~= 1) % if not in the future
        return
    end

    if (dutyData2(2) - dutyData1(1) == 4)
        return % if spans all 5 days
    end

    % if total layover less than 9 hours
    if (dutyData2(3) - dutyData1(4) + 1440*layoverNights) < 540
        return
    end

    possible = true;
end