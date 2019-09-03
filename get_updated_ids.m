function [r_id] = get_updated_ids(L_ele, r_thre)
    l = 1; r = size(L_ele, 1);
    while r >= l
        m = floor((l+r)/2);
        if(L_ele(m) < r_thre)
            l = m+1;
        else
            r = m-1;
        end
    end
    r_id = r;
end