classdef policyUCB < Policy
    %POLICYUCB This is a concrete class implementing UCB.

        
    properties
        % Member variables
        nbActions
        sums
        counts
        t
        chosenAction
        upperConfidences
    end
    
    methods
        function init(self, nbActions)
            % Initialize
            self.nbActions = nbActions;
            self.sums = zeros(1, nbActions) + 0.001; %fix 0/0
            self.counts = zeros(1, nbActions);
            self.t = 1;
            self.upperConfidences = []; %will grow dynamically
        end
        
        function action = decision(self)
            % Choose action
            confidences = (self.sums ./ self.counts) + (log(self.t) ./ (2 .* self.counts)).^0.5;
            [~, action] = max(confidences);
            self.chosenAction = action;
            self.upperConfidences = [self.upperConfidences confidences'];
        end
        
        function getReward(self, reward)
            % Update ucb
            self.sums(self.chosenAction) = self.sums(self.chosenAction) + reward;
            self.counts(self.chosenAction) = self.counts(self.chosenAction) + 1;
            self.t = self.t + 1;
        end        
    end

end
