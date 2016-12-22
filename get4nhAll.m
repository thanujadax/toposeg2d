function neighbors = get4nhAll(pixID,sizeR,sizeC)

neighbors = [];

[r0 c0] = ind2sub([sizeR sizeC],pixID);

i = 0;
% N1
r = r0 - 1;
c = c0;
if(r>0)
    i = i + 1;
    neighbors = [neighbors; sub2ind([sizeR sizeC],r,c)];
end

% N2
r = r0 + 1;
c = c0;
if(r<=sizeR)
    i = i + 1;
    neighbors = [neighbors; sub2ind([sizeR sizeC],r,c)];
end

% N3
r = r0;
c = c0 - 1;
if(c>0)
    i = i + 1;
    neighbors = [neighbors; sub2ind([sizeR sizeC],r,c)];
end

% N4
r = r0;
c = c0 + 1;
if(c<=sizeC)
    i = i + 1;
    neighbors = [neighbors; sub2ind([sizeR sizeC],r,c)];
end