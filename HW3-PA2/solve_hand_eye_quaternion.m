function [X_quat, X_t] = solve_hand_eye_quaternion(q_R, t_R, q_C, t_C) %W9-L2 Slide 17-22

    num_poses = size(q_R, 1);
    n = num_poses - 1;
    M = zeros(4*n, 4); 
    
    rel_R_A = zeros(3, 3, n);
    rel_t_A = zeros(3, n);
    rel_t_B = zeros(3, n);

    for i = 1:n
        % Convert [x y z w] -> [w x y z]
        qRi = [q_R(i,4), q_R(i,1:3)];
        qRj = [q_R(i+1,4), q_R(i+1,1:3)];
        qCi = [q_C(i,4), q_C(i,1:3)];
        qCj = [q_C(i+1,4), q_C(i+1,1:3)];

        % Rotation matrices
        R_i = quat2rot(qRi);
        R_j = quat2rot(qRj);

        % A motion
        rel_R_A(:,:,i) = R_i' * R_j;
        rel_t_A(:,i) = R_i' * (t_R(i+1,:) - t_R(i,:))';
        
        % B motion
        S_i = quat2rot(qCi);
        S_j = quat2rot(qCj);

        rel_R_B = S_i * S_j';
        rel_t_B(:,i) = t_C(i,:)' - rel_R_B * t_C(i+1,:)';
                
        % Convert to quaternions
        qA = rot2quat(rel_R_A(:,:,i));
        qB = rot2quat(rel_R_B);
        
        % Quaternion matrices
        L_qA = [qA(1), -qA(2:4);
                qA(2:4)', qA(1)*eye(3) + skew(qA(2:4))];

        R_qB = [qB(1), -qB(2:4);
                qB(2:4)', qB(1)*eye(3) - skew(qB(2:4))];
        
        M(4*(i-1)+1 : 4*i, :) = L_qA - R_qB;
    end
    
    % Solve rotation
    [~, ~, V] = svd(M);
    X_quat = V(:, end);

    % Normalize quaternion
    X_quat = X_quat / norm(X_quat);

    % Ensure consistent sign 
    if X_quat(1) < 0
        X_quat = -X_quat;
    end

    % Rotation matrix
    R_X = quat2rot(X_quat');

    % Solve translation
    K = [];
    Y = [];

    for i = 1:n
        K = [K; rel_R_A(:,:,i) - eye(3)];
        Y = [Y; R_X * rel_t_B(:,i) - rel_t_A(:,i)];
    end

    X_t = K \ Y;
end

function s = skew(v)
    s = [0 -v(3) v(2);
         v(3) 0 -v(1);
        -v(2) v(1) 0];
end