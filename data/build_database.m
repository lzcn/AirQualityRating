% This function is to build a database for the image sets   
% Input:  rt_data_dir -- directory of image sets  
%         suffix      -- image format like '*.jpg'  
%         TrainingFile-- directory of output for Trainingset
%                        (Default:TrainingSet)
%         TestFile    -- directory of output for Testset
%                        (Default:TestSet)
% Output: database    -- database that contains all the information of  
%                        images  
% 
function database = build_database(rt_data_dir,suffix,TrainingFile,TestFile)  

if nargin == 3
    TestFile = 'TestSet';
elseif nargin == 2
    TrainingFile = 'TrainingSet';
    TestFile = 'TestSet';
elseif nargin == 1
    suffix = '*.jpg';
    TrainingFile = 'TrainingSet';
    TestFile = 'TestSet';
end
SETBYCLASS = true;
fprintf('Building the database...\n'); 
% imgs = dir(fullfile(rt_data_dir,suffix));     
% % information for database
% database = [];  
% database.img_num = 0;  % total image number of the database    
% database.path = {};  % contain the pathes for each image of each class  
% database.aqi = []; % label aqi for every image
% database.class = [];% class for every image
% 
% %% build data and labels
% for i = 1:length(imgs), 
%     database.img_num = length(imgs);
%     
%     path = fullfile(rt_data_dir,imgs(i).name); 
%     database.path = [database.path, path];
%     idAQI = strfind(database.path{i},'-');
%     AQI = str2double( database.path{i}(idAQI(1)+1:idAQI(2)-1));
%     %delete the data without AQI
%      if isnan(AQI)
%          fprintf('%s\n',database.path{i});
%          delete(database.path{i});
%      end
%     database.aqi = [database.aqi AQI ];
%     database.class = [database.class label2class(AQI)];
% end;
%% Build Training set and Test set
disp('Building Training set....');
database = set_image_data(rt_data_dir,suffix);
if exist(TrainingFile,'file')==0 
    mkdir(TrainingFile);
end;
if exist(TestFile,'file')==0 
    mkdir(TestFile);
end;
for i = min(database.class):max(database.class);
    class_index_vector = find(database.class == i);
    perm_vector = randperm(size(class_index_vector,2));%random permutation for one class
    traningset_num = round(0.7*size(class_index_vector,2));% choose T for training set
    for j = 1:traningset_num
        % copy to traning file
        img_index = class_index_vector(perm_vector(j));
        copyfile(database.path{img_index},TrainingFile);
    end
    for j = traningset_num + 1 : size(class_index_vector,2)
        % copy to test file
        img_index = class_index_vector(perm_vector(j));
        copyfile(database.path{img_index},TestFile);
    end
end

if ~SETBYCLASS
    perm_vector = randperm(database.img_num); %random permutation for all data
    traningset_num = round(0.7*database.img_num); %chooose T for training set
    for i = 1:traningset_num
        copyfile(database.path{perm_vector(i)},'TrainingSet');
    end
    disp('Done building Training Set');
    for i = traningset_num+1:database.img_num
        copyfile(database.path{perm_vector(i)},'TestSet');
    end
    disp('Done building Test Set');
end
%%
disp('Done Building!'); 