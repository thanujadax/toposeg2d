function solutionVector = solve3DILPGurobi(ilpObjective,constraintsA,...
    constraintsB,constraintSense)

disp('using Gurobi ILP solver...');
model.A = constraintsA;
model.rhs = constraintsB;
% TODO: check if f contains nan. replace with zero
fnan = isnan(ilpObjective);
if(sum(fnan)>0)
    ilpObjective(fnan==1) = 0;
    disp('Warning! : Nan found in objective function f.')
    disp('Replacing Nan with zero for f(i), where i = ')
    find(fnan==1)
end
model.obj = ilpObjective';
model.sense = constraintSense;
% model.vtype = vtypeArray;
model.vtype = 'B';
% model.lb = lbArray;
% model.ub = ubArray;
model.modelname = '3DreconstructionILP';
% initial guess
% model.start = labelVector;

params.LogFile = 'gurobi_3Dreconstruction.log';
params.Presolve = 0;
params.ResultFile = 'modelfile.mps';
params.InfUnbdInfo = 1;

resultGurobi = gurobi(model,params);
solutionVector = resultGurobi.x;