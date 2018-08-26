% Genotype Setup (All integers [0:99]):
% Position in space:   1,2 [x, y,
% Positive section:
% (Using polar coordinate system:
% - 0 degrees is horizontal to right, movement is clockwise)
%                        3  Rp(radius), 
%                        4  theta1p(angular extent), 
%                        5  theta2p(orientation),
% Negative section:  6,7,8  Rn, theta1n, theta2n,
% Recurrancy:            9  Rec (either none, +ve or -ve),
% Gas Emmision:         10  TE (none, on electrical threshold,
%                               on gas1 threshold, on gas2 threshold),
% Gas Type:             11  CE,
% Gas Decay Rate:       12  s (p=1-11),
% Gas Radius:           13  R (from 10%-60% of plane dimension),
% Tanh index:           14  index,
% Bias:                 15  b (between -1:1),
% Is Input:             16  in
% Task Specific Variables:  ...]
genotype = {...
[0,0,8,50,0,8,0,0,0,2,1,50,20,30,60,0],...
[20,80,8,0,0,8,0,0,0,2,1,50,20,30,60,0],...
[80,50,8,0,0,8,0,0,0,3,0,5,99,30,60,0],...
[70,50,8,0,0,8,0,0,1,1,1,5,20,30,60,0],...
[70,45,8,0,0,8,0,0,2,1,1,1,20,30,60,0],...
[70,55,8,0,0,8,0,0,1,1,1,1,20,30,60,0]};

runGasNet(genotype,0.5,0.1,1,1,[0,0,0,0,0,0,0,0,3,4,2,0,0,0,0,2],...
                                  1,15,@cpgFourFourFitness,0.00001,0,[])