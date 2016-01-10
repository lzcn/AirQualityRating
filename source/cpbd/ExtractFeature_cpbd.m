% Extract feture of transmission
% ExtractFeature_Transmission(dataset,FeatureFile,flag,TransmissionFile)
% Input:
%       'dataset' : the format is 
%                   dataset =
%                           num:
%                           path: {cell}
%                           aqi: []
%                           class: []
%
% Output:
%       'FeatureFile':file name which will be saved under directory 'Features'
%  
%
function ExtractFeature_cpbd(dataset,FeatureFile)
addpath(genpath('source'));
if exist('Features','file')==0 
             mkdir('Features');
end;
featurefile = fullfile('Features','/',FeatureFile);

%% Compute Power Spectrum Slope
fprintf('Computing CPBD...\n');
fprintf('Dealing with   0/%4d',dataset.num);
xvalues = 0:0.02:1;
file = fopen(featurefile,'wb');% saving the vector of features
for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     q = q_cpbd(imread(dataset.path{i}));
     cpbd = hist(q,xvalues);
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:length(cpbd)
         fprintf(file,'%2.5f ',cpbd(j));
     end;
     fprintf(file,'\n');
end
fclose all;
fprintf('\n');
disp('>>>>>>Done for CPBD!');
fprintf('\n\n');