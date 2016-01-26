% using k means to cluster all elements of feature vector of all instances 
% to k clusters and generate k intervals 
% then using the intervals to histogram every vectors to k dimensions
% input :
%    data(indata):
%              im:{cell}
%              aqi:
%          feature:{cell}
%    k : k clusters
% output : the interval for histogram
function interval = interval_for_hist(indata,k)
data = [];
data.num = length(indata.path);
data.path = cell(data.num,1);
data.aqi = -ones(data.num,1);
data.calss = -ones(data.num,1);
data.feature = cell(data.num,1);
% write all emelemt of features to a vector
elem = [];
for i = 1:data.num
    len_feature = length(indata.feature{i});
    sample_num = round(0.025*len_feature);
    p = randperm(len_feature);
    elem = [elem;indata.feature{i}(p(1:sample_num))];
end

IDX = kmeans(elem,k);
xvalues = zeros(2*k,1);
for  j = 1:k
    xvalues(2*j-1) = min(elem(find(IDX == j)));
    xvalues(2*j) = max(elem(find(IDX == j)));
end
xvalues = sort(xvalues);
% generate the interval
interval = zeros(k+1,1);
interval(1) = xvalues(1);
for ii =1:k
    interval(ii+1) = xvalues(2*ii);
end