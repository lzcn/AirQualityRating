% Get the images informations in directory 'folder/dir' with image 'suffix'
% Example: folder =  'DATA_100';dir = 'TrainingSet';suffix= '.*jpg' 
% dataset  = set_image_data('DATA_100','TrainingSet')
% return databset =
%                   num: number of iamges
%                  path: {cell} 
%                   aqi: []
%                 class: []
%                folder: folder
function database = set_image_data(file_dir,data_dir,suffix)
if nargin == 2
    suffix = '*.jpg';
end

rt_data_dir = fullfile(file_dir,data_dir);
if ~isdir(rt_data_dir)
    fprintf('No folder named ''%s''!\n',rt_data_dir);
    database = -1; return
end
images = dir(fullfile(rt_data_dir,suffix));     
% information for database
database = [];  
database.num = length(images); % total image number of the database    
database.path = cell(database.num,1); % contain the pathes for each image of each class  
database.name = cell(database.num,1);
database.aqi = -ones(database.num,1); % label aqi for every image
database.class = -ones(database.num,1); % class for every image
idx = strfind(file_dir,'\');
database.file_dir = file_dir;
database.folder = file_dir(idx(2)+1:end);
%% build data and labels
index = 1;
for i = 1:length(images), 
    path = fullfile(rt_data_dir,images(i).name); 
    database.name{index} = images(i).name;
    database.path{index} = path;
    if strcmp(database.folder,'DATA_100')
        idAQI = strfind(database.path{i},'-');
        database.aqi(index) = str2double( database.path{i}(idAQI(1)+1:idAQI(2)-1));
        database.class(index) = label2class(database.aqi(index));
    elseif strcmp(database.folder,'DATA_200')
        idClass = strfind(database.path{i});
        database.classd(index) = str2double(database.path{i}(idClass - 1));
    end
    index = index + 1;
end;