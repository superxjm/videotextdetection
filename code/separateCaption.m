function separateCaption(frame_dir, start_frame, num_of_frame, format, N)
% the goal of the function is to separate the frame the text cluster 
% and non-text cluster, the text cluster include the caption(graphic text)
% the non-text cluster include the scene text
% N is the index of call the function

%% macro
PATCH_SIDE = 12;
OUTPUT_DIR = ['../output/',num2str(N),'/'];
RESULT_DIR = '../';

GRAY_FRAME_FOLDER = 'grayframes';
TEXT_CLUSTER_FOLDER = 'text_clusters';
NONTEXT_CLUSTER_FOLDER = 'nontext_clusters';
VISUAL_RESULT_FOLDER = 'visual_results';
DIAGRAM_FOLDER = 'diagrams';
RESULT_FOLDER = 'result';

GRAY_FRAME_DIR = [OUTPUT_DIR, GRAY_FRAME_FOLDER, '/'];
TEXT_CLUSTER_DIR = [OUTPUT_DIR, TEXT_CLUSTER_FOLDER, '/'];
NONTEXT_CLUSTER_DIR = [OUTPUT_DIR, NONTEXT_CLUSTER_FOLDER, '/'];
VISUAL_RESULT_DIR = [OUTPUT_DIR, VISUAL_RESULT_FOLDER, '/'];
DIAGRAM_DIR = [OUTPUT_DIR, DIAGRAM_FOLDER, '/'];
RESULT_DIR = [RESULT_DIR, RESULT_FOLDER, '/'];

mkdir(GRAY_FRAME_DIR);
mkdir(TEXT_CLUSTER_DIR);
mkdir(NONTEXT_CLUSTER_DIR);
mkdir(VISUAL_RESULT_DIR);
mkdir(DIAGRAM_DIR);

%% global variables
im1 = imread([frame_dir,num2str(start_frame),'.',format]);
im1 = double(rgb2gray(im1));
text_cluster = zeros(size(im1));
nontext_cluster = zeros(size(im1));
visual_result = zeros(size(im1));
[row,col] = size(im1);
num_of_row = ceil(row/PATCH_SIDE);
num_of_col = ceil(col/PATCH_SIDE);
mask_matrix = ones(num_of_row,num_of_col);
static = struct('fore_cc_nums',[],'back_cc_nums',[]...
        ,'average_fore_cc_nums',[], 'average_back_cc_nums',[]...
        ,'fore_grid_nums',[],'back_grid_nums',[]...
        ,'int_fore_cc_nums',[],'int_back_cc_nums',[]);
% ('sses',[],'distance_of_CXs',[], ...
%     'fore_errs',[],'back_errs',[], ...
%     'fore_grid_nums',[],'back_grid_nums',[], ...
%     'fore_cc_nums',[],'back_cc_nums',[], ...
%     'average_fore_cc_nums',[], 'average_back_cc_nums',[]);

for i = start_frame+1:start_frame+num_of_frame-1
    
%% prepare data
im2 = imread([frame_dir,num2str(i),'.',format]);
imwrite(uint8(rgb2gray(im2)), [GRAY_FRAME_DIR,num2str(i),'.jpg'], 'jpg');
im2 = double(rgb2gray(im2));
[row,col] = size(im1);
clear err_matrix;
err_matrix = zeros(1,length(mask_matrix(:)));

%% calculate the ERROR MATRIX(MSE), FOREGROUND, BACKGROUND
row_inter = PATCH_SIDE;
col_inter = PATCH_SIDE;
n1 = 1;n2 = 1;n3 = 1;
fore_err_matrix = zeros(1,sum(mask_matrix(:)));
back_err_matrix = zeros(1,length(mask_matrix(:))-sum(mask_matrix(:)));
for r = 1:num_of_row
    for c = 1:num_of_col
        sta_row = int32((r-1)*row_inter+1);end_row = int32(sta_row+row_inter-1);
        sta_col = int32((c-1)*col_inter+1);end_col = int32(sta_col+col_inter-1);
        if end_row > row
            end_row = row;
        end
        if end_col > col
            end_col = col;
        end
        err_matrix(n1) = compare(im1(sta_row:end_row,sta_col:end_col),im2(sta_row:end_row,sta_col:end_col));
        n1 = n1+1;
        if mask_matrix(r,c) == 1
            sta_row = int32((r-1)*row_inter+1);end_row = int32(sta_row+row_inter-1);
            sta_col = int32((c-1)*col_inter+1);end_col = int32(sta_col+col_inter-1);
            if end_row > row
                end_row = row;
            end
            if end_col > col
                end_col = col;
            end
            fore_err_matrix(n2) = compare(im1(sta_row:end_row,sta_col:end_col),im2(sta_row:end_row,sta_col:end_col));
            n2 = n2+1;
        else
            sta_row = int32((r-1)*row_inter+1);end_row = int32(sta_row+row_inter-1);
            sta_col = int32((c-1)*col_inter+1);end_col = int32(sta_col+col_inter-1);
            if end_row > row
                end_row = row;
            end
            if end_col > col
                end_col = col;
            end
            back_err_matrix(n3) = compare(im1(sta_row:end_row,sta_col:end_col),im2(sta_row:end_row,sta_col:end_col));
            n3 = n3+1;
        end
    end    
end

if length(fore_err_matrix) == 1
%     static.average_fore_cc_nums = static.fore_cc_nums./static.fore_grid_nums;
%     static.average_back_cc_nums = static.back_cc_nums./static.back_grid_nums; 
    static.int_fore_cc_nums = static.fore_cc_nums(3:end)-static.fore_cc_nums(2:end-1);
    static.int_back_cc_nums = static.back_cc_nums(3:end)-static.back_cc_nums(2:end-1);
    static.fore_cc_nums = static.fore_cc_nums(2:end);
    static.back_cc_nums = static.back_cc_nums(2:end);
    drawDiagram(static, start_frame, DIAGRAM_DIR, N);
    generateResult(static.int_back_cc_nums, start_frame, VISUAL_RESULT_DIR, format, RESULT_DIR, N);
    return;
end

%% statistics
static.fore_grid_nums = [static.fore_grid_nums, length(fore_err_matrix)];
static.back_grid_nums = [static.back_grid_nums, length(back_err_matrix)];
fore_err_matrix = double(fore_err_matrix);
back_err_matrix = double(back_err_matrix);
% static.fore_errs = [static.fore_errs,mean(fore_err_matrix)];
% static.back_errs = [static.back_errs,mean(back_err_matrix)];

%% k-means
[CX, sse] = vgg_kmeans(fore_err_matrix, 2);
% static.sses = [static.sses,sse];
CX = sort(CX);
% static.distance_of_CXs = [static.distance_of_CXs,sqrt(CX(2)^2-CX(1)^2)];

%% update the mask(foreground and background)
fore_err_matrix = (fore_err_matrix-CX(1)).^2 <= (fore_err_matrix-CX(2)).^2;
n = 1;
for r = 1:num_of_row
    for c = 1:num_of_col
        if mask_matrix(r,c) == 1
            mask_matrix(r,c) = mask_matrix(r,c)*fore_err_matrix(n);
            n = n+1;
        end
    end
end

%% visualization
text_cluster = edge(im1,'sobel');
nontext_cluster = text_cluster;
visual_result = im1;

for r = 1:num_of_row
    for c = 1:num_of_col
        sta_row = (r-1)*row_inter+1;end_row = sta_row+row_inter-1;
        sta_col = (c-1)*col_inter+1;end_col = sta_col+col_inter-1;
        if end_row > row
            end_row = row;
        end
        if end_col > col
            end_col = col;
        end
        if mask_matrix(r,c) == 0
            text_cluster(sta_row:end_row,sta_col:end_col) = 0;
            visual_result(sta_row:end_row,sta_col:end_col) = 0;
        else
            nontext_cluster(sta_row:end_row,sta_col:end_col) = 0;
        end
    end
end

[L,CCnum] = bwlabeln(text_cluster);
% CCnum = sum(text_cluster(:));
static.fore_cc_nums = [static.fore_cc_nums,CCnum];
[L,CCnum] = bwlabeln(nontext_cluster);
% CCnum = sum(nontext_cluster(:));
static.back_cc_nums = [static.back_cc_nums,CCnum];

imwrite(uint8(visual_result), [VISUAL_RESULT_DIR,num2str(i),'.jpg'], 'jpg');
imwrite(text_cluster, [TEXT_CLUSTER_DIR,num2str(i),'.jpg'], 'jpg');
imwrite(nontext_cluster, [NONTEXT_CLUSTER_DIR,num2str(i),'.jpg'], 'jpg');

end

% static.average_fore_cc_nums = static.fore_cc_nums./static.fore_grid_nums;
% static.average_back_cc_nums = static.back_cc_nums./static.back_grid_nums;
static.int_fore_cc_nums = static.fore_cc_nums(3:end)-static.fore_cc_nums(2:end-1);
static.int_back_cc_nums = static.back_cc_nums(3:end)-static.back_cc_nums(2:end-1);
static.fore_cc_nums = static.fore_cc_nums(2:end);
static.back_cc_nums = static.back_cc_nums(2:end);
drawDiagram(static, start_frame, DIAGRAM_DIR, N);
generateResult(static.int_back_cc_nums, start_frame, VISUAL_RESULT_DIR, format, RESULT_DIR, N);

end

