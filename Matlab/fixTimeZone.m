function newData = fixTimeZone(numData)
    % take in all numeric data, and adjust to eastern time zone from england time
    % adjust day as well as time if need be.
    % return fixed numeric data

    % new version of data
    newData = zeros(size(numData));

    % for each flight
    for i = 1:size(numData,1)
        % get data
        day = numData(i,1);
        startTime = numData(i,2);
        endTime = numData(i,3);
        flightTime = numData(i,4);
            
        % adjust start time and day if needed
        if (startTime < 240)
            day = day-1;
            startTime = startTime - 240 + 1440;
        else
            startTime = startTime - 240;
        end
            
        % adjust end time
        if (endTime < 240)
            endTime = endTime - 240 + 1440;
        else
            endTime = endTime -240;
        end
        
        % write adjusted data
        newData(i,:) = [day, startTime, endTime, flightTime];
    end
end