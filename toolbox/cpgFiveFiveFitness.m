%CPG Fitness Function for Five:Five pattern.
% This function evaluates the output of the network for the symmetrical
% Five:Five pattern generation task.
function [fitness] = cpgFiveFiveFitness(outputs,time,outputNodes)
[~,noOfOutNodes] = size(outputNodes);
if(noOfOutNodes>1)
    error(['Only one output node is permitted in the Five:Five',... 
                                                ' CPG Fitness Function']);
end
fitness = 0;

target=[];
for i=1:20
    %target = [target ones(1,10)];
    %target = [target ones(1,10)*-1];
    target = [target ones(1,5) ones(1,5)*-1];
end

if(time>200)
    % Isolate desired output column:
    [~,c] = size(outputs);
    tmp = flipud(cell2mat(rot90(outputs)));
    out = tmp(c-199:c,outputNodes(1));
    % Call threshold function:
    thresh_out = threshold(out'); 
    % This makes all points that match the target = 1:
    d = double((thresh_out == target)); 
    % Sum(d) is number of places different to target:
    fitness = sum(d)/200; 
end
end

function [out] = threshold(in)
out(in>=0)=1;
out(in<0)=-1;
end