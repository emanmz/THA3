addpath("HW3-PA1");
%% 
% all dataset letters 
letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
% a - c is clean beautiful data 
% d - g is the noisy data so we have to deal with that

for i = 1:length(letters)
    s = letters{i};
    fprintf('\n Dataset: pa1-debug-%s \n', s);
    
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
%%
% for the unkown data 
letters = {'h', 'i', 'j', 'k'};
for i = 1:length(letters)
    s = letters{i};
    fprintf('\n Dataset: pa1-debug-%s \n', s);
    
    % file names
    calbody_file = sprintf('pa1-unknown-%s-calbody.txt', s);
    calreadings_file = sprintf('pa1-unknown-%s-calreadings.txt', s);
    
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
    
    % check error and output
    residual = norm(D - (R_D * d + p_D), 'fro');
    fprintf('Residual Error: %e\n', residual);
    fprintf('Translation Z: %.2f\n', p_D(3));
end