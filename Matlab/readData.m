function [numData, strData] = readData(fileName)

    % use filename of 'flightLegs.xlsx'
    [~,txt,~] = xlsread(fileName);
    numData = [];
    numData(:, 1) = dateStringtoDay(txt(:, 1));
    numData(:, 2) = timeStringtoMinutes(txt(:, 4));
    numData(:, 3) = timeStringtoMinutes(txt(:, 5));
    numData(:, 4) = timeStringtoMinutes(txt(:, 6));
    strData(:, 1) = txt(:, 7);
    strData(:, 2) = txt(:, 9);
    % final format:
    % numData: [date, starttime, endtime, duration]
    % strData: [start, end] (locations)
end