addpath("HW3-PA1");
%% em pivot calibration
% all dataset letters
letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
% use first frame to define local probe coord compute gjand then translate
% to the relative midpoint 
% for each frame k compute transformation FG k and then use pivot cal
disp('------------EM PIVOT TEST ------------');
for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-debug-%s-empivot.txt \n', s);

    % file names
    empivot_file = sprintf('pa1-debug-%s-empivot.txt', s);

    % ND and d from calbody
    fid_o = fopen(empivot_file, 'r');
    header = fgetl(fid_o);
    params = sscanf(header, '%d, %d');
    NH = params(1); % Number of EM markers
    numFrames = params(2);% number of data frames of data

    allPoints = fscanf(fid_o, '%f, %f, %f', [3, NH*numFrames]);
    fclose(fid_o);
    H_frame1 = allPoints(:, 1:NH);
    H_local = H_frame1 - mean(H_frame1, 2); % Center the local model
    Rs = zeros(3, 3, numFrames);
    ps = zeros(3, numFrames);
    for j = 1:numFrames
        idx = (j-1)*NH + 1 : j*NH;
        G_curr = allPoints(:, idx);

        % need transformation from local to frame tracker pos
        [Rs(:,:,j), ps(:,j)] = point_registration(H_local, G_curr);
    end

    [bTip, bPost] = pivot_calibration(Rs, ps);


    fprintf('\nDataset: %s\n', s);
    fprintf('bTip (Local):  [%6.2f, %6.2f, %6.2f]\n', bTip);
    fprintf('bPost (World): [%6.2f, %6.2f, %6.2f]\n', bPost);

    % Calculate Residual (how much the tip "wobbled" during the pivot)
    residuals = zeros(numFrames, 1);
    for f = 1:numFrames
        tip_in_world = Rs(:,:,f) * bTip + ps(:,f);
        residuals(f) = norm(tip_in_world - bPost);
    end
    fprintf('Avg Residual:   %.4f mm\n', mean(residuals));
end

