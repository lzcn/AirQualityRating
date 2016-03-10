function class = label2class(label)
class = floor(label/50) + 1;
if class >= 6
    class = 6;
end