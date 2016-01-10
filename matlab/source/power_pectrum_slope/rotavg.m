% function to compute rotational average of (square) array
% 
% function f = rotavg(array)
%
% array can be of dimensions N x N, in which case f is of 
% dimension N. N should be even.
%

function f = rotavg(array)
[M, N] = size(array);
[X, Y] = meshgrid(-M/2:M/2-1,-N/2:N/2-1);
[~,rho] = cart2pol(X,Y);
rho = round(rho);
L = max(max(rho));
i = cell(L,1);
% drop the DC
for r = 1:L
    i{r} = find(rho == r);
end
f = zeros(L,1);
for r = 1:L
    f(r)= mean(array(i{r}));
end 

% [~, N] = size(array);
% [X, Y] = meshgrid(-N/2:N/2-1,-N/2:N/2-1);
% [~,rho] = cart2pol(X,Y);
% fprintf('initializing indices\n');
% rho = round(rho);
% i = cell(N/2+1,1);
% % drop the DC
% for r = 1:N/2+1
%     i{r} = find(rho == r);
% end
% fprintf('doing rotational average\n');
% f = zeros(N/2+1,1);
% for r=1:N/2+1
%     f(r)= mean(array(i{r}));
% end 