load('data.mat')

%% 1.3.2

%we're doing regression, so add bias feature
aug_feat_train = [ones(9300, 1), feat_train];
aug_feat_test = [ones(6360, 1), feat_test];
model = aug_feat_train \ result_train;

score_train = aug_feat_train * model;
score_test = aug_feat_test * model;

list_sizes = 1:1:8;
success_ratios = zeros(2, 8);

for i=1:8
    %first row is training data
    success_ratios(1, i) = naiveListPred(score_train, result_train, 30, 310, i);
    %2nd is test data
    success_ratios(2, i) = naiveListPred(score_test, result_test, 30, 212, i);
end

figure;
plot(list_sizes, success_ratios)
legend('train', 'test', 'location', 'northwest')
title('naive list prediction')

%% 1.3.3

list_sizes = 1:1:8;
success_ratios_new = zeros(2, 8);

%no feature update
learners = conSeqOpt(aug_feat_train, result_train, 8, 0);
for i=1:8
    %first row is training data
    success_ratios_new(1, i) = newListPred(learners, aug_feat_train, result_train, i, 0);
    %2nd is test data
    success_ratios_new(2, i) = newListPred(learners, aug_feat_test, result_test, i, 0);
end

%with feature update
learners = conSeqOpt(aug_feat_train, result_train, 8, 1);
for i=1:8
    %3rd row is training data
    success_ratios_new(3, i) = newListPred(learners, aug_feat_train, result_train, i, 1);
    %4th is test data
    success_ratios_new(4, i) = newListPred(learners, aug_feat_test, result_test, i, 1);
end

figure;
plot(list_sizes, success_ratios_new([1,3], :))
legend('no feat update', 'feat update', 'location', 'northwest')
title('conseqopt (training data)')

figure;
plot(list_sizes, success_ratios_new([2,4], :))
legend('no feat update', 'feat update', 'location', 'northwest')
title('conseqopt (test data)')




    
