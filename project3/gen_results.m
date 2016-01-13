%% 2.3

M = dlmread('oakland_part3_am_rf.node_features', ' ', 4, 0);

combs = combnk([1004, 1100, 1103, 1200, 1400],2);

for i=1:10
    onlineSVM(M, combs(i,1), combs(i,2));
end