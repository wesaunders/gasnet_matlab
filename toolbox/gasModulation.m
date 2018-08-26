%Gas Modulation Function:
% This function embodies the behaviour described by Section 2.2 
% "Modulation by the Gases" in Husbands et al.(1998).
% Specifically equations 5,6,7 are implemented here.
%
% This function also calls the gasDiffusion function by default if an 
% alternative is not specified, see documentation for details.
%
% Parameters:
%  phenotype    - Cell Array GasNet Phenotype
%  emissions    - Matrix of emission state (number of nodes x 3), 
%                 describing whether a node is emitting (n,1) [0|1], the 
%                 time step the node last started emitting (n,2) and the 
%                 time step the node last stopped emitting (n,3).
%  distsFromA   - Array of distances to other nodes from node a.
%  t            - The current time step.
%  globalC      - Constant used in gas diffusion.
%  globalK      - Constant used in gas modulation.
%  a            - The current node.
%  diffusionFunction (OPTIONAL)
%               - Function handle to user specified diffusion function.
%                 (fcn must operate within default fcn's specification)
%
% Author: Will Saunders 
% Date: 12.12.11
%
% ------------------------------------------------------------------------
% These tools are developed from the GasNet model described in:
% P Husbands, T Smith, N Jakobi, and M O'Shea. (1998)
% Better Living Through Chemistry: Evolving GasNets for Robot Control. 
% Connection Science, 10(3-4):185-210.
function [transferParameter,gas1,gas2] = ...
                        gasModulation(phenotype,emissions,distsFromA,...
                        t,globalC,globalK,a,diffusionFunction)
if(nargin<8)
    diffusionFunction = @gasDiffusion;
end

[~, noOfGenes] = size(phenotype);

%Calculate gas concentrations using gasDiffusion.
gas1 = 0;
gas2 = 0;
for b=1:noOfGenes
    if(phenotype{b}(10) == 0), continue; end
    if(b == a), continue; end;
    
    tempConcentration = diffusionFunction(emissions(b,1),emissions(b,2),...
                        emissions(b,3),phenotype{b}(12),t,globalC,...
                        distsFromA(b),phenotype{b}(13));
                    
    if(phenotype{b}(11)==0)
        gas1 = gas1 + tempConcentration;
    else
        gas2 = gas2 + tempConcentration;
    end
end


P = [-4,-2,-1,-0.5,-0.25,-0.125,0,0.125,0.25,0.5,1,2,4];
[~,pSize] = size(P);
temp = (phenotype{a}(14) + ((gas1/globalC*globalK) * ...
                        (pSize-phenotype{a}(14))) - ...
                        ((gas2/globalC*globalK)*phenotype{a}(14)));
integerIndex = f(temp,pSize);
transferParameter = P(integerIndex);
end


 %Local function: (Altered) Eq 7 Husbands et al. (1998)
 function out = f(in,n)
 if(in<=0)
     out = 1;
 elseif(in>=n)
     out = n;
 else
     out = ceil(in);
 end
 end