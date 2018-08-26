%LiveGasNet Funtion: 
% This function produces the phenotype of the GasNet network and runs it.
% It initialises the display to monitor gas concentrations and produces 
% terminal output of the networks output nodes.
%
% Author: Will Saunders 
% Date: 12.12.11
%
% Parameters:
%  genotype     - Cell Array GasNet genotype to run.
%  globalC      - Constant used in gas diffusion.
%  globalK      - Constant used in gas modulation.
%  nomValues    - Array of >0s & 0s which matches the gene length
%                 (where nomValues(i) > 0, genotype{-}(i) is nominal val
%                  and nomValues(i) == the number of options).
%  elecThresh   - The gas emission threshold for electrical activity.
%  gasThresh    - The gas emission threshold for gas concentration.
%  display      - Binary value determining whether figure is displayed.
%  fitFunction  - Function handle for fitness function.
%                 Specification: function [fitness] 
%                                       = fitFunction(output,t,outputNodes)
%  fitLevel     - Stopping value for fitness.
%  getInput     - Function handle for retrieving input.
%                 Specification: function [input] 
%                                    = getInput(nodeNum,t,output,genotype)
%  emissState   - State of emissions at point prior to run.
%  outputState  - State of outputs at point prior to run.
%  currentT     - The current timestep.
%  noOfSteps    - The number of time steps to simulate.
%  outputNodes  - The nodes which are specifically output nodes. 
%                 Primarily used in fit func to evaluate a specific node.
%  displayHandles (OPTIONAL)
%               - Handles for display figures.
%  modulationFunction (OPTIONAL)
%               - Function handle to user specified modulation function.
%                 (fcn must operate within default fcn's specification)
%  diffusionFunction (OPTIONAL)
%               - Function handle to user specified diffusion function.
%                 (fcn must operate within default fcn's specification)
% ------------------------------------------------------------------------
% These tools are developed from the GasNet model described in:
% P Husbands, T Smith, N Jakobi, and M O'Shea. (1998)
% Better Living Through Chemistry: Evolving GasNets for Robot Control. 
% Connection Science, 10(3-4):185-210.

function [output, emissions, fitness] = liveGasNet(genotype,elecThresh,...
                            gasThresh,globalC,globalK,nomValues,display,...
                            fitFunction,fitLevel,getInput,emissState,...
                            outputState,currentT,noOfSteps,outputNodes,...
                            displayHandles,modulationFunction,...
                            diffusionFunction)
if(nargin<18)
    diffusionFunction = @gasDiffusion;
end
if(nargin<17)
    modulationFunction = @gasModulation;
end
if(nargin<16 || any(ishandle(displayHandles)==0))
    displayHandles(1) = figure();
    displayHandles(2) = figure();
end
if(nargin<15)
    error('Insufficient parameters.')
end

[~, noOfGenes] = size(genotype);

%Calculate phenotype values from genotype.
phenotype = cell(1,noOfGenes);
for geneIndex=1:noOfGenes
    [~,valueLength] = size(genotype{geneIndex});
    temp = zeros(1,valueLength);
    for valueIndex=1:valueLength
        if(valueIndex == 4 || valueIndex == 5 || valueIndex == 7 ||...
                                                        valueIndex == 8)
            %Phenotype value is an angle in degrees.
            temp(valueIndex) = (genotype{geneIndex}(valueIndex)/99)*360;
        elseif(valueIndex == 12)
            %Phenotype value is gas decay (limited to 1:11).
            temp(valueIndex) = ((genotype{geneIndex}(valueIndex)/99)*10)+1;
        elseif(valueIndex == 15)
            %Phenotype value is bias (limited to -1:1).
            temp(valueIndex) = ...
                            (((genotype{geneIndex}(valueIndex)/99)*2)-1);
        elseif(nomValues(valueIndex) > 0)
            %Phenotype value is a nominal value.
            temp(valueIndex) = mod(genotype{geneIndex}(valueIndex), ...
                                                   nomValues(valueIndex));
        else
            %Phenotype value is continuous.
            temp(valueIndex) = genotype{geneIndex}(valueIndex)/99;
        end
    end
    phenotype{geneIndex} = temp;
end       

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Step 1 - Establish distances %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Distances are stored in node x node matrix.
distances = zeros(noOfGenes,noOfGenes);
for i=1:noOfGenes
    for j=1:noOfGenes
        if(j==i); continue; end;
        x1 = phenotype{i}(1);
        y1 = phenotype{i}(2);
        x2 = phenotype{j}(1);
        y2 = phenotype{j}(2);
        distances(i,j) = sqrt(((x2-x1)^2)+(((y2-y1)^2)));
    end
end

displayDistances = cell(100,100);
realValuePoints = (0:99);
realValuePoints = realValuePoints/99; %Establishing phenotypical points.
for idx=1:100
    for idy=1:100
        temp = zeros(1,noOfGenes);
        for idg=1:noOfGenes
            x1 = realValuePoints(idx);
            y1 = realValuePoints(idy);
            x2 = phenotype{idg}(1);
            y2 = phenotype{idg}(2);
            temp(idg) = sqrt(((x2-x1)^2)+(((y2-y1)^2)));
        end
        displayDistances{idx,idy} = temp;
    end
end
%Rotate matrix to return to cartesian space.
displayDistances = rot90(displayDistances);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Step 2 - Establish network connectivity. ("Arcs" Method) %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
connections = cell(1,noOfGenes);
connectionIndexes = ones(1,noOfGenes);
for k=1:noOfGenes
    %Pull pos segment details from  gene.
    posRadius = phenotype{k}(3);
    posExtent = phenotype{k}(4);
    posOrientation = phenotype{k}(5);
    
    %Pull neg segment details from  gene.
    negRadius = phenotype{k}(6);
    negExtent = phenotype{k}(7);
    negOrientation = phenotype{k}(8);
    
    %Make recurrent connections.
    if(phenotype{k}(9) == 0)
        continue;
    elseif (phenotype{k}(9) == 1)
        connections{k}{connectionIndexes(k)} = [k,1];
        connectionIndexes(k) = connectionIndexes(k) + 1;
        continue;
    elseif (phenotype{k}(9) == 2)
        connections{k}{connectionIndexes(k)} = [k,-1];
        connectionIndexes(k) = connectionIndexes(k) + 1;
        continue;
    end
    
    for l=1:noOfGenes
        % x,y positions need to be shifted to a relative origin.
        % take source coordinates away from target coordinates.
        x = phenotype{l}(1) - phenotype{k}(1);
        y = phenotype{l}(2) - phenotype{k}(2);
        [radians, rho] = cart2pol(x,y);
        theta = radians * (180/pi); % conversion to degrees.
        if(theta<0)
            %Making sure range is from 0:2pi not -pi:pi
            theta = (180 + theta) + 180;
        end
         
        if((posOrientation+posExtent)<=360)
            if(rho<=posRadius && (theta>=posOrientation &&...
                    theta<=(posExtent+posOrientation)))
                connections{k}{connectionIndexes(k)} = [l,1];
                connectionIndexes(k) = connectionIndexes(k) + 1;
            end
        else
            if(rho<=posRadius && ((theta>=posOrientation && theta<=360)...
               || (theta<=((posOrientation+posExtent)-360) && theta>=0)))
                connections{k}{connectionIndexes(k)} = [l,1];
                connectionIndexes(k) = connectionIndexes(k) + 1;
            end
        end
        
        if((negOrientation+negExtent)<=360)
            if(rho<=negRadius && (theta>=negOrientation &&...
                    theta<=(negExtent+negOrientation)))
                connections{k}{connectionIndexes(k)} = [l,-1];
                connectionIndexes(k) = connectionIndexes(k) + 1;
            end
        else
            if(rho<=negRadius && ((theta>=negOrientation && theta<=360)...
               || (theta<=((negOrientation+negExtent)-360) && theta>=0)))
                connections{k}{connectionIndexes(k)} = [l,-1];
                connectionIndexes(k) = connectionIndexes(k) + 1;
            end
        end
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Step 3 - Simulate the GasNet. %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%The emissions matrix:
% Stores the state of gas of emissions for each node in the network: 
% (n,1) = whether the node is emmiting, (n,2) = the time step at which 
% emission was last turned on, (n,3) = the time step at which emission 
% was last turned off.
emissions = emissState;
% tempEmissions is used to store the changes to the state of emissions for
% the next timestep, where it is batch-updated.

%The outputs cell array.
% Stores the output for each cell at each time step.
% Dynamically creates new indexes at runtime.
output = outputState;

%The fitness cell array.
% Stores the fitness for each timestep.
fitness = cell(1,noOfSteps+1);
fitness{currentT-1} = 0;
fitness{currentT} = 0;

t = currentT;
while(t < (currentT+noOfSteps) && fitness{t-1} < fitLevel)
    tempEmissions = emissions;
    for a=1:noOfGenes
        %Step 3a - Sum all inputs.
        % - Go through 'connections' and pull previous outputs.
        input = 0;
        [~,n]=size(connections{1,a});
        if(n > 0)
            for cnctIndex=1:n
                input = input + ...
                    (output{t-1}(connections{a}{cnctIndex}(1)) * ...
                    connections{a}{cnctIndex}(2));
            end
        end
        
        %- For input nodes:
        if(phenotype{a}(16) == 1)
           nodeInput = getInput(a,t-1,output,genotype);
           input = input + nodeInput;
        end
        
        %Step 3b - Calculate modulation factor.
        [transferParameter,gas1,gas2] = modulationFunction(phenotype,...
                           emissions,distances(a,:),t,globalC,globalK,a,...
                           diffusionFunction);
        
        %Step 3c - Apply tanh calculation.
        nodeOutput = tanh(transferParameter*input+phenotype{a}(15));
        output{t}(a) = nodeOutput;
        
        %Step 3d - Check emission rules for gas concentration.
        if(phenotype{a}(10)==2)
            if(gas1>gasThresh)
                %Node can now emit.
                if(emissions(a,1)==0)
                    %Wasn't emitting previously so now should be updated.
                    tempEmissions(a,1) = 1; tempEmissions(a,2) = t;
                end
            else
                %Node cannot now emit.
                if(emissions(a,1)==1)
                    %Previously emitting so now should be updated.
                    tempEmissions(a,1) = 0; tempEmissions(a,3) = t;
                end
            end
        elseif(phenotype{a}(10)==3)
            if(gas2>gasThresh)
                %Node can now emit.
                if(emissions(a,1)==0)
                    %Wasn't emitting previously so now should be updated.
                    tempEmissions(a,1) = 1; tempEmissions(a,2) = t;
                end
            else
                %Node cannot now emit.
                if(emissions(a,1)==1)
                    %Previously emitting.
                    tempEmissions(a,1) = 0; tempEmissions(a,3) = t;
                end
            end
        end
        
        %Step 3e - Check emission rules for elec activity.
        if(phenotype{a}(10)==1)
            if(nodeOutput>elecThresh)
                %Node can now emit.
                if(emissions(a,1)==0)
                    %Wasn't emitting previously so now should be updated.
                    tempEmissions(a,1) = 1; tempEmissions(a,2) = t;
                end
            else
                %Node cannot now emit.
                if(emissions(a,1)==1)
                    %Was previously emitting so now should be updated.
                    tempEmissions(a,1) = 0; tempEmissions(a,3) = t;
                end
            end
        end
        
    end
    %Step 3f - Batch update emissions.
    emissions = tempEmissions;
    
    %Step 3g - Evaluate fitness based on network outputs.
    fitness{t} = fitFunction(output,t,outputNodes);
    
    %Step 3h - Update display.
    if(display)
        axes(displayHandles(1));
        updateDisplay(phenotype,emissions,displayDistances,1,t,...
                                                globalC,diffusionFunction);
        axes(displayHandles(2));
        updateDisplay(phenotype,emissions,displayDistances,2,t,...
                                                globalC,diffusionFunction);
    end
    
    %Step 3i - Increment t.
    t = t+1;
end
end