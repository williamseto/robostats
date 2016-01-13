function [ ratio ] = evalLists( lists, results )
%takes predicted lists & results, and gives success ratio
%lists and results should be num_env x num_traj_per_env
num_env = size(results, 1);

num_success = 0;
for i=1:num_env
    row = results(i, :);
    if sum(row(lists(i, :)) == 1) > 0
        num_success = num_success + 1;
    end
end
    
%fprintf('Ratio of success:%f\n',num_success / num_env);

ratio = num_success / num_env;

end

