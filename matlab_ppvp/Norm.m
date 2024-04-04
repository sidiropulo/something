function NormVector = Norm(x,y,z)
    actual_count_x = numel(x);
    actual_count_y = numel(y);
    actual_count_z = numel(z);
    
    norm_count = max([actual_count_x actual_count_y actual_count_z]);

    if (actual_count_x ~= norm_count)
        x((actual_count_x+1):norm_count) = 0;
    end
    
    if (actual_count_y ~= norm_count)
        y((actual_count_y+1):norm_count) = 0;
    end
    
    if (actual_count_z ~= norm_count)
        z((actual_count_z+1):norm_count) = 0;
    end
    
    NormVector = zeros(1,norm_count);
    for norm_index=1:norm_count
        NormVector(norm_index) = norm([x(norm_index) ...
            y(norm_index) z(norm_index)]);
    end
end

