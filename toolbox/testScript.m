genotype = {[1,1,8,0,60,99,1,2,50]};
nomValues = [0,0,0,0,0,0,0,0,3];
[~, noOfGenes] = size(genotype);

phenotype = cell(1,noOfGenes);
for geneIndex=1:noOfGenes
    [~,valueLength] = size(genotype{geneIndex});
    temp = zeros(1,valueLength);
    for valueIndex=1:valueLength
        if(nomValues(valueIndex) > 0)
            %Phenotype value is a nominal value.
            'nom'
            temp(valueIndex) = mod(genotype{geneIndex}(valueIndex), ...
                                                   nomValues(valueIndex))
        else
            %Phenotype value is continuous.
            'continuous'
            temp(valueIndex) = genotype{geneIndex}(valueIndex)/99
        end
    end
    phenotype{geneIndex} = temp;
end
phenotype
