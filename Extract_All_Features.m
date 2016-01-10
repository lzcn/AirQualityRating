function Extract_All_Features(folder,flag)
%% extract the origin features for training set 
Train_dataset = set_image_data(folder,'TrainingSet');
disp('>>Extract TrainingSet Features');
origin_train = {'train_transmission_origin','train_pss_origin','train_contrast_origin','train_saturation_origin'};
ExtractFeature_Transmission(Train_dataset,'train_transmission_origin',flag);
% ExtractFeature_cpbd(T rain_dataset,'train_cpbd');
ExtractFeature_pss(Train_dataset,'train_pss_origin',flag);
ExtractFeature_contrast(Train_dataset,'train_contrast_origin',flag);
ExtractFeature_satu(Train_dataset,'train_saturation_origin',flag);
%% generate interval fo hist and rewrite the feature file
interval = cell(length(origin_train),1);
file_dir = fullfile('source',folder,Features);
for kk =1:length(origin_train)
    feature_file_name = fullfile(file_dir,origin_train{kk});
    indata = readmydata(feature_file_name);
    interval{kk} = interval_for_hist(indata,50);
    dataset = feature_hist(indata,interval{kk});
    file = open(feature_file_name,'w');
    for i = 1:dataset.num
        fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
        for j = 1:length(dataset.feature{i})
            fprintf(file,'%d ',dataset.feature{i}(j));
        end
    end
end
disp('>>Done For training set!');

fprintf('\n');
%% extract the origin features for test set 
Test_dataset = set_image_data(folder,'TestSet');
disp('>>Extract TestSet Features')
ExtractFeature_Transmission(Test_dataset,'test_transmission_origin',flag);
% ExtractFeature_cpbd(Test_dataset,'test_cpbd');
ExtractFeature_pss(Test_dataset,'test_pss_origin',flag);
ExtractFeature_contrast(Test_dataset,'test_contrast_origin',flag);
ExtractFeature_satu(Test_dataset,'test_saturation_origin',flag);

%% Rewrite the test feature file
origin_test = {'test_transmission_origin','test_pss_origin','test_contrast_origin','test_saturation_origin'};
for kk =1:length(origin_test)
    feature_file_name = fullfile(file_dir,origin_test{kk});
    indata = readmydata(feature_file_name);
    interval{kk} = interval_for_hist(indata,50);
    dataset = feature_hist(indata,interval{kk});
    file = open(feature_file_name,'w');
    for i = 1:dataset.num
        fprintf(file,'%s\n%d\n',dataset.path{i},dataset.aqi(i));
        for j = 1:length(dataset.feature{i})
            fprintf(file,'%d ',dataset.feature{i}(j));
        end
    end
end
disp('>>Done For test set!');