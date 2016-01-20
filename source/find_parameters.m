function [best_c,best_g,best_rate] = find_parameters(varargin)
if nargin < 1
    error(message('stats:grid:TooFewInputs'));
end

pnames = { 'svm_type' ...
           'c_range' 'c_step' ...
           'g_range' 'g_step' ...
           'fold' ...
           'train_filename' ...
           'test_filename' ...
           'svm_path'};
dflts =  { 5 ...
           [-5 15] 2 ...
           [3 -15] -2 ...
           5 ...
           'train' ...
           'test' ...
           '.\bin'};
[ svm_type,...
  c_range,c_step,...
  g_range,g_step,...
  fold,...
  train_filename,...
  test_filename,...
  svm_path ] ...
  = internal.stats.parseArgs(pnames, dflts, varargin{:});
% init paras and feature files
best_c = c_range(1);
best_g = g_range(1);
best_rate = 0;
train_scale = 'train.scale';
test_scale = 'test.scale';
cmdline = get_cmd('svm_path',svm_path,...
                  'svm_bin','svm-scale',...
                  'l','-1','u','1',...
                  'train_filename',train_filename,...
                  'scale_file',train_scale);
eval(cmdline);
cmdline = get_cmd('svm_path',svm_path,...
                  'svm_bin','svm-scale',...
                  'l','-1','u','1',...
                  'train_filename',test_filename,...
                  'scale_file',test_scale);

eval(cmdline);
% find paras
x = meshgrid(c_range(1):c_step:c_range(2),g_range(1):g_step:g_range(2));
y = meshgrid(g_range(1):g_step:g_range(2),c_range(1):c_step:c_range(2));
z = zeros(length(y),length(x));
m = 1;
for i = c_range(1):c_step:c_range(2)
    n = 1;
    for j = g_range(1):g_step:g_range(2)
        c_tmp =  2^i;
        g_tmp =  2^j;
        switch(svm_type)
            case 5 % using ranksvm
                cmdline = get_cmd('svm_path',svm_path,...
                                  'svm_bin','svm-train',...
                                  'svm_type',svm_type,...
                                  'c',c_tmp,'g',g_tmp,...
                                  'train_filename',train_scale);
                evalc(cmdline);
                model_file = strcat(train_scale,'.model');
                output_file = strcat(train_scale,'rank.out');
                cmdline = get_cmd('svm_path',svm_path,...
                                  'svm_bin','svm-predict',...
                                  'test_filename',test_scale,...
                                  'model_file',model_file,...
                                  'output_file',output_file);
                result = evalc(cmdline);
                best_rate_new = str2double(result(20:27));
                if ~isnan(best_rate_new)
%                     line([i,i],[j,j],[0,round(best_rate_new)],'LineWidth',10,'Color',cmap(round(best_rate_new*2.55),:));
                    z(n,m) = best_rate_new;
                else
                    z(n,m) = 0;
                end
            case 0 % 
            otherwise %
        end        
        if ~isnan(best_rate_new) && (best_rate_new > best_rate)
          best_rate = best_rate_new;
          best_c = c_tmp;
          best_g = g_tmp;
        end   
        m = m + 1;
    end
    n = n + 1;
end
meshc(x,y,z);




function cmdline = get_cmd(varargin)
pnames = { 'svm_path' ...
           'svm_bin' ...
           'svm_type' ...
           'c' 'g' ...
           'l' 'u' ...
           'fold' ...
           'train_filename' ...
           'test_filename' ...
           'model_file' ...
           'scale_file' ...
           'output_file'};
dflts =  { '.\bin' ...
           [] ...
           [] ...
           1  1 ...
           '-1' '1' ...
           5 ...
           [] ...
           [] ...
           [] ...
           [] ...
           [] };
[ svm_path,...
  svm_bin,...
  svm_type,...
  c,g,...
  l,u,...
  fold,...
  train_filename,...
  test_filename,...
  model_file,...
  scale_file,...
  output_file ] ...
  = internal.stats.parseArgs(pnames, dflts, varargin{:});
dflts_svm_bin = {'svm-scale','svm-train','svm-predict'};
svm_bin = internal.stats.getParamVal(svm_bin,dflts_svm_bin,'''SVMBIN''');
switch (svm_bin)
    case 'svm-scale'
        cmdline = [ '!',fullfile(svm_path,svm_bin),...
                    ' -l ',l...
                    ' -u ',u,...
                    ' -s range ',...
                    ' ',train_filename,' > ',...
                    ' ',scale_file];
    case 'svm-train'
        if svm_type == 0;
            cmdline = [ '!',fullfile(svm_path,svm_bin),...
                        ' -s ',num2str(svm_type)...
                        ' -t 2',...
                        ' -c ',num2str(c),...
                        ' -g ',num2str(g),...
                        ' -v ',num2str(fold),...
                        ' ',train_filename];
        elseif svm_type == 5
            cmdline = [ '!',fullfile(svm_path,svm_bin),...
                        ' -s ',num2str(svm_type)...
                        ' -t 2',...
                        ' -c ',num2str(c),...
                        ' -g ',num2str(g),...
                        ' ',train_filename];
        end
     case 'svm-predict'
        cmdline = [ '!',fullfile(svm_path,svm_bin),...
                    ' ',test_filename,...
                    ' ',model_file,...
                    ' ',output_file];
        
    otherwise
end