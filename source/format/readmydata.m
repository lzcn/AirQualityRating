% read the single feature file
function data = readmydata(file)
row = linenum(file);
data = [];
data.num = row/3;
data.im = cell(row/3,1);
data.aqi = -ones(row/3,1);
data.feature = cell(row/3,1);
fid = fopen(file,'r');
num = 1;
while ~feof(fid)
    % image information
    line = fgetl(fid);
    if ~isempty(line);
        data.im{num} = line;
    end
    % aqi
    line = fgetl(fid);
    if ~isempty(line);
        data.aqi(num) = str2double(line);
    end
    % feature vector
    line = fgetl(fid);
    if ~isempty(line);
        data.feature{num} = str2num(line);
        if size(data.fearture{num},2) > size(data.fearture{num},1)
            data.fearture{num} = data.fearture{num}';
        end
    end
    num = num + 1 ;
end
fclose(fid);