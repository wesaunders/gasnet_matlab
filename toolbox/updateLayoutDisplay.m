%updateLayoutDisplay function:
% This function produes a display of the GasNet space, depicting the
% location of nodes, gas radii and connections from the genotype.
% Genotype must be of 1998 standard.
%
% Author: Will Saunders 
% Date: 12.12.11
%
% Parameters:
%  genotype     - Cell Array GasNet genotype to run.
%  nomValues    - Array of 1s & 0s which matches the gene length
%                 (where nomValues(i) > 0, genotype{-}(i) is nominal val).
%
function [] = updateLayoutDisplay(genotype,nomValues)
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

%Derive connections:
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
    if (phenotype{k}(9) == 1)
        connections{k}{connectionIndexes(k)} = [k,1];
        connectionIndexes(k) = connectionIndexes(k) + 1;
    elseif (phenotype{k}(9) == 2)
        connections{k}{connectionIndexes(k)} = [k,-1];
        connectionIndexes(k) = connectionIndexes(k) + 1;
    end
    
    for l=1:noOfGenes
        if(l==k), continue; end;
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
%%%%%%%%%%%%%%%%%%%%%%% Step 1 - Produce Display %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold on;
axis tight;
axis square;
for i=1:noOfGenes
    %Plot position:
    if(phenotype{i}(16))
        plot(phenotype{i}(1),phenotype{i}(2),'Marker','*','Color','k')
        text(phenotype{i}(1)+0.025,phenotype{i}(2)+0.025,num2str(i),...
                                                            'FontSize',10);
    else
        plot(phenotype{i}(1),phenotype{i}(2),'Marker','o','Color','k')
        text(phenotype{i}(1)+0.025,phenotype{i}(2)+0.025,num2str(i),...
                                                            'FontSize',10);
    end
    
    %Plot gas cloud:
    if(phenotype{i}(11)==0 && phenotype{i}(10)~=0)
        theta = 0:(2 * pi)/500:2*pi;
        xline = phenotype{i}(1) + phenotype{i}(13) * cos(theta);
        yline = phenotype{i}(2) + phenotype{i}(13) * sin(theta);
        plot(xline,yline,'LineStyle','-','Color','b');
        plot([phenotype{i}(1),xline(1)],[phenotype{i}(2),yline(2)],...
                                            'LineStyle','-','Color','b');
    elseif(phenotype{i}(11)==1 && phenotype{i}(10)~=0)
        theta = 0:(2 * pi)/500:2*pi;
        xline = phenotype{i}(1) + phenotype{i}(13) * cos(theta);
        yline = phenotype{i}(2) + phenotype{i}(13) * sin(theta);
        plot(xline,yline,'LineStyle','-','Color','r')
        plot([phenotype{i}(1),xline(1)],[phenotype{i}(2),yline(2)],...
                                            'LineStyle','-','Color','r');
    end
    
    %Plot connections:
    [~,n]=size(connections{i});
    if(n > 0)
        for cnctIndex=1:n
            if(connections{i}{cnctIndex}(2)>0)
                if(connections{i}{cnctIndex}(1)==i)
                    theta = 0:(2 * pi)/500:2*pi;
                    xline = (phenotype{i}(1)+0.025) + 0.04 * cos(theta);
                    yline = (phenotype{i}(2)+0.025) + 0.04 * sin(theta);
                    plot(xline,yline,'--g');
                else
                    plot([phenotype{i}(1),...
                        phenotype{connections{i}{cnctIndex}(1)}(1)],...
                        [phenotype{i}(2),...
                        phenotype{connections{i}{cnctIndex}(1)}(2)],...
                        '--g');
                end
            else
                if(connections{i}{cnctIndex}(1)==i)
                    theta = 0:(2 * pi)/500:2*pi;
                    xline = (phenotype{i}(1)+0.025) + 0.04 * cos(theta);
                    yline = (phenotype{i}(2)+0.025) + 0.04 * sin(theta);
                    plot(xline,yline,':m');
                else
                    plot([phenotype{i}(1),...
                        phenotype{connections{i}{cnctIndex}(1)}(1)],...
                        [phenotype{i}(2),...
                        phenotype{connections{i}{cnctIndex}(1)}(2)],...
                        ':m');
                end
            end
        end
    end
end
hold off;
    
