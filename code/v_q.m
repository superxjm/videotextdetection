function ci = v_q(ct, x)

if size(x,1) ~= size(ct,1)
    error('ct and featues do not have same dim!');
end

nPoints = size(x,2);
nct = size(ct,2);


ds = Inf * ones(nPoints,nct);
for p = 1:nPoints
    for c = 1:nct
        ds(p,c) = sum((ct(:,c) - x(:,p)).^2);
    end
end

[tmp,ci] = min(ds,[],1);
