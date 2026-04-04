function [bTip, bPost] = pivot_calibration(R, p) %W9-L2 Slide 9-11
% R = N x 3 rotational transformation between tracker and tool trackers
% p = N x 1 translational transformation between tracker and tool trackers

numFrames = size(R, 3);
A = zeros(3 * numFrames, 6);
B = zeros(3 * numFrames, 1);
for i = 1:numFrames
    Ri = R(:,:,i);
    p_i = p(:,i);

    % Row indices for current frame
    rows = (3*i-2):(3*i);

    A(rows, :) = [Ri, -eye(3)];
    B(rows) = -p_i;

end
% least squares operator
X = A \ B;

bTip = X(1:3,:);
bPost = X(4:6,:);

end

