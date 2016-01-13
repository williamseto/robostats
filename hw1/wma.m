function [ regrets, losses, weights ] = wma( N, T , eta, nature_type)

%N: number of experts
%T: number of trials
%eta
%nature_type: 1: stochastic, 2: deterministic, 3: adversarial

%import all necessary functions
funcs = common_functions;

weights = ones(1, N);

%store all expert predictions and y's over time to calculate regret
all_h = zeros(N, T);
y = zeros(1, T);

curr_loss = 0;

regrets = zeros(1, T);
losses = zeros(1, T);

for t = 1:T
    
features = funcs.get_features(t, y);
x = funcs.get_advice(N, features);

prediction = sign(sum(weights .* x));

switch nature_type
    case 1
        result = funcs.nature.stochastic();
    case 2
        result = funcs.nature.deterministic(N, features);
    case 3
        result = funcs.nature.adversarial(0, weights, x);
end

error = (x ~= (ones(1, N).* result));
weights = weights .* (ones(1,N) - (error .* eta));

%calc loss and regret
y(t) = result;
all_h(:,t) = x';

curr_loss = curr_loss + (prediction ~= result);
reg = funcs.calc_regret(curr_loss, y, all_h);

losses(t) = curr_loss;
regrets(t) = reg;


end
end

