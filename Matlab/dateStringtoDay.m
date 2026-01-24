function date = dateStringtoDay(dateStrings)
    % split date and take day portion
    date = zeros(size(dateStrings,1),1);
    for i = 1:size(dateStrings, 1)
        stringParts = split(dateStrings(i), "-");
        date(i) = str2double(stringParts(1));
    end
end