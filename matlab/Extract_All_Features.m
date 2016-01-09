function Extract_All_Features(folder,flag)
% for training set 
Train_dataset = set_image_data(folder,'TrainingSet');
disp('>>Extract TrainingSet Features');
ExtractFeature_Transmission(Train_dataset,'train_transmission',flag);
% ExtractFeature_cpbd(T rain_dataset,'train_cpbd');
ExtractFeature_pss(Train_dataset,'train_pss',flag);
ExtractFeature_contrast(Train_dataset,'train_contrast',flag);
ExtractFeature_satu(Train_dataset,'train_saturation',flag);
disp('>>Done For training set!');
fprintf('\n');
% for test set
Test_dataset = set_image_data(folder,'TestSet');
disp('>>Extract TestSet Features')
ExtractFeature_Transmission(Test_dataset,'test_transmission',flag);
% ExtractFeature_cpbd(Test_dataset,'test_cpbd');
ExtractFeature_pss(Test_dataset,'test_pss',flag);
ExtractFeature_contrast(Test_dataset,'test_contrast',flag);
ExtractFeature_satu(Test_dataset,'test_saturation',flag);
disp('>>Done For test set!');