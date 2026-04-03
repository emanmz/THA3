function [bTip, bPost] = pivot_calibration(R, p) %W9-L2 Slide 9-11
% R = N x 3 rotational transformation between tracker and tool trackers
% p = N x 1 translational transformation between tracker and tool trackers
% we could also input F pointer and just extract the components...

A = [];
for %do some indexing here to call every 3x3 of R
    Ai = Ri*eye(3);
    A = [A; Ai]; %stack all the A matrices
end

B = -p;
x = A/B;
bTip = X(1:3,:);
bPost = X(4:6,:);

end 

%def need to check that this works but i dont know how