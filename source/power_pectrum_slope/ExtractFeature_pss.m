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
function ExtractFeature_pss(dataset,feature_file,flag,pss_file_name)
if (nargin == 4 && flag == 1)
    SAVE_PSS_IMGAE = true; 
elseif (nargin == 3 && flag == 1)
    SAVE_PSS_IMGAE = true;
    pss_file_name = 'Contrast';
elseif (nargin == 2)
    SAVE_PSS_IMGAE = false;
end

outfolder = fullfile('result',dataset.folder);
% the directory to save features
feature_folder = fullfile(outfolder,'Features');

if exist(feature_folder,'file')==0 
             mkdir(feature_folder);
end;
% the name of feature file 
feature_file_path = fullfile(feature_folder,feature_file);

%% Compute Power Spectrum Slope
fprintf('>>Computing Power Spectrum Slope...\n');
fprintf('>>Dealing with   0/%4d',dataset.num);

file = fopen(feature_file_path,'wb');% saving the vector of features

for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     pss = LocalPowerSpectrumSlope(imread(dataset.path{i}),17);
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:numel(pss)
         fprintf(file,'%2.5f ',pss(j));
     end;
     fprintf(file,'\n');
     if SAVE_PSS_IMGAE
         pss_folder = fullfile(outfolder,pss_file_name);
         if exist(pss_folder,'file')==0
             mkdir(pss_folder);
         end
         pss_image_path = fullfile(pss_folder,dataset.name{i});
         imwrite(pss,pss_image_path);
     end
end
fclose all;
fprintf('\n');
disp('>>Done for compute Power Spectrum Slope!');