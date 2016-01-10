function data = readmydata(file)
row = linenum(file);
data = [];
data.num = row/3;
data.im = {row/3};
data.aqi = (row/3);
data.feature = {row/3};
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
        data.feature{num} = data.feature{num}/sum(data.feature{num});
    end
    num = num + 1 ;
end

fclose(fid);