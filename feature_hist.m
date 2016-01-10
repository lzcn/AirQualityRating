% using k means to cluster all elements of feature vector of all instances 
% to k clusters and generate k intervals 
% then using the intervals to histogram every vectors to k dimensions
% input :
%    data(indata):
%              im:{cell}
%              aqi:
%          feature:{cell}
function data = feature_hist(indata,interval)
data = [];
data.num = length(indata.im);
data.im = indata.im;
data.aqi = indata.aqi;
data.feature = cell(data.num,1);
for i = 1:data.num
    data.feature{i} = hist(indata.feature{i},interval);
end