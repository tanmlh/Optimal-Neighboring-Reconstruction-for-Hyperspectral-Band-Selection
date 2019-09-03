function [suc_rec_ratio, max_rec_err] = cal_rec_err(L, band_set, thre, noise_band_id)
    %% initialization
    [~, ~, d] = size(L);
    m = size(band_set, 2);
    error = zeros(d, 1);
    suc_rec_ratio = 0; 
    max_rec_err = 0;
    
    %% calculate the reconstruction error of each band
    error(1 : band_set(1) - 1) = L(d+1, band_set(1), 1 : band_set(1) - 1);
    l = band_set(1);
    for i = 2 : m
        r = band_set(i);
        error(l+1:r-1) = L(l, r, l+1:r-1);
        l = r;
    end
    error(band_set(m)+1 : d) = L(band_set(m), d+2, band_set(m)+1 : d);
    
    %% find the number of bands that are clean and successfully reconstructed
    for i = 1 : d
        max_rec_err = max(max_rec_err, error(i));
        if error(i) < thre && noise_band_id(i) == 0
            suc_rec_ratio = suc_rec_ratio + 1;
        end
    end
    
    %% get the success ratio
    suc_rec_ratio = suc_rec_ratio / sum(noise_band_id == 0);
    
end