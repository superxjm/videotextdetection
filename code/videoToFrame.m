NUM_OF_VIDEO = 5;

for i = 11:11%1:NUM_OF_VIDEO
    
vidObj = mmreader(['./video/',num2str(i),'.avi']); 
numFrames = vidObj.NumberOfFrames;
mkdir(['./original_input/frames',num2str(i)]);
for j = 1:numFrames
    frame = read(vidObj, j);
    imwrite(frame, ['./original_input/frames',num2str(i),'/',num2str(j),'.jpg'], 'jpg');
end

end