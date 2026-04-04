addpath("HW3-PA1");
%%
% all dataset letters
letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};
% a - c is clean beautiful data
% d - g is the noisy data so we have to deal with that
disp('------------EM PIVOT TEST ------------');
for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-debug-%s \n', s);

    % file names
    empivot_file = sprintf('pa1-debug-%s-empivot.txt', s);

    % ND and d from calbody
    fid = fopen(empivot_file, 'r');
    header = fgetl(fid);
    params = sscanf(header, '%d, %d');
    NG = params(1); % Number of EM markers
    numFrames = params(2);% number of data frames of data

    allPoints = fscanf(fid, '%f, %f, %f', [3, NG*numFrames]);
    fclose(fid);
    G_frame1 = allPoints(:, 1:NG);
    G_local = G_frame1 - mean(G_frame1, 2); % Center the local model
    Rs = zeros(3, 3, numFrames);
    ps = zeros(3, numFrames);
    for i = 1:numFrames
        idx = (i-1)*NG + 1 : i*NG;
        G_curr = allPoints(:, idx);

        % need transformation from local to frame tracker pos
        [Rs(:,:,i), ps(:,i)] = point_registration(G_local, G_curr);
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

disp('------------OPT PIVOT TEST ------------');
for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-debug-%s \n', s);

    % file names
    optpivot_file = sprintf('pa1-debug-%s-optpivot.txt', s);

    % ND and d from calbody
    fid = fopen(optpivot_file, 'r');
    header = fgetl(fid);
    params = sscanf(header, '%d, %d');
    NG = params(1); % Number of EM markers
    numFrames = params(2);% number of data frames of data

    allPoints = fscanf(fid, '%f, %f, %f', [3, NG*numFrames]);
    fclose(fid);
    G_frame1 = allPoints(:, 1:NG);
    G_local = G_frame1 - mean(G_frame1, 2); % Center the local model
    Rs = zeros(3, 3, numFrames);
    ps = zeros(3, numFrames);
    for i = 1:numFrames
        idx = (i-1)*NG + 1 : i*NG;
        G_curr = allPoints(:, idx);

        % need transformation from local to frame tracker pos
        [Rs(:,:,i), ps(:,i)] = point_registration(G_local, G_curr);
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