% Extract feture of transmission
% ExtractFeature_Transmission(dataset,FeatureFile,flag,TransmissionFile)
% Input:
%        dataset = see 'set_image_data.m'
%                           num:
%                           path: {cell}
%                           name:{cell}
%                           aqi: []
%                           class: []
%                           folder:
% Output:
%       'FeatureFile':file name which will be saved under directory 'Features'
%  
%
function ExtractFeature_contrast(dataset,feature_file,flag,contrast_file_name)
if (nargin == 4 && flag == 1)
    SAVE_CONTRAST_IMGAE = true; 
elseif (nargin == 3 && flag == 1)
    SAVE_CONTRAST_IMGAE = true;
    contrast_file_name = 'Contrast';
elseif (nargin == 2)
    SAVE_CONTRAST_IMGAE = false;
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
fprintf('>>Computing contrast...\n');
fprintf('>>Dealing with   0/%4d',dataset.num);

file = fopen(feature_file_path,'wb');% saving the vector of features
for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     im = imread(dataset.path{i});
     contrast = Contrast(im);
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:numel(contrast)
         fprintf(file,'%1.6f ',contrast(j));
     end;
     fprintf(file,'\n');
     if SAVE_CONTRAST_IMGAE
         contrast_folder = fullfile(outfolder,contrast_file_name);
         if exist(contrast_folder,'file') == 0
             mkdir(contrast_folder);
         end
         contrast_image = fullfile(contrast_folder,dataset.name{i});
         MaxValue = max(max(contrast));
         MinValue = min(min(contrast));
         im_c = uint8(255*(contrast - MinValue)/(MaxValue - MinValue));
         imwrite(uint8(im_c),contrast_image);
     end
end
fclose all;
fprintf('\n');
disp('>>Done for compute contrast!');