function generateResult(val, start_frame, VISUAL_RESULT_DIR, format, RESULT_DIR, N)

    dec_val = (val < 0);
    pla_val = (val == 0);
    dec_i = strfind(dec_val, [0,1]);
    min_dec_i = min(dec_i);
    min_pla_i = min(strfind(pla_val, 1));
    
    i = min_dec_i+start_frame;
    im = imread([VISUAL_RESULT_DIR,num2str(i),'.',format]);
    RESULT_DIR1 = [RESULT_DIR,'1/'];
    mkdir(RESULT_DIR1);
    imwrite(im, [RESULT_DIR1,num2str(N),'.jpg'], 'jpg');
    
    if min_dec_i < min_pla_i
        i = min(dec_i(dec_i>min_pla_i))+start_frame;
        if isempty(i)
            i = min_pla_i+start_frame;
        end
    else
        i = min_dec_i+start_frame;
    end
    im = imread([VISUAL_RESULT_DIR,num2str(i),'.',format]);
    RESULT_DIR2 = [RESULT_DIR,'2/'];
    mkdir(RESULT_DIR2);
    imwrite(im, [RESULT_DIR2,num2str(N),'.jpg'], 'jpg');
    
end

