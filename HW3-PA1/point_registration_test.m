addpath("HW3-PA1");
%% Test Case from Gemini: Point Registration Test Script

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

% Display Results
fprintf('--- Ground Truth ---\n');
disp('R_true:'), disp(R_true);
disp('p_true:'), disp(p_true);

fprintf('\n--- Results: NO NOISE ---\n');
fprintf('Rotation Error (F-norm): %e\n', norm(R_true - R_res1, 'fro'));
fprintf('Translation Error: %e\n', norm(p_true - p_res1));

fprintf('\n--- Results: WITH NOISE (std = %.2f) ---\n', noise_level);
fprintf('Rotation Error (F-norm): %e\n', norm(R_true - R_res2, 'fro'));
fprintf('Translation Error: %e\n', norm(p_true - p_res2));


%% Test Case with Clean Assignment Data 
% all dataset letters 
letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
% a - c is clean beautiful data 
% d - g is the noisy data so we have to deal with that

for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-debug-%s \n', s);
    
    % file names
    calbody_file = sprintf('pa1-debug-%s-calbody.txt', s);
    calreadings_file = sprintf('pa1-debug-%s-calreadings.txt', s);
    
    % ND and d from calbody
    fid_b = fopen(calbody_file, 'r');
    header_b = fgetl(fid_b);
    params_b = sscanf(header_b, '%d, %d, %d');
    ND = params_b(1); % Number of markers on the EM base
    d = fscanf(fid_b, '%f, %f, %f', [3, ND]);
    fclose(fid_b);
    
    % Frame 1 measured points (D) from calreadings
    fid_r = fopen(calreadings_file, 'r');
    fgetl(fid_r); % Skip header
    D = fscanf(fid_r, '%f, %f, %f', [3, ND]); % Read first ND points for Frame 1
    fclose(fid_r);
    
    % Point Registration 
    [R_D, p_D] = point_registration(d, D);
    
    % Verify and Output
    residual = norm(D - (R_D * d + p_D), 'fro');
    fprintf('Residual Error: %e\n', residual);
    fprintf('Translation Z: %.2f\n', p_D(3));
end
%% Test Case with Noisy Assignment Data
% for the unkown data 
letters = {'h', 'i', 'j', 'k'};
for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-debug-%s \n', s);
    
    % file names
    calbody_file = sprintf('pa1-unknown-%s-calbody.txt', s);
    calreadings_file = sprintf('pa1-unknown-%s-calreadings.txt', s);
    
    % ND and d from calbody
    fid_b = fopen(calbody_file, 'r');
    header_b = fgetl(fid_b);
    params_b = sscanf(header_b, '%d, %d, %d'); % ND,NA,NC
    ND = params_b(1); % Number of markers on the EM base
    d = fscanf(fid_b, '%f, %f, %f', [3, ND]);
    fclose(fid_b);
    
    % Frame 1 measured points (D) from calreadings
    fid_r = fopen(calreadings_file, 'r');
    fgetl(fid_r); % Skip header
    D = fscanf(fid_r, '%f, %f, %f', [3, ND]); % ND,NA,NC,Nframes
    fclose(fid_r);
    
    % Point Registration 
    [R_D, p_D] = point_registration(d, D);
    
    % check error and output
    residual = norm(D - (R_D * d + p_D), 'fro');
    fprintf('Residual Error: %e\n', residual);
    fprintf('Translation Z: %.2f\n', p_D(3));
end