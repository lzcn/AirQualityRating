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
function ExtractFeature_satu(dataset,out_folder,feature_file,flag,saturation_folder_name)
if (nargin == 5 && flag == 1)
    SAVE_SATURATION_IMGAE = true; 
elseif (nargin == 4 && flag == 1)
    SAVE_SATURATION_IMGAE = true;
    saturation_folder_name = 'Saturation';
elseif (nargin == 3)
    SAVE_SATURATION_IMGAE = false;
end

if exist(out_folder,'file')==0 
             mkdir(out_folder);
end;

% the name of feature file
feature_file_path = fullfile(out_folder,feature_file);
%% Compute Power Spectrum Slope

fprintf('>>Computing saturation...\n');
fprintf('>>Dealing with   0/%4d',dataset.num);
file = fopen(feature_file_path,'wb');% saving the vector of features
for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     satu = LocalSaturation(imread(dataset.path{i}));
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:numel(satu)
         fprintf(file,'%2.5f ',satu(j));
     end;
     fprintf(file,'\n');
     if SAVE_SATURATION_IMGAE
         saturation_folder = fullfile(out_folder,saturation_folder_name);
         if exist(saturation_folder,'file')==0 
             mkdir(saturation_folder);
         end;
         saturation_image = fullfile(saturation_folder,dataset.name{i});
         MaxValue = max(max(satu));
         MinValue = min(min(satu));
         im_s = uint8(255*(satu - MinValue)/(MaxValue - MinValue));
         imwrite(im_s,saturation_image);
     end
end
fclose all;
fprintf('\n');
disp('>>Done for Saturation!');