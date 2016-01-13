classdef gameLookupTable < Game
    %GAMELOOKUPTABLE This is a concrete class defining a game defined by an
    %external input
    
    methods
        function self = gameLookupTable(tabInput, isLoss)
            % Input
            %   tabInput - input table (actions x rewards or losses)
            %   isLoss - 1 if input table represent loss, 0 otherwise
            self.nbActions = size(tabInput, 1);
            self.totalRounds = size(tabInput, 2);
            if isLoss == 1
                self.tabR = 1 - tabInput;
            else
                self.tabR = tabInput;
            end
            self.N = 0;
        end
        
    end
    
end
