% Get the images informations in directory 'folder/dir' with image 'suffix'
% Example: folder =  'DATA_100';dir = 'TrainingSet';suffix= '.*jpg' 
% dataset  = set_image_data('DATA_100','TrainingSet')
% return databset =
%                   num: number of iamges
%                  path: {cell} 
%                   aqi: []
%                 class: []
%                folder: folder
function database = set_image_data(folder,data_dir,suffix)
if nargin == 2
    suffix = '*.jpg';
end
root = './data/';
rt_data_dir = fullfile(root,folder,data_dir);
if ~isdir(rt_data_dir)
    fprintf('No folder named ''%s''!\n',folder);
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
database.folder = folder;
%% build data and labels
index = 1;
for i = 1:length(images), 
    path = fullfile(rt_data_dir,images(i).name); 
    database.name{index} = images(i).name;
    database.path{index} = path;
    if strcmp(folder,'DATA100')
        idAQI = strfind(database.path{i},'-');
        database.aqi(index) = str2double( database.path{i}(idAQI(1)+1:idAQI(2)-1));
        database.class(index) = label2class(database.aqi(index));
    elseif strcmp(folder,'DATA200')
        idClass = strfind(database.path{i});
        database.classd(index) = str2double(database.path{i}(idClass - 1));
    end
    index = index + 1;
end;