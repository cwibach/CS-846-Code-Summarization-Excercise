## MATLAB ##

For each function, the comment should concisely state what each parameter passed to the function does/means, what the function does in 1 or 2 lines, and then briefly state what each value returned is. Simply stating the names of parameters/return values is not useful, nor is a long-winded explanation.

### buildBranches ###
Criteria:
- Take in starting index, flight usage, all data, current pairing, current cost, all combinations, max flight usage, max branch width, and if deadheads are allowed
- Recursively build branches of possible flight pairings
- Check all possible next flights and build new pairing for each one up to max width
- Return all created pairings with costs, and new flight usage

Good Example (with guidelines):

    % inputs: startIndex, flightUsage, numData, strData, pairing, cost, combinations, MFU, MBW, deadheads
    % does: recursively expands feasible connection branches from startIndex to build complete pairings and costs
    % outputs: pairings (legs x combos), costs (row vector), flightUsage (updated usage counts)


Bad Example (without guidelines):

    %BUILDBRANCHES  Recursively generate pairing branches.
    % Inputs: startIndex, flightUsage, numData, strData, pairing, cost, combinations, MFU, MBW, deadheads
    % Outputs: pairings, costs, flightUsage


### combineDuties ###
Criteria:
- Take pairing and its cost, index of the last flight in the pairing, set of combinations, duties, duty costs, and duties already covered
- Check what duties can be appended to the end of this pairing
- Return possibly updated pairing with cost and duties covered


Good Example (with guidelines):

    % inputs: pairing (legs x 1) — current pairing vector; cost (scalar) — current accumulated cost
    %         curIndex (scalar) — index of the duty to extend from; combinations (map) — duty -> feasible next duties
    %         duties (legs x duties) — duty coverage vectors; costs (1 x duties) — per-duty costs; dutiesCovered (vector) — indexes already used
    % does: recursively combine compatible duties (per `combinations`) into a single pairing and sum costs
    % outputs: pairing — updated pairing vector; cost — updated total cost; dutiesCovered — updated index list


Bad Example (without guidelines):

    %COMBINEDUTIES Recursively combine compatible duties into a pairing
    %   [pairing,cost,dutiesCovered] = COMBINEDUTIES(pairing,cost,curIndex,combinations,...) 
    %   attempts to append compatible duties (from `combinations`) to `pairing`
    %   and accumulates cost and covered-duty indices.
    %
    % Inputs
    %   pairing, duties    - column vectors indicating legs covered
    %   cost               - scalar cost for the `pairing` so far
    %   curIndex           - current duty index to consider
    %   combinations       - dictionary mapping duty -> feasible next duties
    %   costs              - 1xD vector of duty costs
    %   dutiesCovered      - vector of already-covered duty indices
    %
    % Outputs
    %   pairing, cost, dutiesCovered - updated pairing, cost and covered list
    %
    % Example
    %   [p,c,dc] = combineDuties(p,c,1,combinations,duties,costs,[]);


### dutiestoPairings ###
Criteria:
- Take set of flight duties, costs, and all numeric data
- Find duties to combine to create pairings
- Use criteria from external case to identify combinable duties
- Return final pairings from duties with pairing costs


Good Example (with guidelines):

    % inputs: duties (legs x duties), costs (1 x duties), numData (legs x 4)
    % does: converts duty-level schedules into leg-based pairings by combining duties where feasible
    % outputs: finalPairings — matrix (legs x pairings); finalCosts — row vector of pairing costs


Bad Example (without guidelines):

    %DUTIESTOPAIRINGS Convert duty-based solutions into leg-based pairings
    %   [finalPairings,finalCosts] = DUTIESTOPAIRINGS(duties,costs,numData)
    %   converts duties (blocks of legs) into final pairing vectors and costs
    %   adjusted to the numeric `numData` indexing/format.
    %
    % Inputs
    %   duties   - MxD matrix, each column is a duty (legs covered)
    %   costs    - 1xD vector of costs for each duty
    %   numData  - Nx4 numeric flight data used to compute duty spans
    %
    % Outputs
    %   finalPairings - NxK matrix of pairings covering legs
    %   finalCosts    - 1xK vector of costs corresponding to finalPairings
    %
    % Example
    %   [fp,fc] = dutiestoPairings(duties,costs,numData);


### findCombinations ###
Criteria:
- Take in all data, max # overnights, max layover time
- Return dictionary of feasible flight connections


Good Example (with guidelines):

    % inputs: numData, strData, overnights, maxLayover — flight numeric/string data, overnight flags, max layover (minutes)
    % does: finds all feasible downstream connections for each leg using isFeasibleCombo
    % outputs: combinations — dictionary mapping leg index -> vector of feasible destination indices


Bad Example (without guidelines):

    %FINDCOMBINATIONS Build feasible-next-leg mapping for each flight
    %   combinations = FINDCOMBINATIONS(numData,strData,overnights,maxLayover)
    %   returns a dictionary where key i maps to a vector of leg indices
    %   that are feasible immediate connections from leg i.
    %
    % Inputs
    %   numData    - Nx4 numeric matrix: [date, starttime, endtime, duration]
    %   strData    - NxM cell/string array with airport/location info
    %   overnights - allowed overnight gap (days)
    %   maxLayover - maximum same-day layover (minutes)
    %
    % Outputs
    %   combinations - dictionary mapping leg index -> vector of feasible next indices
    %
    % Example
    %   comb = findCombinations(numData,strData,1,240);


### fixTimeZone ###
Criteria:
- Take in all numeric data
- Adjust time zone by 4 hours
- Adjust day if time is now negative
- Return updated numeric data


Good Example (with guidelines):

    % inputs: numData (Nx4) — [date, starttime, endtime, duration] in original timezone
    % does: shifts times by -240 minutes (timezone adjustment) and normalizes day/start/end
    % outputs: newData (Nx4) — timezone-corrected [date, starttime, endtime, duration]


Bad Example (without guidelines):

    %FIXTIMEZONE Adjust numeric flight times for timezone offset
    %   newData = FIXTIMEZONE(numData) subtracts a 240-minute timezone offset
    %   from start/end times and adjusts the travel day when needed.
    %
    % Inputs
    %   numData  - Nx4 numeric matrix: [date, starttime, endtime, duration]
    %
    % Outputs
    %   newData  - Nx4 numeric matrix with adjusted [date, starttime, endtime, duration]
    %
    % Example
    %   nd = fixTimeZone(numData);


### isFeasibleCombo ###
Criteria:
- Take numeric and string data for both flights, max # overnights, and max layover
- Identify if possible for crew to work both flights using provided external constraints
- Return true if none of failing criteria met


Good Example (with guidelines):

    % inputs: nData1,nData2 (1x4) and sData1,sData2 (1x2) — numeric/string flight data for two legs; overnights, maxLayover (scalars)
    % does: returns whether leg2 is a feasible connection after leg1 (checks airport, layover, duty limits, overnight rules)
    % outputs: possible (logical) — true if the two legs can be legally paired


Bad Example (without guidelines):

    %ISFEASIBLECOMBO Check whether two flight legs can form a feasible connection
    %   possible = ISFEASIBLECOMBO(nData1,sData1,nData2,sData2,overnights,maxLayover)
    %   returns true if leg2 can follow leg1 subject to layover and overnight rules.
    %
    % Inputs
    %   nData1, nData2   - 1x4 numeric rows: [date, starttime, endtime, duration]
    %   sData1, sData2   - string/cell with airport names for the legs
    %   overnights       - integer allowed overnight gap (in days)
    %   maxLayover       - max allowed same-day layover in minutes
    %
    % Outputs
    %   possible - logical true if connection is allowed
    %
    % Example
    %   ok = isFeasibleCombo(n1,s1,n2,s2,1,240);


### makePairings ###
Criteria:
- Take in all numeric and string data, feasible combinations, max flight usage, max branch width, and if deadheads are allowed
- Create pairings starting with each possible starting flight
- Return set of all possible pairings and costs for each pairing


Good Example (with guidelines):

    % inputs: numData, strData, combinations, MFU, MBW, deadheads — dataset, connection map, and numeric limits/flags
    % does: enumerates feasible pairings by seeding valid starts and expanding branches (calls buildBranches)
    % outputs: pairings — matrix (legs x combos) of coverage; costs — row vector of corresponding pairing costs


Bad Example (without guidelines):

    %MAKEPAIRINGS Generate candidate pairings and their costs from flight data
    %   [pairings,costs] = MAKEPAIRINGS(numData,strData,combinations,MFU,MBW,deadheads)
    %   builds pairing candidates (columns indicate legs included) and
    %   associated costs using connectivity constraints and parameters.
    %
    % Inputs
    %   numData      - Nx4 numeric matrix: [date, starttime, endtime, duration]
    %   strData      - NxM cell/string array with airport codes/strings
    %   combinations - dictionary mapping leg index -> feasible next-leg indices
    %   MFU, MBW     - numeric parameters controlling pairing generation
    %   deadheads    - integer, allowed deadhead count
    %
    % Outputs
    %   pairings - MxP matrix where each column is a pairing (legs covered)
    %   costs    - 1xP vector of costs for each pairing
    %
    % Example
    %   [p,c] = makePairings(numData,strData,combinations,inf,inf,0);


### readData ###
Criteria:
- Take in filename
- Read in data and convert dates, times to minutes, and string data for flight data
- Return separated string and numeric data


Good Example (with guidelines):

    % inputs: fileName (string) — Excel file (e.g. 'flightLegs.xlsx') containing flight-leg rows
    % does: reads Excel and converts date/time strings to numeric arrays and extracts location strings
    % outputs: numData (Nx4) — [date, starttime, endtime, duration]; strData (Nx2) — [start, end] (locations)


Bad Example (without guidelines):

    %READDATA  Load flight spreadsheet into numeric and string matrices.
    % Inputs: fileName
    % Outputs: numData, strData


### reorderPairings ###
Criteria:
- Take in matrix of pairings, costs, and number to break up into
- Return new sets of pairings and costs split into provided number of sections, with list of section breakpoints

Good Example (with guidelines):

    % inputs: pairings (legs x combos), costs (1 x combos), newNumMatrices (scalar) — desired grouping width
    % does: reorders existing pairing columns into `newNumMatrices`-wide blocks and computes breakpoints
    % outputs: newPairings, newCosts — reordered matrices; breakPoints — start indices of each new block


Bad Example (without guidelines):

    %REORDERPAIRINGS Redistribute pairings into new matrix-grouping order
    %   [newPairings,newCosts,breakPoints] = REORDERPAIRINGS(pairings,costs,newNumMatrices)
    %   reorganizes columns of `pairings`/`costs` so they form `newNumMatrices`
    %   groups and returns break-point indices for each new group.
    %
    % Inputs
    %   pairings       - MxP logical/numeric matrix (legs x pairings)
    %   costs          - 1xP vector of pairing costs
    %   newNumMatrices - scalar number of pairings-per-group for reordering
    %
    % Outputs
    %   newPairings  - MxP reordered pairings
    %   newCosts     - 1xP reordered costs
    %   breakPoints  - 1x(newNumMatrices+1) indices marking group boundaries
    %
    % Example
    %   [np,nc,bp] = reorderPairings(pairings,costs,8);


### timeStringtoMinutes ###
Criteria:
- Take in string of time in 24 hour format
- Convert to number of minutes, with 00:00 as 0 minutes

Good Example (with guidelines):

    % inputs: timeString — time string(s) in "HH:mm" format (string or cellstr)
    % does: parses HH:mm values and converts them to numeric minutes
    % outputs: minutes — column vector of minutes for each input time


Bad Example (without guidelines):

    %TIMESTRINGTOMINUTES Convert HH:mm time string(s) to minutes
    %   minutes = TIMESTRINGTOMINUTES(timeString) converts a single time
    %   string or a column of time strings in format 'HH:mm' to numeric
    %   minutes since midnight.
    %
    % Inputs
    %   timeString - char array or string array (Nx1) with format 'HH:mm'
    %
    % Outputs
    %   minutes    - numeric scalar or Nx1 vector of minutes
    %
    % Example
    %   m = timeStringtoMinutes("09:30");


