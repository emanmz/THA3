function [RX, tX] = hand_eye_quat() % W11-L1 slide 10-12

% load data from data_quaternion
[qR, qC, tR, tC] = data_quaternion();
num_poses = size(qR, 1);

% matrices for rotation est
M = [];

% solve rotation using quats

for i = 1:num_poses-1
    % robot relative motion Ai
    [RA, tA] = get_relative_transform(qR(i,:), tR(i,:), qR(i+1,:), tR(i+1,:));
    qA = rot2quat(RA); 
    % camera relative motion Bi
    [RB, tB] = get_relative_transform(qC(i,:), tC(i,:), qC(i+1,:), tC(i+1,:));
    qB = rot2quat(RB);

    % K matrix
    K = left_quat_mat(qA) - right_quat_mat(qB);
    M = [M; K];
    
end 

% svd
[~,~,V] = svd(M);
qX = V(:,end);
qX = qX/norm(qX);
RX = quat2rot(qX');

% solve for translation
Amat = [];
Bmat = [];

for i = 1:num_poses-1
    [RA, tA] = get_relative_transform(qR(i,:), tR(i,:), qR(i+1,:), tR(i+1,:));
    [~, tB] = get_relative_transform(qC(i,:), tC(i,:), qC(i+1,:), tC(i+1,:));

    Amat = [Amat; (RA-eye(3))];
    Bmat = [Bmat; (RX * tB' - tA')];

    err = norm(RA*RX - RX*RB);
    fprintf('Residual error for pose %d: %e\n', i, err);
end 
tX = Amat\Bmat; % least squares

end 
hand_eye_quat();

%% the helper fucntions 

function [R_rel, t_rel] = get_relative_transform(q1, t1, q2, t2)
    % T_rel = T1^-1 * T2
    R1 = quat2rot(q1);
    R2 = quat2rot(q2);
    R_rel = R1' * R2;
    t_rel = R1' * (t2 - t1)';
    t_rel = t_rel';
end

function L = left_quat_mat(q)
    w = q(1); x = q(2); y = q(3); z = q(4);
    L = [w -x -y -z;
         x  w -z  y;
         y  z  w -x;
         z -y  x  w];
end

function R = right_quat_mat(q)
    w = q(1); x = q(2); y = q(3); z = q(4);
    R = [w -x -y -z;
         x  w  z -y;
         y -z  w  x;
         z  y -x  w];
end
function [R] = quat2rot(q)
% q is expected to be a 4-element vector [w, x, y, z]
q0 = q(1); q1 = q(2); q2 = q(3); q3 = q(4);

mag = sqrt(q0^2 + q1^2 + q2^2 + q3^2);
q0 = q0/mag; q1 = q1/mag; q2 = q2/mag; q3 = q3/mag;

% Rotation Matrix
R = [q0^2 + q1^2 - q2^2 - q3^2, 2*(q1*q2 - q0*q3),     2*(q0*q2 + q1*q3);
     2*(q1*q2 + q0*q3),         q0^2 - q1^2 + q2^2 - q3^2, 2*(q2*q3 - q0*q1);
     2*(q1*q3 - q0*q2),         2*(q0*q1 + q2*q3),         q0^2 - q1^2 - q2^2 + q3^2];
end

function q = rot2quat(R)
    % Calculate individual components
    q0 = 0.5 * sqrt(max(0, R(1,1) + R(2,2) + R(3,3) + 1));
    q1 = 0.5 * sgn(R(3,2) - R(2,3)) * sqrt(max(0, R(1,1) - R(2,2) - R(3,3) + 1));
    q2 = 0.5 * sgn(R(1,3) - R(3,1)) * sqrt(max(0, R(2,2) - R(3,3) - R(1,1) + 1));
    q3 = 0.5 * sgn(R(2,1) - R(1,2)) * sqrt(max(0, R(3,3) - R(1,1) - R(2,2) + 1));
    
    % Pack them into a single vector to be used by left_quat_mat
    q = [q0, q1, q2, q3]; 
end

function s = sgn(x)
if x >= 0 
    s = 1; 
else 
    s = -1;
end 
end 