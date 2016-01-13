% paras:
%   folder: image data which in '/data/folder' has two folders 'TraningSet' and 'TestSet'
%   flag : whether to save the feature image;
%   feature_func : select which features to extract;
%   feature_file : the coresponding file to save feature vectors
%                  training set will be save as 'train_'+ feature_file;
%                  while test set as 'test_' + feature_file;
function eaf = Extract_All_Features(folder,flag,feature_func,feature_file,feature_file_dir)
%% extract the origin features
TwoSets = {'TraningSet','TestSet'};
prefix = {'train_','test_'};

if length(feature_func) ~= length(feature_file)
    eaf = -1;
    fprintf('>> function''s length doesn''t matchs file''s\n');
    return;
else NumF = length(feature_func);
end
for i = 1:2
    feature_fullname = strcat(prefix{1},feature_file(:));
    dataset = set_image_data(folder,TwoSets{i});
    if dataset == -1
        eaf = -1;
        return;
    end
    fprintf('>> Extract %s''s Features\n',TwoSets{i});
    parfor j = 1:length(feature_func)
        feval(feature_func{j},dataset,feature_fullname{j},flag);
    end
end
% Train_dataset = set_image_data(folder,'TrainingSet');
% disp('>>Extract TrainingSet Features');
% 
% origin_train = {'train_transmission_origin','train_pss_origin','train_contrast_origin','train_saturation_origin'};
% ExtractFeature_Transmission(Train_dataset,'train_transmission_origin',flag);
% ExtractFeature_pss(Train_dataset,'train_pss_origin',flag);
% ExtractFeature_contrast(Train_dataset,'train_contrast_origin',flag);
% ExtractFeature_satu(Train_dataset,'train_saturation_origin',flag);
%% generate interval fo hist and rewrite the feature file
interval = cell(NumF,1);
% the directory storing the feature files
feature_file_dir = fullfile('result',folder,'Features');
for kk =1:length(origin_train)
    feature_file_name = fullfile(feature_file_dir,origin_train{kk});
    indata = readmydata(feature_file_name);
    interval{kk} = interval_for_hist(indata,50);
    dataset = feature_hist(indata,interval{kk});
    fid = fopen(feature_file_name,'r');
    for i = 1:dataset.num
        fprintf(fid,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
        for j = 1:length(dataset.feature{i})
            fprintf(fid,'%d ',dataset.feature{i}(j));
        end
    end
    fclose(fid);
end
disp('>>Done For training set!');

fprintf('\n');
%% extract the origin features for test set 
Test_dataset = set_image_data(folder,'TestSet');
disp('>>Extract TestSet Features');
ExtractFeature_Transmission(Test_dataset,'test_transmission_origin',flag);
ExtractFeature_pss(Test_dataset,'test_pss_origin',flag);
ExtractFeature_contrast(Test_dataset,'test_contrast_origin',flag);
ExtractFeature_satu(Test_dataset,'test_saturation_origin',flag);

%% Rewrite the test feature file
origin_test = {'test_transmission_origin','test_pss_origin','test_contrast_origin','test_saturation_origin'};
for kk =1:length(origin_test)
    feature_file_name = fullfile(feature_file_dir,origin_test{kk});
    indata = readmydata(feature_file_name);
    dataset = feature_hist(indata,interval{kk});
    fid = fopen(feature_file_name,'w');
    for i = 1:dataset.num
        fprintf(fid,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
        for j = 1:length(dataset.feature{i})
            fprintf(fid,'%d ',dataset.feature{i}(j));
        end
    end
    fclose(fid);
end
disp('>>Done For test set!');