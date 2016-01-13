classdef policyGWM < Policy
    %POLICYGWM This policy implementes GWM for the bandit setting.
    
    properties
        nbActions % number of bandit actions
        % Add more member variables as needed
        weights
        t %current time step
        lastAction
    end
    
    methods
        
        function init(self, nbActions)
            % Initialize any member variables
            self.nbActions = nbActions;
            
            % Initialize other variables as needed
            self.weights = ones(1, nbActions);
            self.t = 1;
            self.lastAction = 0;

        end
        
        function action = decision(self)
            % Choose an action according to multinomial distribution
            dist = self.weights ./ sum(self.weights);
            action = randsrc(1, 1, [ 1:1:self.nbActions ; dist]);
            self.lastAction = action;

        end
        
        function getReward(self, reward)
            % or get loss
            % Update the weights
            
            % First we create the loss vector for GWM
            lossScalar = 1 - reward; % This is loss of the chosen action
            lossVector = zeros(1,self.nbActions);
            lossVector(self.lastAction) = lossScalar;
            
            % Do more stuff here using loss Vector
            % actually update weights
            
            eta_t = (log(self.nbActions) / self.t)^0.5;
            self.weights = self.weights .* exp(-eta_t * lossVector);
            self.t = self.t + 1;
        end        
    end
end

