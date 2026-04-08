%% Simple Test Case 
close all; clear all;
    % A: source points (3 x N)
    % B: target points (3 x N)
    % square thats translated 2 in x then rotated 90deg about z

    A = [ 0 0 2 2;
         0 2 2 0;
         0 0 0 0];

    B = [0 -2 -2 0;
         2 2 4 4;
         0 0 0 0];

    [R, p] = point_registration(A,B);

Bfunc =[];
  for i = 1:size(A,2)
      bi = R*A(:,i)+p;
      Bfunc = [Bfunc, bi];
      
  end
  disp('Bfunc')
  disp(Bfunc)
  disp('B')
  disp(B)

%% Test Case from Gemini: Point Registration Test Script
addpath("HW3-PA1");
% 1. Setup Ground Truth Transformation
R_true = expm(skewSym(rand(3,1))); % Random valid rotation matrix
p_true = rand(3, 1) * 10;          % Random translation vector

% 2. Generate Source Points (3 x N)
N = 10;
A = rand(3, N) * 5;

% --- CASE 1: NO NOISE ---
% Generate target points using ground truth
B_clean = R_true * A + p_true;

% Run registration
[R_res1, p_res1] = point_registration(A, B_clean);

% --- CASE 2: WITH NOISE ---
% Add Gaussian noise to target points
noise_level = 0.05;
B_noisy = B_clean + noise_level * randn(3, N);

% Run registration
[R_res2, p_res2] = point_registration(A, B_noisy);

%% Display Results
fprintf('--- Ground Truth ---\n');
disp('R_true:'), disp(R_true);
disp('p_true:'), disp(p_true);

fprintf('\n--- Results: NO NOISE ---\n');
fprintf('Rotation Error (F-norm): %e\n', norm(R_true - R_res1, 'fro'));
fprintf('Translation Error: %e\n', norm(p_true - p_res1));

fprintf('\n--- Results: WITH NOISE (std = %.2f) ---\n', noise_level);
fprintf('Rotation Error (F-norm): %e\n', norm(R_true - R_res2, 'fro'));
fprintf('Translation Error: %e\n', norm(p_true - p_res2));
