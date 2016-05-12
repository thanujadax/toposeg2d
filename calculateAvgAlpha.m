function alpha = calculateAvgAlpha(y,x)

% y,x are angle values in degrees [-180,180]
% have to handle the boundary condition when alpha_i ~ 180 or 0

alphas = atan2d(y,x);

negAlphaInds = (alphas < 0);
posAlphaInds = ~negAlphaInds;
numNegAlphas = sum(negAlphaInds);
numPosAlphas = numel(y) - numNegAlphas;

negAlphas = alphas(negAlphaInds);

if(numNegAlphas>0 && numPosAlphas>0)
    alphasP = median(alphas(posAlphaInds));
    alphasN = median(alphas(negAlphaInds));
    
    a1 = alphasP - alphasN;
    a2 = alphasP + alphasN;
    
    if((a1 - a2)>180)
        negAlphas = negAlphas + 360;
        alphas(negAlphaInds) = negAlphas;
    end
end
alpha = median(alphas);

if(alpha<0)
    alpha = alpha + 360;
end