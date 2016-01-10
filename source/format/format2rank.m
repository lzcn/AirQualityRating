function format2rank(train_file,test_file)
%  
cate = {'train_' 'test_'};
% feature = {'transmission' 'pss' 'cpbd' 'contrast' 'saturation'};
feature = {'transmission' 'pss' 'contrast' 'saturation'};
temp = cell(8,1);
xvalues = cell(4,1);
num = 1;
for i = 1:length(cate)
    for j = 1:length(feature)
        filename = strcat(cate{i},feature{j});
        fullname = fullfile('result/DATA_200/Features',filename);
        temp{num} = readmydata(fullname);
        [temp{num},xvalues{num}]= hist_with_kmeans(temp{num},5);
        num = num + 1;
    end
end

%data for train
data = datacat(temp(1:4));
v_l = length(data.feature{1});
% write in the format of rank svm 
file = fopen(train_file,'w');
for i = 1:data.num
    fprintf(file,'%d ',data.aqi(i));
    for j = 1:v_l
         fprintf(file,'%d:%d ',j,data.feature{i}(j));
     end
     fprintf(file,'\n');
end
%data for test
data = datacat(temp(5:8));
v_l = length(data.feature{1});
% write in the format of rank svm 
file = fopen(test_file,'w');
for i = 1:data.num
    fprintf(file,'%d ',data.aqi(i));
    for j = 1:v_l
         fprintf(file,'%d:%d ',j,data.feature{i}(j));
     end
     fprintf(file,'\n');
end