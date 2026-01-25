function date = dateStringtoDay(dateStrings)
    % take date string in
    % return day of month as number, usable as only 5 day window used
    date = zeros(size(dateStrings,1),1);
    for i = 1:size(dateStrings, 1)
        stringParts = split(dateStrings(i), "-");
        date(i) = str2double(stringParts(1));
    end
end