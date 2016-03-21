function angleScore = angleSmoothness(alpha1,alpha2,gsigma)

% Calculates the smoothness score for a node of two active edges at
% relative angles to the node alpha1 and alpha2
% angle values are in degrees
beta = abs(alpha1-alpha2);
mean = 180;
a = -1;
angleScore = gauss1d(beta,mean,gsigma,a);

