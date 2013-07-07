%% macro
INPUT_DIR = '../input/';
BASE_NAME = 'frames';
FORMAT = 'jpg';
START_FRAME = 1135;
PATCH_SIDE = 12;

fold_info = dir([INPUT_DIR,'*']);
for i = 1:length(fold_info)-2
    frame_dir = [INPUT_DIR,BASE_NAME,num2str(i),'/'];
    frame_set = dir([frame_dir,'*','.',FORMAT]);
    frame_indices = [];
    if length(frame_set) ~= 0
        for j = 1:length(frame_set)
            frame_name = regexp(frame_set(j).name, '\.', 'split');
            frame_indices = [frame_indices, str2num(frame_name{1})];
        end 
        separateCaption(frame_dir, min(frame_indices), length(frame_set), FORMAT, i)
    end
end



