classdef gameGaussian < Game
    %GAMEGAUSSIAN This is a concrete class defining a game where rewards
    %are draw from a gaussian distribution.
    
    methods
        
        function self = gameGaussian(nbActions, totalRounds)
            % Input
            % nbActions - number of actions
            % totalRounds - number of rounds of the game
            self.nbActions = nbActions;
            self.totalRounds = totalRounds;
            self.tabR = zeros(nbActions, totalRounds);
            
            for n = 1:nbActions
                mu = rand();
                sigma = rand();
                for t = 1:totalRounds
                    g = -1;
                    while (g < 0 || g > 1)
                        g = normrnd(mu, sigma);
                    end
                    self.tabR(n, t) = g;
                end
            end
            
            self.N = 0;      
            
        end
        
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        