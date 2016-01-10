% using k means to cluster all elements of feature vector of all instances 
% to k clusters and generate k intervals 
% then using the intervals to histogram every vectors to k dimensions
%   data(indata):
%              im:{}
%              aqi:
%          feature:{cell}
function [data xvalues]= hist_with_kmeans(indata,k)
data = [];
data.num = length(indata.im);
data.im = cell(data.num,1);
data.aqi = -ones(data.num,1);
data.feature = cell(data.num,1);
% get the number of all elements
elem = [];
for i = 1:data.num
    elem = [elem;data.feature{i}];
end
IDX = kmeans(elem,k);
xvalues = zeros(k+1,1);
xvalues(1) = min(elem(IDX == 1));
for  j = 1:k
    xvalues(k) = max(elem(IDX == j));
end
for ii =1:data.num
    data.feature{ii} = hist(data.feature{ii},xvalues);
end