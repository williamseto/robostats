function funs = common_functions
    funs.nature.stochastic = @stochastic;
    funs.nature.deterministic = @deterministic;
    funs.nature.adversarial = @adversarial;
    funs.get_features = @get_features;
    funs.get_advice = @get_advice;
    funs.calc_regret = @calc_regret;
end

function [ regret ] = calc_regret(learner_loss, y, h)

%expand y to size of h. 1xT -> NxT, so we can compare all experts at once
expanded_y = repmat(y, size(h, 1), 1);

best_exp_loss = min(sum((expanded_y ~= h), 2));

regret = learner_loss - best_exp_loss;

end

function [ features ] = get_features( t , y)

% features
% 1: time step t
% 2: weather {-1, 1}
% 3: previous result y(t-1)
% 4: home/away {-1, 1}
% 5: #of injuries

features = zeros(1, 5);

features(1) = t;
features(2) = randsrc();
if t > 1
    features(3) = y(t-1);
end
features(4) = mod(t+1, 2);
features(5) = randsrc(1, 1, [0 1 2 3; 0.35 0.4 0.15 0.1]);

end

function [ advice ] = get_advice( N, features )


%first part: 3 experts
if N == 3
    advice = [1 -1 0];
    e3 = mod(features(1), 2);
    if e3 == 0
        advice(3) = 1;
    else
        advice(3) = -1;
    end
else

    advice = ones(1, N);
    advice(1) = 1; %always pick win
    advice(2) = -1; %always pick loss
    if mod(features(1),2) == 0
        advice(3) = 1;      %even trial = win, odd trial = loss
    else
        advice(3) = -1;     
    end
    advice(4) = features(2); %choose according to weather
    if features(1) > 1
        advice(5) = features(3) * -1;   %pick opposite of last result
    end
    advice(5) = features(4); %choose according to home/away
    if features(5) > 1
        advice(6) = -1; %loss if more than 1 injury
    else
        advice(6) = 1;
    end
end





end

function [ label ] = stochastic( )

label = randsrc();

end

function [ label ] = deterministic( N, features )

%every 3rd "game" is a win
if N == 3
    label = mod(features(1), 3);
else
    %for part 3.5
    label = sign( (2*features(2) + features(3) + 2*features(4) - features(5)) + 1);
end

end

function [ label ] = adversarial( rand, weights, predictions)

%nature knows our strategy and has access to expert weights/predictions
%rand = 0 or 1
%0 means wma (deterministic), 1 is rwma

if rand == 0
    %opposite of learner's prediction rule
    label = -1 * sign(sum(weights .* predictions));
else
    %sample from same distribution as learner
    %but pick opposite prediction of chose expert
    dist = weights ./ sum(weights);
    chosen_expert = randsrc(1, 1, [ 1:1:length(weights) ; dist]);
    label = -1 * predictions(chosen_expert);
end
        


end

