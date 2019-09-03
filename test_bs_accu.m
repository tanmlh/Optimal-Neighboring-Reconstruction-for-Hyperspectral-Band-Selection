function [accu, result] = test_bs_accu(band_set, Dataset, classifier_type)
    accu = struct('OA', 0, 'MA', 0, 'Kappa', 0);
    train_X = Dataset.train_X;
    train_labels = double(Dataset.train_labels);
    test_X = Dataset.test_X;
    test_labels = double(Dataset.test_labels);
    test_size = size(test_labels, 1);
    [no_rows, no_cols, ~] = size(Dataset.A);
    C = max(test_labels);
    % warning('off');
    bs_train_X = train_X(:, band_set);
    bs_test_X = test_X(:, band_set);
    switch(classifier_type)
        case 'SVM'
            model = svmtrain(train_labels, bs_train_X, Dataset.svm_para); %'-c 300 -t 2 -g 1 -q'
            [predict_labels, corrected_num, ~] = svmpredict(test_labels, bs_test_X, model, '-q');
            result = svmpredict((1:no_rows*no_cols)', Dataset.X(band_set, :)', model, '-q');
            
            accu.OA = corrected_num(1) / 100;
            cmat = confusionmat(test_labels, predict_labels);
            sum_accu = 0;
            for i = 1 : C
                sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
            end
            accu.MA = sum_accu / C;
            Pe = 0;
            for i = 1 : C
                Pe = Pe + cmat(i, :) * cmat(:, i);
            end
            Pe = Pe / (test_size * test_size);
            accu.Kappa = (accu.OA - Pe) / (1 - Pe);
        case 'CART'
            tree = fitctree(bs_train_X, train_labels);
            predict_label = tree.predict(bs_test_X);
            accu.OA = length(find(predict_label == test_labels)) / length(test_labels);
            cmat = confusionmat(test_labels, predict_label);
            sum_accu = 0;
            for i = 1 : C
                sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
            end
            accu.MA = sum_accu / C;
            Pe = 0;
            for i = 1 : C
                Pe = Pe + cmat(i, :) * cmat(:, i);
            end
            Pe = Pe / (test_size * test_size);
            accu.Kappa = (accu.OA - Pe) / (1 - Pe);
            
        case 'KNN'
            predict_label = knnclassify(bs_test_X, bs_train_X, train_labels, 3, 'euclidean');
            accu.OA = 0;
            cmat = confusionmat(test_labels, predict_label);
            for i = 1 : size(predict_label, 1)
                if predict_label(i) == test_labels(i)
                    accu.OA = accu.OA + 1;
                end
            end
            accu.OA = accu.OA / size(predict_label, 1);
            sum_accu = 0;
            for i = 1 : C
                sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
            end
            accu.MA = sum_accu / C;
            
            Pe = 0;
            for i = 1 : C
                Pe = Pe + cmat(i, :) * cmat(:, i);
            end
            Pe = Pe / (test_size*test_size);
            accu.Kappa = (accu.OA - Pe) / (1 - Pe);
        case 'LDA'
            factor = fitcdiscr(bs_train_X, train_labels);
            predict_label = double(factor.predict(bs_test_X));
            cmat = confusionmat(test_labels, predict_label);
            accu.OA = length(find(predict_label == test_labels)) / length(test_labels);
            sum_accu = 0;
            for i = 1 : C
                sum_accu = sum_accu + cmat(i, i) / sum(cmat(i, :), 2);
            end
            accu.MA = sum_accu / C;
            
            Pe = 0;
            for i = 1 : C
                Pe = Pe + cmat(i, :) * cmat(:, i);
            end
            Pe = Pe / (test_size*test_size);
            accu.Kappa = (accu.OA - Pe) / (1 - Pe);
    end
end