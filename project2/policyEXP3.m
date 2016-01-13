classdef policyEXP3 < Policy
    %POLICYEXP3 This is a concrete class implementing EXP3.
    
    properties
        % Define member variables
        nbActions
        weights
        t
        lastAction
        dist %save probabilities since we need it for scaled loss
    end
    
    methods

        function init(self, nbActions)
            % Initialize member variables
            self.nbActions = nbActions;
            self.weights = ones(1, nbActions);
            self.t = 1;
            self.lastAction = 0;  
            self.dist = ones(1, nbActions);
        end
        
        function action = decision(self)
            % Choose an action
            self.dist = self.weights ./ sum(self.weights);

            action = randsrc(1, 1, [ 1:1:self.nbActions ; self.dist]);
            self.lastAction = action;
        end
        
        function getReward(self, reward)
            % reward is the reward of the chosen action
            % update internal model

            lossScalar = (1 - reward) / self.dist(self.lastAction); % scaled loss
            lossVector = zeros(1,self.nbActions);
            lossVector(self.lastAction) = lossScalar;
            
            eta_t = (log(self.nbActions) / (self.t * self.nbActions))^0.5;
            self.weights = self.weights .* exp(-eta_t * lossVector);
            self.t = self.t + 1;
        end        
    end
end