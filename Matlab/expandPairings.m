function [newPairings] = expandPairings(oldPairings, indexes, newSize)
    % take in old list of pairings, indices, and new size to reset to
    % return new set of pairings in proper size

    % convert indexes of smaller set of legs to larger set of legs
    newPairings = zeros(newSize, size(oldPairings,2));
    % make set of pairings with size of larger set of legs
    for i = 1:size(oldPairings,2)
        % get each pairing
        pairing = oldPairings(:,i);
        for j = 1:size(pairing,1)
            % get index that has value
            if (pairing(j,1) == 1)
                % find index in larger set of legs and set to 1
                newIndex = indexes(j,1);
                newPairings(newIndex, i) = 1;
            end
        end
    end
end