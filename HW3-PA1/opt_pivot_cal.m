%% optical tracker pivot cal
clear all;
% okay so the camera is moving that is the issue need to fix
% use value fB to transform the optical tracker beacon positions into EM
% tracker coordinates :P thats why it wasnt working 
letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
disp('------------OPT PIVOT TEST ------------');
for i = 1:length(letters)
    s = letters{i};

    % calbody  
    calbody_file = sprintf('pa1-debug-%s-calbody.txt', s);
    fid_b = fopen(calbody_file, 'r');
    params_b = sscanf(fgetl(fid_b), '%d, %d, %d');
    ND = params_b(1); 
    d_base_model = fscanf(fid_b, '%f, %f, %f', [3, ND]);
    fclose(fid_b);
    
    % opt pivot 
    optpivot_file = sprintf('pa1-debug-%s-optpivot.txt', s);
    % ND and d from calbody
    fid_o = fopen(optpivot_file, 'r');
    header = fgetl(fid_o);
    params = sscanf(header, '%d, %d, %d');
    ND_file = params(1);
    NH = params(2); % Number of EM markers
    numFrames = params(3);% number of data frames of data
    
    allPoints = fscanf(fid_o, '%f, %f, %f', [3, (ND_file + NH)*numFrames]);
    fclose(fid_o);

    H_frame1 = allPoints(:,ND+1: ND+NH);
    H_local = H_frame1 - mean(H_frame1, 2); % Center the local model

    Rs = zeros(3, 3, numFrames);
    ps = zeros(3, numFrames);

    for k = 1:numFrames
        idx = (k-1)*(ND+NH);
        D_curr = allPoints(:, idx +1 : idx + ND_file);
        H_curr = allPoints(:, idx + ND_file + 1 : idx + ND_file + NH);

        % need transformation from base to tracker
        [Rbase, pbase] = point_registration(d_base_model, D_curr);
        % probe to tracker
        [Rprobe, pprobe] = point_registration(H_local, H_curr);
        % probe to base 
        Rs(:,:,k) = Rbase' * Rprobe;
        ps(:,k) = Rbase' * (pprobe - pbase);
    end

    [bTip, bPost] = pivot_calibration(Rs, ps);


    fprintf('\nDataset: %s\n', s);
    fprintf('bTip (Local):  [%6.2f, %6.2f, %6.2f]\n', bTip);
    fprintf('bPost (World): [%6.2f, %6.2f, %6.2f] (Relative to Base) \n', bPost);

    % Calculate Residual (how much the tip "wobbled" during the pivot)
    residuals = zeros(numFrames, 1);
    for x = 1:numFrames
        tip_in_world = Rs(:,:,x) * bTip + ps(:,x);
        residuals(x) = norm(tip_in_world - bPost);
    end
    fprintf('Avg Residual:   %.4f mm\n', mean(residuals));
end