% read the single feature file
function data = readmydata(file)
row = linenum(file);
data = [];
data.num = row/3;
data.path = cell(row/3,1);
data.aqi = -ones(row/3,1);
data.feature = cell(row/3,1);
fid = fopen(file,'r');
num = 1;
while ~feof(fid)
    % image information
    line = fgetl(fid);
    if ~isempty(line);
        data.path{num} = line;
    end
    % aqi
    line = fgetl(fid);
    if ~isempty(line);
        data.aqi(num) = str2double(line);
    end
    % feature vector
    line = fgetl(fid);
    if ~isempty(line);
        data.feature{num} = str2num(line)';
        if size(data.feature{num},2) > size(data.feature{num},1)
            data.feature{num} = data.feature{num}';
        end
    end
    num = num + 1 ;
end
fclose(fid);

function row = linenum(filename)
if (isunix)
    [~, numstr] = system( ['wc -l ', 'data.csv'] );
    row = str2double(numstr);
elseif (ispc) 
    if exist('countlines.pl','file')~=2
        fid=fopen('countlines.pl','w');
        fprintf(fid,'%s\n%s','while (<>) {};','print $.,"\n";');
        fclose(fid);
    end
    row = str2double( perl('countlines.pl', filename) );
end