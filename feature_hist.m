% using k means to cluster all elements of feature vector of all instances 
% to k clusters and generate k intervals 
% then using the intervals to histogram every vectors to k dimensions
% input :
%    data(indata):
%              im:{cell}
%              aqi:
%          feature:{cell}
function data = feature_hist(indata,interval)
