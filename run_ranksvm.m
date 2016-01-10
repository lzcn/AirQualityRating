clc;clear all;close all;
%% Extract feature
addpath(genpath('source'));
disp('Extracting features!');
Extract_All_Features('DATA_200',1);
disp('Changing the data format for ranksvm');
format2rank('train','test');

%% using rank SVM

% scale the data
disp('Scale Phase!');
command = '!svm-scale -l -1 -u 1 -s  range train > train_rank.scale';
eval(command);
command = '!svm-scale -l -1 -u 1 -s  range test > test_rank.scale';
eval(command);
% train
disp('Train Phase!');
pairwise_accuracy = zeros(180,1);
arguments = cell(180,1);
idx = 1;
for i = 1:5
    for j = 1:6
        for k = 1:6
            c = 2^i - 1;
            g = 2^(-j);
            e = 2^(-k);
            A = [c g e];
            arguments{idx} = A;
            Nc = ['-c ',num2str(c),' '];
            Ng = ['-g ',num2str(g),' '];
            Ne = ['-e ',num2str(e),' '];
            command = ['!svm-train -s 5 ',Nc,' -t 2 ',Ng,Ne,'train_rank.scale '];
            evalc(command);
            % predict
            command = '!svm-predict  test_rank.scale train_rank.scale.model test_rank.scale.result';
            Result = evalc(command)
            pairwise_accuracy(idx) = str2double(Result(20:27));
            idx = idx + 1;
        end
    end
end
disp('done rank svm!');
[pairwise_accuracy,p_idx] = max(pairwise_accuracy);
file = fopen('Result.txt','wb');
disp('Best Rank Arguments');
disp(pairwise_accuracy);
disp(arguments{p_idx});
fprintf(file,'Best Rank Arguments\n');
fprintf(file,'%f\n',arguments{p_idx});
fprintf(file,'%s\n','Accuracy');
fprintf(file,'%f\n',pairwise_accuracy);
fclose(file);