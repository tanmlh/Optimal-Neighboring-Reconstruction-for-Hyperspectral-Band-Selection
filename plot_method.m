function fig = plot_method(Methods, x, classifier_names, classifier_id, method_names, dataset_id, type_accu)
    
    M_cnt = size(Methods, 2);
    colors = [linspecer(M_cnt); 0, 0, 0];
    colors_cnt = size(colors, 1);
    line_types = {'-^', '--', '-.p', '-d', '-v', '--x', '-.', '-*', '-^'};
    line_types_cnt = size(line_types, 2);
    x_cnt = size(x, 2);
    y = zeros(1, x_cnt);
    set(gcf,'unit','normalized','position',[0, 0, 0.22,0.35]);
    fig = figure(1);

    ymin = zeros(M_cnt, 1);
    y_max = 0;
    for i = 1 : M_cnt
        for j = 1 : x_cnt
            switch type_accu
                case 1
                    y(1, j) = mean(Methods{1, i}.accu(dataset_id, classifier_id, floor(x(j)/3), :));
            end
        end
        ymin(i) = y(1, 1);
        y_max = max(y_max, max(y));
        plot(x, y(1:x_cnt), line_types{1, mod(i, line_types_cnt)+1}, 'Color', colors(mod(i, colors_cnt)+1, :));
        hold on;
    end
    y_min = mean(ymin(2:M_cnt));
    axis([1 max(x) y_min y_max + 0.02 * (y_max-y_min)]);
    axis normal;
    xlabel('Number of Bands');
    ylabel(['Overall Accuracy by ', classifier_names{classifier_id}]);
    grid on;
    h = legend(method_names, 'Location', 'southeast');
    
end