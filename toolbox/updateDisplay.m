%Update Display Funtion:
% This funtion produces a display of the current network configuration.
% It will display the concentration of the specified gas across the space.
% 
% This function also calls the gasDiffusion function, see documentation 
% for details.
%
% Author: Will Saunders 
% Date: 30.12.11
%
% Parameters:
%  phenotype    - Cell Array GasNet phenotype.
%  emissions    - Matrix of emission state (number of nodes x 3), 
%                 describing whether a node is emitting (n,1) [0|1], the 
%                 time step the node last started emitting (n,2) and the 
%                 time step the node last stopped emitting (n,3).
%  displayDistances
%               - 2D cell array each holding an array of distances
%                 to each node.
%  gas          - Gas to display (1 or 2).
%  t            - The current time step.
%  globalC      - Constant used in gas diffusion.
%  diffusionFunction (OPTIONAL)
%               - Function handle to user specified diffusion function.
%                 (fcn must operate within default fcn's specification)
% ------------------------------------------------------------------------
% These tools are developed from the GasNet model described in:
% P Husbands, T Smith, N Jakobi, and M O'Shea. (1998)
% Better Living Through Chemistry: Evolving GasNets for Robot Control. 
% Connection Science, 10(3-4):185-210.
function [] = updateDisplay(phenotype,emissions,displayDistances,...
                                          gas,t,globalC,diffusionFunction)
if(nargin < 7)
    diffusionFunction = @gasDiffusion;
end
[~, noOfGenes] = size(phenotype);

gas1Spread = zeros(100,100);
gas2Spread = zeros(100,100);
for a=1:100
    for b=1:100
        gas1 = 0;
        gas2 = 0;
        for c=1:noOfGenes
            if(phenotype{c}(10) == 0), continue; end
            
            tempConcentration = diffusionFunction(emissions(c,1),...
                emissions(c,2),emissions(c,3),phenotype{c}(12),t,...
                globalC,displayDistances{a,b}(c),phenotype{c}(13));
            
            if(phenotype{c}(11)==0)
                gas1 = gas1 + tempConcentration;
            else
                gas2 = gas2 + tempConcentration;
            end
        end
        gas1Spread(a,b) = gas1;
        gas2Spread(a,b) = gas2;
    end
end

if(gas == 1)
    % Flip data as imagesc automatically flips y axis
    imagesc(flipud(gas1Spread));
    colormap default;
    caxis([0 1]);
    axis tight;
    axis xy;
    colorbar;
    set(gca,'YDir','normal');
    
elseif(gas == 2)
    % Flip data as imagesc automatically flips y axis
    imagesc(flipud(gas2Spread));
    colormap default;
    caxis([0 1]);
    axis tight;
    axis xy;
    colorbar;
    set(gca,'YDir','normal');
end
end
    