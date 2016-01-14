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
    row = str2double( perl('countlines.pl',filename) );
end