function [RX, tX] = hand_eye_quat_comparison()
%% Selection
% Change to 'false' to run with only 5 sets for Part B of your assignment
use_full_dataset = true;

% noisy data
[qR, qC, tR, tC] = data_quaternion_noisy();


if ~use_full_dataset
    qR = qR(1:5, :); qC = qC(1:5, :);
    tR = tR(1:5, :); tC = tC(1:5, :);
    fprintf('--- HALF dataset (5 poses) ---\n');
else
    fprintf('--- FULL dataset (10 poses) ---\n');
end

num_poses = size(qR, 1);
M = [];

%% Rotation (qX)
for i = 1:num_poses-1
    [RA, ~] = get_relative_transform(qR(i,:), tR(i,:), qR(i+1,:), tR(i+1,:));
    [RB, ~] = get_relative_transform(qC(i,:), tC(i,:), qC(i+1,:), tC(i+1,:));

    qA = rot2quat(RA);
    qB = rot2quat(RB);

    % Stack the K matrices
    K = left_quat_mat(qA) - right_quat_mat(qB);
    M = [M; K];
end

[~,~,V] = svd(M);
qX = V(:,end);
qX = qX/norm(qX);
RX = quat2rot(qX');

%% Translation (tX)
Amat = [];
Bmat = [];
fprintf('\nResidual Errors (Rotational Consistency):\n');
for i = 1:num_poses-1
    [RA, tA] = get_relative_transform(qR(i,:), tR(i,:), qR(i+1,:), tR(i+1,:));
    [RB, tB] = get_relative_transform(qC(i,:), tC(i,:), qC(i+1,:), tC(i+1,:));

    Amat = [Amat; (RA - eye(3))];
    Bmat = [Bmat; (RX * tB' - tA')];

    % Check how well RA*RX = RX*RB
    err = norm(RA*RX - RX*RB);
    fprintf('Pose Pair %d to %d: %e\n', i, i+1, err);
end

tX = Amat \ Bmat; % Least squares solution

%% display
fprintf('\n--- Final Hand-Eye Transformation (X) ---\n');
disp('Rotation Matrix (RX):');
disp(RX);
disp('Translation Vector (tX):');
disp(tX);
end
hand_eye_quat_comparison()
%% Functions

function [R_rel, t_rel] = get_relative_transform(q1, t1, q2, t2)
R1 = quat2rot(q1);
R2 = quat2rot(q2);
R_rel = R1' * R2;
t_rel = (R1' * (t2 - t1)')';
end

function L = left_quat_mat(q)
w = q(1); x = q(2); y = q(3); z = q(4);
L = [w -x -y -z; x w -z y; y z w -x; z -y x w];
end

function R = right_quat_mat(q)
w = q(1); x = q(2); y = q(3); z = q(4);
R = [w -x -y -z; x w z -y; y -z w x; z y -x w];
end

function [R] = quat2rot(q)
q = q / norm(q);
q0 = q(1); q1 = q(2); q2 = q(3); q3 = q(4);
R = [q0^2 + q1^2 - q2^2 - q3^2, 2*(q1*q2 - q0*q3),     2*(q0*q2 + q1*q3);
    2*(q1*q2 + q0*q3),         q0^2 - q1^2 + q2^2 - q3^2, 2*(q2*q3 - q0*q1);
    2*(q1*q3 - q0*q2),         2*(q0*q1 + q2*q3),         q0^2 - q1^2 - q2^2 + q3^2];
end

function q = rot2quat(R)
q0 = 0.5 * sqrt(max(0, R(1,1) + R(2,2) + R(3,3) + 1));
q1 = 0.5 * sgn(R(3,2) - R(2,3)) * sqrt(max(0, R(1,1) - R(2,2) - R(3,3) + 1));
q2 = 0.5 * sgn(R(1,3) - R(3,1)) * sqrt(max(0, R(2,2) - R(3,3) - R(1,1) + 1));
q3 = 0.5 * sgn(R(2,1) - R(1,2)) * sqrt(max(0, R(3,3) - R(1,1) - R(2,2) + 1));
q = [q0, q1, q2, q3];
end

function s = sgn(x)
s = (x >= 0) * 2 - 1;
end