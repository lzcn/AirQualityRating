% Extract feture of transmission
% ExtractFeature_Transmission(dataset,FeatureFile,flag,TransmissionFile)
% It will save the result in './result/folder/Features/feature_file_name
% Input:
%        dataset = see 'set_image_data.m'
%                           num:
%                           path: {cell}
%                           name:{cell}
%                           aqi: []
%                           class: []
%                           folder:
%
%       'feature_file':file name which will be saved under directory 'Features'
%  
%       'flag': using for saving the Transmission gray images
%               if do saves in the directory 'TransmissionFile'
%       'transmission_file':The file name to store transmission images
function ExtractFeature_Transmission(dataset,feature_file_name,flag,transmission_folder_name)
% Extract Transimission  Feature for every image
if (nargin == 4 && flag == 1)
    SAVE_TRANSIMISSION_IMGAE = true; 
elseif (nargin == 3 && flag == 1)
    SAVE_TRANSIMISSION_IMGAE = true;
    transmission_folder_name = 'Transmission';
elseif (nargin == 2)
    SAVE_TRANSIMISSION_IMGAE = false;
end

outfolder = fullfile('result',dataset.folder);

%% Compute Transimisson 
% the directory to save features
feature_folder = fullfile(outfolder,'Features');
if exist(feature_folder,'file')==0 
             mkdir(feature_folder);
end;
feature_file_path = fullfile(feature_folder,feature_file_name);

fprintf('>>Computing transimission...\n');
fprintf('>>Dealing with    0/%4d',dataset.num);
file = fopen(feature_file_path,'wb');% saving the vector of features
for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     Transmission = GetTransmission(imread(dataset.path{i}));
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:numel(Transmission)
         fprintf(file,'%d ',Transmission(j));
     end
     fprintf(file,'\n'); 
     if SAVE_TRANSIMISSION_IMGAE
         % the directory to save feature images
         transmission_folder = fullfile(outfolder,transmission_folder_name);
         if exist(transmission_folder,'file')==0 
             mkdir(transmission_folder);
         end;
         transimission_image = fullfile(transmission_folder,dataset.name{i});
         imwrite(uint8(255.*Transmission),transimission_image);
     end
end
fclose all;
fprintf('\n');
disp('>>Done for compute trasmission!');
