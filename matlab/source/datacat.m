function odata = datacat(indata)
ll = length(indata);
% check indata
imnum = indata{1}.num;
f_v = zeros(ll,1);
for i = 1 : ll
    if imnum ~= indata{i}.num
        disp('The datasize in not match!');
        return;
    end
    f_v(i) = length(indata{i}.feature{1});
end
f_v_all = sum(f_v);

odata.num = imnum;
odata.aqi = zeros(1,imnum);
odata.im = cell(1,imnum);
odata.feature = cell(1,imnum);
for i = 1: imnum
    odata.feature{i} = zeros(1,f_v_all);
end
f_idx = 1;
for i = 1 : ll
    for j = 1:indata{i}.num
        if i == 1
            odata.im{j} = indata{1}.im{j};
            odata.aqi(j) = indata{1}.aqi(j);
        end
        odata.feature{j}(f_idx:sum(f_v(1:i))) = indata{i}.feature{j};
    end
    f_idx = sum(f_v(1:i)) + 1;
end