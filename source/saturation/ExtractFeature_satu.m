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
function ExtractFeature_satu(dataset,feature_file,flag,saturation_folder_name)
if (nargin == 4 && flag == 1)
    SAVE_SATURATION_IMGAE = true; 
elseif (nargin == 3 && flag == 1)
    SAVE_SATURATION_IMGAE = true;
    saturation_folder_name = 'Saturation';
elseif (nargin == 2)
    SAVE_SATURATION_IMGAE = false;
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
fprintf('>>Computing saturation...\n');
fprintf('>>Dealing with   0/%4d',dataset.num);
file = fopen(feature_file_path,'wb');% saving the vector of features
xvalues = 0:0.01:0.5;
for i = 1:dataset.num
     fprintf('\b\b\b\b\b\b\b\b\b');
     fprintf('%4d/%4d',i,dataset.num);
     satu = NormedSatu(imread(dataset.path{i}));
     [count,~]= hist(satu(:),xvalues);
     fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
     for j = 1:length(count)
         fprintf(file,'%2.5f ',count(j));
     end;
     fprintf(file,'\n');
     if SAVE_SATURATION_IMGAE
         saturation_folder = fullfile(outfolder,saturation_folder_name);
         if exist(saturation_folder,'file')==0 
             mkdir(saturation_folder);
         end;
         saturation_image = fullfile(saturation_folder,dataset.name{i});
         imwrite(uint8(255.*satu),saturation_image);
     end
end
fclose all;
fprintf('\n');
disp('>>Done for Saturation!');