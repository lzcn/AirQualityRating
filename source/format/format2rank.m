
%   paras:         
%         file_dir: the file directory to save result feature file
%         train_old: files of origin train feature
%         train_file: the file saved train featrues
%         test_old : files of origin test feature
%         trast_file: the file saved test featrues
         
function f = format2rank(file_dir,train_origin,train_file,test_origin,test_file)

if length(train_origin) ~= length(test_origin)
    f = -1;
    fprintf('>> train''s featrue don''t match test''s!');
    teturn;
else NumF = length(train_origin); 
end

filename =[train_origin;test_origin]
data_origin = cell(2*NumF,1);
for j = 1:2*NumF
    data_origin{j} = readmydata(filename{j});
end
cate = {fullfile(file_dir,train_file),fullfile(file_dir,test_file)};
for i = 1:2    
    data_all = datacat(data_origin(NumF*(i-1)+1:NumF*i));
    v_l = length(data_all.feature{1});
    fid = fopen(cate{i},'w');
    for m = 1:data_all.num
        fprintf(fid,'%d ',data_all.aqi(m));
        for n = 1:v_l
            fprintf(fid,'%d:%d ',n,data_all.feature{m}(n));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end
    