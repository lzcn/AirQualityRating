% paras:
%   folder: image data which in '/data/folder' has two folders 'TraningSet' and 'TestSet'
%   flag : whether to save the feature image;
%   feature_func : select which features to exrract;
%   feature_file : the coresponding file to save feature vectors
%                  training set will be save as 'train_'+ feature_file;
%                  while test set as 'test_' + feature_file;
function interval = Extract_All_Features(folder,flag,feature_func,feature_file)
%% extract the origin features for training set 
TwoSet = {'TraningSet','TestSet'};
prefix = {'train_','test_'};
for k=1:2
    for i = 1:length(feature_func)
        dataset = set_image_data(folder,TwoSet{k});
        if dataset == -1 
            return;
        end
        feval(feature_func{i},dataset,feature_file{i},flag);
    end
end
Train_dataset = set_image_data(folder,'TrainingSet');
disp('>>Extract TrainingSet Features');

origin_train = {'train_transmission_origin','train_pss_origin','train_contrast_origin','train_saturation_origin'};
ExtractFeature_Transmission(Train_dataset,'train_transmission_origin',flag);
ExtractFeature_pss(Train_dataset,'train_pss_origin',flag);
ExtractFeature_contrast(Train_dataset,'train_contrast_origin',flag);
ExtractFeature_satu(Train_dataset,'train_saturation_origin',flag);
%% generate interval fo hist and rewrite the feature file
interval = cell(length(origin_train),1);
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