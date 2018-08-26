%Gas Diffusion Function:
% This function embodies the behaviour described by Section 2.1
% "Gas Diffusion in the Networks" in Husbands et al.(1998).
% Specifically equations 2,3,4 are implemented here.
% This function calculates the concentration of the gas from one node using
% the distance and decay calculations etc.
%
% Parameters:
%  isEmitting   - Binary value describing whether the node is emitting.
%  emissionStart    - The time step that the node last started emitting.
%  emissionStop     - The time step that the node last started emitting.
%  s            - The decay rate value for the node.
%  t            - The current time step.
%  globalC      - Constant used in gas diffusion.
%  distance     - The distance to the node.
%  gasRadius    - The radius of the node's gas.
%
% Author: Will Saunders
% Date: 12.12.11
%
% ------------------------------------------------------------------------
% These tools are developed from the GasNet model described in:
% P Husbands, T Smith, N Jakobi, and M O'Shea. (1998)
% Better Living Through Chemistry: Evolving GasNets for Robot Control.
% Connection Science, 10(3-4):185-210.
function concentration = gasDiffusion(isEmitting, emissionStart,...
                    emissionStop, s, t, globalC, distance, gasRadius)

if(distance>gasRadius)
    concentration = 0;
    return;
end

if(isEmitting) %Node is emitting.
    buildUp = H((t-emissionStart)/s);
elseif(~isEmitting) %Node is not emitting.
    buildUp = H(...
        H((emissionStop-emissionStart)/s)-H((t-emissionStop)/s));
end

concentration = (globalC * exp((-2*distance)/gasRadius) * buildUp);
end


%Local Function: Eq 4, Husbands et al. (1998)
function out1 = H(in) 
if(in<=0)
    out1 = 0;
elseif(in>1)
    out1 = 1;
else
    out1 = in;
end
end