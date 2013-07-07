function drawDiagram(static, start_frame, DIAGRAM_DIR, N)

fields = fieldnames(static);

for i = 1:length(fields)
    field_name = char(fields(i));
    field_val = static.(field_name);
    plot(start_frame+1:1:start_frame+length(field_val),field_val,'--rs');
    title(strrep(field_name, '_', ' '));
    print(1, '-djpeg', [DIAGRAM_DIR, field_name, '.jpg']);
    save([DIAGRAM_DIR, field_name, '.mat'], 'field_val');
    
end

end

