function y = sem(x)
y = std(x) / sqrt(size(x,2));
end