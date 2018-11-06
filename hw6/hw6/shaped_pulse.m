%shaped pulse .. 
% findig out the number of sample points
% at t > 1.21  , the value of the filter goes below 0.01 . 
% this can be found out analytically or by prgromatically using the code below;

%% shaped_pulse_width: function description
function width = findWidth(tolerance)
 tolerance = 0.01;
 t = 0:0.001:2;
 p = exp(-pi*t.^2);
 plot(t,p);
 idx = lookup(p,tolerance);
 t(idx);
 limit = t(idx);
 disp(["p at  "  num2str(limit) " is " num2str(exp(-pi*width*limit))] )
width = idx;