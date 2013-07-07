function ret = compare(grid1, grid2)

%measure1 MSE
ret = sum(sum((grid1-grid2).^2))/(size(grid1,1)*size(grid1,2));

%measure2 SIFT

end

