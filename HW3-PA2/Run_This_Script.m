%% PA2
clear; clc;

[q_Rc, q_Cc, t_Rc, t_Cc] = data_quaternion();
[q_Rn, q_Cn, t_Rn, t_Cn] = data_quaternion_noisy(); 

%% ================= CLEAN DATA (10 POSES) =================
[qX_c, tX_c] = solve_hand_eye_quaternion(q_Rc, t_Rc, q_Cc, t_Cc);
TX_c = [quat2rot(qX_c'), tX_c; 0 0 0 1];

fprintf('================ CLEAN DATA (10 POSES) ================\n');
disp(TX_c);
fprintf('Translation: [%.4f %.4f %.4f] m\n\n', tX_c);

%% ================= CLEAN DATA (5 POSES) =================
[qX_c5, tX_c5] = solve_hand_eye_quaternion( ...
    q_Rc(1:5,:), t_Rc(1:5,:), q_Cc(1:5,:), t_Cc(1:5,:));
TX_c5 = [quat2rot(qX_c5'), tX_c5; 0 0 0 1];

fprintf('================ CLEAN DATA (5 POSES) ================\n');
disp(TX_c5);
fprintf('Translation: [%.4f %.4f %.4f] m\n\n', tX_c5);

%% ================= NOISY DATA (10 POSES) =================
[qX_n, tX_n] = solve_hand_eye_quaternion(q_Rn, t_Rn, q_Cn, t_Cn);
TX_n = [quat2rot(qX_n'), tX_n; 0 0 0 1];

fprintf('================ NOISY DATA (10 POSES) ================\n');
disp(TX_n);
fprintf('Translation: [%.4f %.4f %.4f] m\n\n', tX_n);

%% ================= NOISY DATA (5 POSES) =================
[qX_n5, tX_n5] = solve_hand_eye_quaternion( ...
    q_Rn(1:5,:), t_Rn(1:5,:), q_Cn(1:5,:), t_Cn(1:5,:));
TX_n5 = [quat2rot(qX_n5'), tX_n5; 0 0 0 1];

fprintf('================ NOISY DATA (5 POSES) ================\n');
disp(TX_n5);
fprintf('Translation: [%.4f %.4f %.4f] m\n\n', tX_n5);

%% ================= ERROR COMPARISON =================
fprintf('================ ERROR COMPARISON =================\n');

% --- Translation Errors ---
err_t_n10 = norm(tX_c - tX_n);
err_t_n5  = norm(tX_c - tX_n5);
err_t_c5  = norm(tX_c - tX_c5);

% --- Rotation Errors ---
rot_err = @(q1,q2) rad2deg(2 * acos(min(1,max(-1,abs(dot(q1,q2))))));

err_q_n10 = rot_err(qX_c, qX_n);
err_q_n5  = rot_err(qX_c, qX_n5);
err_q_c5  = rot_err(qX_c, qX_c5);

fprintf('Clean (5 vs 10) Error:     %.4f m, %.4f deg\n', err_t_c5, err_q_c5);
fprintf('Noisy (10 vs Clean):      %.4f m, %.4f deg\n', err_t_n10, err_q_n10);
fprintf('Noisy (5 vs Clean):       %.4f m, %.4f deg\n\n', err_t_n5, err_q_n5);

%% ================= GEOMETRIC CONSISTENCY (CLEAN) =================
fprintf('Geometric Consistency Check (Clean Data)\n');
num_poses = size(q_Rc, 1);
residuals = zeros(num_poses-1, 1);

for i = 1:num_poses-1
    qRi = [q_Rc(i,4), q_Rc(i,1:3)]; qRj = [q_Rc(i+1,4), q_Rc(i+1,1:3)];
    qCi = [q_Cc(i,4), q_Cc(i,1:3)]; qCj = [q_Cc(i+1,4), q_Cc(i+1,1:3)];
    
    RA = quat2rot(qRi)' * quat2rot(qRj);
    tA = quat2rot(qRi)' * (t_Rc(i+1,:) - t_Rc(i,:))';
    TA = [RA, tA; 0 0 0 1];
    
    RB = quat2rot(qCi) * quat2rot(qCj)';
    tB = t_Cc(i,:)' - RB * t_Cc(i+1,:)';
    TB = [RB, tB; 0 0 0 1];
    
    residuals(i) = norm(TA * TX_c - TX_c * TB, 'fro');
    fprintf('Pair %d->%d Residual: %.2e\n', i, i+1, residuals(i));
end
fprintf('Average Residual: %.2e\n\n', mean(residuals));

%% ================= CONVERGENCE ANALYSIS (NOISY) =================
fprintf('Noise Convergence Analysis\n');

n_range = 3:10;
err_t_line = [];
err_q_line = [];

for n = n_range
    [qX_ni, tX_ni] = solve_hand_eye_quaternion( ...
        q_Rn(1:n,:), t_Rn(1:n,:), q_Cn(1:n,:), t_Cn(1:n,:));
    
    err_t_line(end+1) = norm(tX_c - tX_ni);
    
    dq = abs(dot(qX_c, qX_ni));
    dq = min(1, max(-1, dq));
    err_q_line(end+1) = rad2deg(2 * acos(dq));
end

%% ================= PLOTS =================
figure('Name', 'Hand-Eye Calibration Analysis', 'Color', 'w');

subplot(2,1,1);
plot(n_range, err_t_line, '-ob', 'LineWidth', 2, 'MarkerFaceColor', 'b');
title('Translation Error vs Number of Poses');
ylabel('Error (m)');
xlabel('Number of Poses');
grid on;

subplot(2,1,2);
plot(n_range, err_q_line, '-sr', 'LineWidth', 2, 'MarkerFaceColor', 'r');
title('Rotation Error vs Number of Poses');
ylabel('Error (deg)');
xlabel('Number of Poses');
grid on;