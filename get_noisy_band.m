%% find a threshold that if the minimal possible reconstruction error of a band 
%% is greater than the error, that band will be regarded as a noisy band
function [noise_band_id] = get_noisy_band(L)
    d = size(L, 3);
    min_L = inf(1, d); % the minimal possible reconstrution error of each band
    
    noise_band_id = zeros(d, 1); % indicator of the noisy bands
    
    %% caluclate min_L and sort it
    for i = 1 : d
        for j = i+2 : d
            k = i+1 : j-1;
            min_L(k) = min(min_L(k), reshape(L(i, j, k), size(k)));
        end
    end
    for i = 2 : d
        j = 1 : i-1;
        min_L(j) = min(min_L(j), reshape(L(d+1, i, j), size(j)));
    end

    for i = 1 : d-1
        j = i+1 : d;
        min_L(j) = min(min_L(j), reshape(L(i, d+2, j), size(j)));
    end
    [sorted_min_L, sorted_id] = sort(min_L);
    
    %% noises occur if the growing rate of sorted_min_L is getting lower
    
    % get a histogram of sorted_min_L
    [hist_L, centers] = hist(sorted_min_L, floor(0.6 * d));
    width = 5; 
    noise_thre = sorted_min_L(end); thre_id = d;
    
    % original growing rate
    ori_rate = mean(hist_L(1 : 2 * width+1), 2);
    for i = width + 1 : size(hist_L, 2) - width
        if ori_rate - mean(hist_L(i - width : i + width), 2) > 0.6 * ori_rate
            noise_thre = centers(i);
            break;
        end
    end
    
    % get the index of the first noisy band
    for i = 1 : d
        if sorted_min_L(i) > noise_thre
            thre_id = i;
            break;
        end
    end
    
    %% indicate the noisy bands
    noise_band_id(sorted_id(thre_id : end)) = 1;

end