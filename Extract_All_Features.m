% paras:
%   file_dir: image data in file_dir has two folders 'TraningSet' and 'TestSet'
%   flag : whether to save the feature image or not;
%   feature_func : select which features to extract;
%   feature_file : the coresponding file to save feature vectors
%                  training set will be save as 'train_'+ feature_file;
%                  while test set as 'test_' + feature_file;
%                  both saved under directory:file_dir/Features
%   prefix: the prefix for out file of training set ,test set or both
%   Sets: the sets to extract featrues eg: {'TrainingSet','TestSet'}
% output:
%   eaf: all of feature files
function eaf = Extract_All_Features(file_dir,...
                                    flag,...
                                    feature_func,...
                                    feature_file_dir,...
                                    feature_file,...
                                    prefix,...
                                    Sets)
%% extract the origin features

if length(feature_func) ~= length(feature_file)
    fprintf('>> function''s length doesn''t matchs file''s\n');
    return;
else NumF = length(feature_func);
end
if length(prefix) ~= length(Sets)
    fprintf('>> Sets''s length   doesn''t matchs prefix\n');
    return;
end
for i = 1:length(Sets)
    feature_fullname = strcat(prefix{i},'origin_',feature_file(:));
    data_train_new = set_image_data(file_dir,Sets{i});
    fprintf('>> Extract %s''s Features\n',Sets{i});
    for j = 1:length(feature_func)
%         feval(feature_func{j},data_train_new,feature_file_dir,feature_fullname{j},flag);
    end
end

%% generate intervals fo hist and rewrite the feature file
% the directory storing the feature files
origin_train_feature = fullfile(feature_file_dir,strcat(prefix{1},'origin_',feature_file(:)));
origin_test_feature = fullfile(feature_file_dir,strcat(prefix{2},'origin_',feature_file(:)));
final_train_feature = fullfile(feature_file_dir,strcat(prefix{1},feature_file(:)));
final_test_feature = fullfile(feature_file_dir,strcat(prefix{2},feature_file(:)));
eaf{1} = final_train_feature;
eaf{2} = final_test_feature;
% for n = 1:NumF
%     data_train = readmydata(origin_train_feature{n});
%     interval = interval_for_hist(data_train,50);
%     data_train_new = feature_hist(data_train,interval);
%     fid_train = fopen(final_train_feature{n},'wb');
%     for i = 1:data_train_new.num
%         fprintf(fid_train,'%s\n%d\n',data_train_new.path{i},data_train_new.aqi(i));
%         for j = 1:length(data_train_new.feature{i})
%             fprintf(fid_train,'%d ',data_train_new.feature{i}(j));
%         end
%         fprintf(fid_train,'\n');
%     end
%     fclose(fid_train);clear data_train;
%     data_test = readmydata(origin_test_feature{n});
%     data_test_new = feature_hist(data_test,interval);
%     fid_test = fopen(final_test_feature{n},'wb');
%     for i = 1:data_test_new.num
%         fprintf(fid_test,'%s\n%d\n',data_test_new.path{i},data_test_new.aqi(i));
%         for j = 1:length(data_test_new.feature{i})
%             fprintf(fid_test,'%d ',data_test_new.feature{i}(j));
%         end
%         fprintf(fid_train,'\n');
%     end
%     fclose(fid_test);clear data_test;
% end
% disp('>>Done!');
% fprintf('\n');

% using k means to cluster all elements of feature vector of all instances 
% to k clusters and generate k intervals 
% then using the intervals to histogram every vectors to k dimensions
% input :
%    data(indata):
%              path:{cell}
%              aqi:
%          feature:{cell}
function data = feature_hist(indata,interval)
data = [];
data.num = length(indata.path);
data.path = indata.path;
data.aqi = indata.aqi;
data.feature = cell(data.num,1);
for i = 1:data.num
    data.feature{i} = hist(indata.feature{i},interval);
end

% using k means to cluster all elements of feature vector of all instances 
% to k clusters and generate k intervals 
% then using the intervals to histogram every vectors to k dimensions
% input :
%    data(indata):
%              im:{cell}
%              aqi:
%          feature:{cell}
%    k : k clusters
% output : the interval for histogram
function interval = interval_for_hist(indata,k)
data = [];
data.num = length(indata.path);
data.path = cell(data.num,1);
data.aqi = -ones(data.num,1);
data.calss = -ones(data.num,1);
data.feature = cell(data.num,1);
% write all emelemt of features to a vector
elem = [];
for i = 1:10
    elem = [elem;indata.feature{i}];
end

IDX = kmeans(elem,k);
xvalues = zeros(2*k,1);
for  j = 1:k
    xvalues(2*j-1) = min(elem(find(IDX == j)));
    xvalues(2*j) = max(elem(find(IDX == j)));
end
xvalues = sort(xvalues);
% generate the interval
interval = zeros(k+1,1);
interval(1) = xvalues(1);
for ii =1:k
    interval(ii+1) = xvalues(2*ii);
end