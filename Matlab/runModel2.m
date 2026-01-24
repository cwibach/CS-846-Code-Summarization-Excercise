function result = runModel2(pairings, costs)
    % run a model without adding the identity matrix at the end
    num_legs = size(pairings,1);
    b = ones(num_legs,1);

    model.A = sparse(pairings);
    model.obj = costs;
    model.rhs = b;
    model.sense = '>';
    model.vtype = 'B';
    model.modelsense = 'min';

    params.outputflag = 0;

    result = gurobi(model, params);
end