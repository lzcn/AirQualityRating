% get the images in directory 'rt_data_dir' with image 'suffix'
% return 
%         database =
%                  num:
%                 path: {cell}
%                  aqi: []
%                class: []
function database = set_image_data(rt_data_dir,suffix)
if nargin == 1
    suffix = '*.jpg';
end
images = dir(fullfile(rt_data_dir,suffix));     
% information for database
database = [];  
database.num = 0;
database.img_num = 0;  % total image number of the database    
database.path = {};  % contain the pathes for each image of each class  
database.name = {};
database.aqi = []; % label aqi for every image
database.class = [];% class for every image

%% build data and labels
for i = 1:length(images), 
    database.img_num = length(images);
    
    path = fullfile(rt_data_dir,images(i).name); 
    database.name = [database.name,images(i).name];
    database.path = [database.path, path];
    idAQI = strfind(database.path{i},'-');
    AQI = str2double( database.path{i}(idAQI(1)+1:idAQI(2)-1));
    %delete the data without AQI
     if isnan(AQI)
         fprintf('%s\n',database.path{i});
         delete(database.path{i});
     end
    database.aqi = [database.aqi AQI ];
    database.class = [database.class label2class(AQI)];
end;
database.num = database.img_num;