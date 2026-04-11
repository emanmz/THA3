%% PA2: Hand-Eye Calibration Main Script with Verification
clear; clc;

% Load Data
[q_Rc, q_Cc, t_Rc, t_Cc] = data_quaternion();
[q_Rn, q_Cn, t_Rn, t_Cn] = data_quaternion_noisy(); 

% Solve Clean Data
[qX_c, tX_c] = solve_hand_eye_quaternion(q_Rc, t_Rc, q_Cc, t_Cc);
TX_c = [quat2rot(qX_c'), tX_c; 0 0 0 1];

%% --- VERIFICATION CHECK ---
fprintf('--- Verification Check (Residuals) ---\n');

num_poses = size(q_Rc, 1);
residuals = zeros(num_poses-1, 1);

for i = 1:num_poses-1
    % Convert [x y z w] -> [w x y z]
    qRi = [q_Rc(i,4), q_Rc(i,1:3)];
    qRj = [q_Rc(i+1,4), q_Rc(i+1,1:3)];
    qCi = [q_Cc(i,4), q_Cc(i,1:3)];
    qCj = [q_Cc(i+1,4), q_Cc(i+1,1:3)];

    % A motion
    RA = quat2rot(qRi)' * quat2rot(qRj);
    tA = quat2rot(qRi)' * (t_Rc(i+1,:) - t_Rc(i,:))';
    TA = [RA, tA; 0 0 0 1];
    
    % B motion
    RB = quat2rot(qCi) * quat2rot(qCj)';
    tB = t_Cc(i,:)' - RB * t_Cc(i+1,:)';
    TB = [RB, tB; 0 0 0 1];
    
    residuals(i) = norm(TA * TX_c - TX_c * TB, 'fro');
    fprintf('Relative Motion %d Residual: %.2e\n', i, residuals(i));
end

fprintf('Average Residual: %.2e\n\n', mean(residuals));


%% --- NOISE ANALYSIS ---
n_range = 3:10;
err_t_line = [];
err_q_line = [];

for n = n_range
    [qX_ni, tX_ni] = solve_hand_eye_quaternion( ...
        q_Rn(1:n,:), t_Rn(1:n,:), q_Cn(1:n,:), t_Cn(1:n,:));
    
    % Translation error
    err_t_line(end+1) = norm(tX_c - tX_ni);

    % Quaternion error (FIXED)
    dq = abs(dot(qX_c, qX_ni));
    dq = min(1, max(-1, dq)); % clamp
    err_q_line(end+1) = rad2deg(2 * acos(dq));
end

%% --- CUMULATIVE ERROR ---
raw_err_t = err_t_line;
raw_err_q = err_q_line;

cum_err_t = cumsum(raw_err_t);
cum_err_q = cumsum(raw_err_q);

%% --- PLOTS ---
figure('Name', 'Cumulative Hand-Eye Error');

subplot(2,1,1);
plot(n_range, cum_err_t, '-o', 'LineWidth', 2);
title('Cumulative Translation Error');
xlabel('Number of Poses');
ylabel('Error (m)');
grid on;

subplot(2,1,2);
plot(n_range, cum_err_q, '-s', 'LineWidth', 2);
title('Cumulative Rotation Error');
xlabel('Number of Poses');
ylabel('Error (deg)');
grid on;