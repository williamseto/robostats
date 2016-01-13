classdef gameAdversarial<Game
    %GAMEADVERSARIAL This is a concrete class defining a game where rewards
    %   are adversarially chosen.

    methods
        
        function self = gameAdversarial()
            self.nbActions = 2;
            self.totalRounds = 1000;
            self.tabR = toeplitz(mod(0:1, 2), mod(0:999,2));
            % [0 1 0 1 0 ...;
            %  1 0 1 0 1 ...]
            self.N = 0;
        end
        
    end    
end

