%Optimise GasNet Funtion:
% This function uses a genetic algorithm to optimise a GasNet based upon
% the fitness function provided as a parameter. popNum must be even, due 
% to distributed toroidal set-up.
%
% Author: Will Saunders
% Date: 03.01.12
%
% Parameters:
% (GA Specific):
%  mu           - Mutation operator (percentage).
%  maxRun       - The maximum number of epochs.
%  planeWidth   - The width of the population plane (10 = 10x10 space)
%  nodeSeed     - Initial number of nodes(genes) for each genotype.
%  noOfValues   - The number of values for each gene.
%  isMutable    - Logical array of gene length, describe which gene values
%                 can be mutated during GA epoch.
%  fixedNodes   - Array describing the which nodes of the starting genotype
%                 are fixed and cannot be removed during mutation. 0 = can 
%                 be removed, 1 = fixed but gene values can be mutated 
%                 using isMutable, 2 = fixed and non-mutatable. All fixed 
%                 nodes should be at the start of the genotype.
%  startGenotype (OPTIONAL)
%               - If included the GA will generate a starting population
%                 by mutating the startGenotype.
%
% (Required for runGasNet, see runGasNet documentation for details):
%  globalC      - Constant used in gas diffusion.
%  globalK      - Constant used in gas modulation.
%  nomValues    - Array of 1s & 0s which matches the gene length
%                 (where nomValues(i) > 0, genotype{-}(i) is nominal val).
%  elecThresh   - The gas emission threshold for electrical activity.
%  gasThresh    - The gas emission threshold for gas concentration.
%  maxT         - The maximum number of time steps for GasNet run.
%  fitFunction  - Function handle for fitness function.
%  fitLevel     - Stopping value for fitness.
%  getInput     - Function handle for input function.
%  outputNodes  - The nodes which are specifically output nodes. 
%                 Primarily used in fit func to evaluate a specific node.
%                 Output nodes should be matched to fixed nodes during
%                 optimisation. 
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
function [pop, fitness, stats] = optimiseGasNet(fitFunction,fitLevel,...
    planeWidth,nodeSeed,noOfValues,mu,isMutable,fixedNodes,maxRun,...
    elecThresh,gasThresh,globalC,globalK,nomValues,maxT,getInput,...
    outputNodes,modulationFunction,diffusionFunction,startGenotype)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Step 1 - Initialise Population %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(nargin < 19)
    pop = cell(planeWidth,planeWidth);
    for i=1:planeWidth
        for j=1:planeWidth
            pop{i,j} = cell(1,nodeSeed);
            for k=1:nodeSeed
                pop{i,j}{k} = randi([0,99],1,noOfValues);
                pop{i,j}{k}(16) = 0;
            end
        end
    end
else
    pop = cell(planeWidth,planeWidth);
    for i=1:planeWidth
        for j=1:planeWidth
            pop{i,j} = mutate(startGenotype,isMutable,fixedNodes,...
                                                            noOfValues,mu);
        end
    end
end
if(nargin < 18), diffusionFunction = @gasDiffusion; end;
if(nargin < 17), modulationFunction = @gasModulation; end;
if(nargin < 16), error('Insufficient parameters.'); end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Step 2 - Evolution %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initial evaluation.
fitness = zeros(planeWidth,planeWidth);
epoch = 1;
stats = zeros(maxRun-1,4);
peakFitness = 0;
peakPos = zeros(1,2);
total = 0;
for idx1=1:planeWidth
    for idx2=1:planeWidth
%         [~,noOfNodes] = size(pop{idx1,idx2});
%         score = 0;
%         for idx3=1:noOfNodes
%             score = score + sum(cell2mat(pop{idx1,idx2}(idx3)));
%         end
%         fitness(idx1,idx2) = score;
        [~,fitScores] = runGasNet(pop{idx1,idx2},elecThresh,...
            gasThresh,globalC,globalK,nomValues,0,maxT,fitFunction,...
            fitLevel,getInput,outputNodes,modulationFunction,...
            diffusionFunction);
        [~,c] = size(fitScores);
        fitness(idx1,idx2) = fitScores{c};                    
        if(fitness(idx1,idx2)>peakFitness)
            peakFitness = fitness(idx1,idx2);
            peakPos = [idx1 idx2];
        end
        
        total = total + fitness(idx1,idx2);
    end
end
avgFitness = total/(planeWidth^2);
stats(epoch,1) = avgFitness;
stats(epoch,2) = peakFitness;
stats(epoch,3) = peakPos(1,1);
stats(epoch,4) = peakPos(1,2);

wb = waitbar(0,'Evolution in progress');
while(epoch<maxRun && peakFitness<fitLevel)
    waitbar(epoch/maxRun,wb,...
           'Evolution in progress. (Wait represents epoch over max run)');
    %Step 2a - Select random rc positions.
    for popCount=1:planeWidth^2
        r = randi([1,planeWidth],1,1);
        c = randi([1,planeWidth],1,1);
        neighbourhood = zeros(9,2);
        
        %Step 2b - Neighbourhood Selection.
        % Neighbourhood indexes refer to 123;456;789 arrangement.
        % Code ensures distributed toroidal setup.
        neighbourhood(1,:) = [5,fitness(r,c)];
        positions = zeros(9,2);
        if(r==1)
            if(c==1)
                positions(1,1) = planeWidth; positions(1,2) = planeWidth;
                positions(2,1) = planeWidth; positions(2,2) = c;
                positions(3,1) = planeWidth; positions(3,2) = c+1;
                positions(4,1) = r; positions(4,2) = planeWidth;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = c+1;
                positions(7,1) = r+1; positions(7,2) = planeWidth;
                positions(8,1) = r+1; positions(8,2) = c;
                positions(9,1) = r+1; positions(9,2) = c+1;
            elseif(c==planeWidth)
                positions(1,1) = planeWidth; positions(1,2) = c-1;
                positions(2,1) = planeWidth; positions(2,2) = c;
                positions(3,1) = planeWidth; positions(3,2) = 1;
                positions(4,1) = r; positions(4,2) = c-1;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = 1;
                positions(7,1) = r+1; positions(7,2) = c-1;
                positions(8,1) = r+1; positions(8,2) = c;
                positions(9,1) = r+1; positions(9,2) = 1;
            else
                positions(1,1) = planeWidth; positions(1,2) = c-1;
                positions(2,1) = planeWidth; positions(2,2) = c;
                positions(3,1) = planeWidth; positions(3,2) = c+1;
                positions(4,1) = r; positions(4,2) = c-1;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = c+1;
                positions(7,1) = r+1; positions(7,2) = c-1;
                positions(8,1) = r+1; positions(8,2) = c;
                positions(9,1) = r+1; positions(9,2) = c+1;
            end
        elseif(r==planeWidth)
            if(c==1)
                positions(1,1) = r-1; positions(1,2) = planeWidth;
                positions(2,1) = r-1; positions(2,2) = c;
                positions(3,1) = r-1; positions(3,2) = c+1;
                positions(4,1) = r; positions(4,2) = planeWidth;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = c+1;
                positions(7,1) = 1; positions(7,2) = planeWidth;
                positions(8,1) = 1; positions(8,2) = c;
                positions(9,1) = 1; positions(9,2) = c+1;
            elseif(c==planeWidth)
                positions(1,1) = r-1; positions(1,2) = c-1;
                positions(2,1) = r-1; positions(2,2) = c;
                positions(3,1) = r-1; positions(3,2) = 1;
                positions(4,1) = r; positions(4,2) = c-1;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = 1;
                positions(7,1) = 1; positions(7,2) = c-1;
                positions(8,1) = 1; positions(8,2) = c;
                positions(9,1) = 1; positions(9,2) = 1;
            else
                positions(1,1) = r-1; positions(1,2) = c-1;
                positions(2,1) = r-1; positions(2,2) = c;
                positions(3,1) = r-1; positions(3,2) = c+1;
                positions(4,1) = r; positions(4,2) = c-1;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = c+1;
                positions(7,1) = 1; positions(7,2) = c-1;
                positions(8,1) = 1; positions(8,2) = c;
                positions(9,1) = 1; positions(9,2) = c+1;
            end
        else
            if(c==1)
                positions(1,1) = r-1; positions(1,2) = planeWidth;
                positions(2,1) = r-1; positions(2,2) = c;
                positions(3,1) = r-1; positions(3,2) = c+1;
                positions(4,1) = r; positions(4,2) = planeWidth;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = c+1;
                positions(7,1) = r+1; positions(7,2) = planeWidth;
                positions(8,1) = r+1; positions(8,2) = c;
                positions(9,1) = r+1; positions(9,2) = c+1;
            elseif(c==planeWidth)
                positions(1,1) = r-1; positions(1,2) = c-1;
                positions(2,1) = r-1; positions(2,2) = c;
                positions(3,1) = r-1; positions(3,2) = 1;
                positions(4,1) = r; positions(4,2) = c-1;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = 1;
                positions(7,1) = r+1; positions(7,2) = c-1;
                positions(8,1) = r+1; positions(8,2) = c;
                positions(9,1) = r+1; positions(9,2) = 1;
            else
                positions(1,1) = r-1; positions(1,2) = c-1;
                positions(2,1) = r-1; positions(2,2) = c;
                positions(3,1) = r-1; positions(3,2) = c+1;
                positions(4,1) = r; positions(4,2) = c-1;
                positions(5,1) = r; positions(5,2) = c;
                positions(6,1) = r; positions(6,2) = c+1;
                positions(7,1) = r+1; positions(7,2) = c-1;
                positions(8,1) = r+1; positions(8,2) = c;
                positions(9,1) = r+1; positions(9,2) = c+1;
            end
        end
        
        neighbourhood(1,:)=[1,fitness(positions(1,1),positions(1,2))];
        neighbourhood(2,:)=[2,fitness(positions(2,1),positions(2,2))];
        neighbourhood(3,:)=[3,fitness(positions(3,1),positions(3,2))];
        neighbourhood(4,:)=[4,fitness(positions(4,1),positions(4,2))];
        neighbourhood(5,:)=[5,fitness(positions(5,1),positions(5,2))];
        neighbourhood(6,:)=[6,fitness(positions(6,1),positions(6,2))];
        neighbourhood(7,:)=[7,fitness(positions(7,1),positions(7,2))];
        neighbourhood(8,:)=[8,fitness(positions(8,1),positions(8,2))];
        neighbourhood(9,:)=[9,fitness(positions(9,1),positions(9,2))];
        pool = sortrows(neighbourhood,2);
        
        %Step 2c - Linear roulette wheel selection.
        % The roulette wheel boundaries have been determined by Eq 8
        % Husbands et al (1998). The probablities were : 
        % 0, 2.2, 4.4, 6.6, 8.8, 11, 13.2, 15.4, 17.6, 19.8
        randPos = 99 * rand(1);
        poolIndex = 0;
        if(randPos < 2.2)
            poolIndex = 1;
        elseif(randPos < 6.6)
            poolIndex = 2;
        elseif(randPos < 13.2)
            poolIndex = 3;
        elseif(randPos < 22)
            poolIndex = 4;
        elseif(randPos < 33)
            poolIndex = 5;
        elseif(randPos < 46.2)
            poolIndex = 6;
        elseif(randPos < 61.6)
            poolIndex = 7;
        elseif(randPos < 79.2)
            poolIndex = 8;
        else
            poolIndex = 9;
        end
        
        % Parent positions collected from selected parent.
        parentRPos = positions(pool(poolIndex,1),1);
        parentCPos = positions(pool(poolIndex,1),2);
        
        child = mutate(pop{parentRPos,parentCPos},isMutable,...
                                                fixedNodes,noOfValues,mu);              
        pop{parentRPos,parentCPos} = child;
    end
    
    %Step 2d - Evaluate population fitnesses.
    % Reset values to zero.
    peakFitness = 0;
    total = 0;
    for l=1:planeWidth
        for m=1:planeWidth
%             [~,noOfNodes] = size(pop{l,m});
%             score = 0;
%             for k=1:noOfNodes
%                 score = score + sum(cell2mat(pop{l,m}(k)));
%             end
%             fitness(l,m) = score;
            [outputs,fitScores] = runGasNet(pop{l,m},elecThresh,...
                gasThresh,globalC,globalK,nomValues,0,maxT,fitFunction,...
                fitLevel,getInput,outputNodes,modulationFunction,...
                diffusionFunction);
            [~,c] = size(fitScores);
            fitness(l,m) = fitScores{c};           
            if(fitness(l,m)>peakFitness)
                peakFitness = fitness(l,m);
                peakPos = [l m];
            end
            
            total = total + fitness(l,m);
        end
    end
    avgFitness = total/planeWidth^2;
    stats(epoch,1) = avgFitness;
    stats(epoch,2) = peakFitness;
    stats(epoch,3) = peakPos(1,1);
    stats(epoch,4) = peakPos(1,2);
    epoch = epoch + 1;
end
close(wb);
end

function genotypeOut = mutate(genotypeIn,isMutable,fixedNodes,...
                                                            noOfValues,mu)
[~, noOfFixed] = size(find(fixedNodes > 0));
[~,noOfNodes] = size(genotypeIn);
genotypeOut = genotypeIn;
%Step1 - Gene value mutation (mu% chance).
for a=1:noOfNodes;
    [~,valNum] = size(genotypeIn{a});
    if(a>noOfFixed || fixedNodes(a) ~= 2)
        for b=1:valNum
            if(~isMutable(b)), continue; end;
            choice1 = randi([1,100],1,1);
            if(choice1<mu)
                %Gaussian centred on original value, with stdev of 10.
                new = ceil(genotypeIn{a}(b) + 10 * randn(1));
                if(new<0)
                    new = abs(new);
                elseif(new>99)
                    new = abs(99-(new-99));
                end
                genotypeOut{a}(b) = new;
            end
        end
    end
end

%Step2 - Node addition mutation (mu% chance).
choice2 = randi([1,100],1,1);
if(choice2 < mu)
    if(noOfValues<50)
        genotypeOut{noOfNodes+1} = zeros(1,noOfValues);
        genotypeOut{noOfNodes+1}(1:noOfValues-1) = ...
                                            randi([0,99],1,noOfValues-1);
    end
end

[~,noOfNodes] = size(genotypeOut);
%Step3 - Node removal mutation (mu% chance).
choice3 = randi([1,100],1,1);
if(choice3 < mu)
    if(noOfNodes>noOfFixed)
        idx = randi([noOfFixed+1,noOfNodes],1,1);
        genotypeOut(idx) = [];
    end
end

end