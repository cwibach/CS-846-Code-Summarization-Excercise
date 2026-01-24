function [bestPairings, bestCosts, cost, results, objVals, times] = fullProgram(fileName)
    % read in initial data
    [numData1, strData1] = readData(fileName);
    num_legs = size(numData1,1);
    numData1 = fixTimeZone(numData1);
    tStart = tic;
    times = zeros(1,16);
    timeIndex = 1;

    % Stage 1
    combinations1 = findCombinations(numData1, strData1, 0, 180);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;

    [pairings1, costs1] = makePairings(numData1, strData1, combinations1, inf, inf, 0);
    [pairings1, costs1] = prunePairings(pairings1, costs1, numData1);
    [pairings1, costs1, breakPoints] = reorderPairings(pairings1, costs1, 8);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;

    [optiBasis1, optiCosts1, newBreakPoints1, ~] = initialModels(pairings1, costs1, breakPoints);
    [fPairings1, fCosts1, result1, ~] = findOptimal(optiBasis1, optiCosts1, newBreakPoints1);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;

    fprintf('Stage 1 Complete\n')
    times(timeIndex) = sum(times(1:3));
    timeIndex = timeIndex + 1;

    % Stage 2
    [numData2, strData2, goodPairings1, goodCosts1, indexes2] = getBadLegs(fPairings1, fCosts1, numData1, strData1);
    combinations2 = findCombinations(numData2, strData2, 1, 240);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    
    [pairings2, costs2] = makePairings(numData2, strData2, combinations2, 50,25, 0);
    [pairings2, costs2] = prunePairings(pairings2, costs2, numData2);
    [pairings2, costs2, breakPoints2] = reorderPairings(pairings2, costs2, 2);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;

    [optiBasis2, optiCosts2, newBreakPoints2, ~] = initialModels(pairings2, costs2, breakPoints2);
    [fPairings2, fCosts2, result2, ~] = findOptimal(optiBasis2, optiCosts2, newBreakPoints2);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    

    fprintf('Stage 2 Complete\n')
    times(timeIndex) = sum(times(5:7));
    timeIndex = timeIndex + 1;

    % Stage 3
    [numData3, strData3, goodPairings2, goodCosts2, indexes3] = getBadLegs(fPairings2, fCosts2, numData2, strData2);
    goodPairings2 = expandPairings(goodPairings2, indexes2, num_legs);

    combinations3 = findCombinations(numData3, strData3, 3, inf);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    
    [pairings3, costs3] = makePairings(numData3, strData3, combinations3, 50, 25, 0);
    [pairings3, costs3] = prunePairings(pairings3, costs3, numData3);
    [pairings3, costs3, breakPoints3] = reorderPairings(pairings3, costs3, 8);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    
    [optiBasis3, optiCosts3, newBreakPoints3, ~] = initialModels(pairings3, costs3, breakPoints3);
    [fPairings3, fCosts3, result3, ~] = findOptimal(optiBasis3, optiCosts3, newBreakPoints3);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    

    fprintf('Stage 3 Complete\n')
    times(timeIndex) = sum(times(9:11));
    timeIndex = timeIndex + 1;

    % Stage 4
    [numData4, strData4, goodPairings3, goodCosts3, indexes4] = getBadLegs(fPairings3, fCosts3, numData3, strData3);
    goodPairings3 = expandPairings(goodPairings3, indexes3, size(numData2,1));
    goodPairings3 = expandPairings(goodPairings3, indexes2, num_legs);

    combinations4 = findCombinations(numData4, strData4, 3, inf);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    
    [pairings4, costs4] = makePairings(numData4, strData4, combinations4, 20, inf, 1);
    [pairings4, costs4] = prunePairings(pairings4, costs4, numData4);
    [pairings4, costs4, breakPoints4] = reorderPairings(pairings4, costs4, 32);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;
    
    [optiBasis4, optiCosts4, newBreakPoints4, ~] = initialModels(pairings4, costs4, breakPoints4);
    [fPairings4, fCosts4, result4, ~] = findOptimal(optiBasis4, optiCosts4, newBreakPoints4);
    times(timeIndex) = toc;
    tic;
    timeIndex = timeIndex + 1;

    fprintf('Stage 4 Complete\n')
    times(timeIndex) = sum(times(13:15));

    goodPairings4 = expandPairings(fPairings4, indexes4, size(numData3,1));
    goodPairings4 = expandPairings(goodPairings4, indexes3, size(numData2,1));
    goodPairings4 = expandPairings(goodPairings4, indexes2, num_legs);

    % Final Results to return
    results = [result1, result2, result3, result4];

    bestCosts = [goodCosts1, goodCosts2, goodCosts3, fCosts4];
    objVals = [result1.objval, result2.objval + sum(goodCosts1), result3.objval + sum(goodCosts1) + sum(goodCosts2), result4.objval + sum(goodCosts1) + sum(goodCosts2) + sum(goodCosts3)];
    bestPairings = [goodPairings1, goodPairings2, goodPairings3, goodPairings4];

    % convert duties to pairings
    [bestPairings, bestCosts] = dutiestoPairings(bestPairings, bestCosts, numData1);

    cost = sum(fCosts4) + sum(goodCosts3) + sum(goodCosts1) + sum(goodCosts2) - 3000*num_legs;
    fprintf('Program Complete \n')
end