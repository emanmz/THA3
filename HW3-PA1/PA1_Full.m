%% SET UP
% this file is basically everything step by step in case we need to
% actually fix the distrotion?
addpath("HW3-PA1");
clear; clc;

%% Uncomment the dataset you want to test
letters = {'a','b','c','d','e','f','g'}; % debug
% letters = {'h','i','j','k'}; % unknown

for i = 1:length(letters)
    s = letters{i};

    fprintf('\n================ %s ================\n', s);

    % Prefix
    if any(strcmp(s, {'a','b','c','d','e','f','g'}))
        prefix = 'pa1-debug';
        isDebug = true;
    else
        prefix = 'pa1-unknown';
        isDebug = false;
    end


    %% READ CALBODY

    calbody_file = sprintf('%s-%s-calbody.txt', prefix, s);
    fid = fopen(calbody_file,'r');

    % extract number of markers on each body
    params = sscanf(fgetl(fid),'%d, %d, %d');
    ND = params(1); NA = params(2); NC = params(3);

    % extract coordinates of di, ai, and ci representing the markers on
    % each body
    d = fscanf(fid,'%f, %f, %f',[3,ND]);
    a = fscanf(fid,'%f, %f, %f',[3,NA]);
    c = fscanf(fid,'%f, %f, %f',[3,NC]);
    fclose(fid);

    %% CALREADINGS → C_expected pt 3

    calreadings_file = sprintf('%s-%s-calreadings.txt', prefix, s);
    fid = fopen(calreadings_file,'r');

    params = sscanf(fgetl(fid),'%d, %d, %d, %d');
    numFrames = params(4);

    C_expected = zeros(3, NC, numFrames);

    for f = 1:numFrames
        D = fscanf(fid,'%f, %f, %f',[3,ND]);
        A = fscanf(fid,'%f, %f, %f',[3,NA]);
        fscanf(fid,'%f, %f, %f',[3,NC]); % C (unused)

        [Rd, pd] = point_registration(d, D);
        FD = [Rd, pd; 0 0 0 1];

        [Ra, pa] = point_registration(a, A);
        FA = [Ra, pa; 0 0 0 1];

        c_h = [c; ones(1,NC)];
        C_exp = (FD \ FA) * c_h;

        C_expected(:,:,f) = C_exp(1:3,:);
    end
    fclose(fid);

    %% EM PIVOT pt. 4

    empivot_file = sprintf('%s-%s-empivot.txt', prefix, s);
    fid = fopen(empivot_file,'r');

    params = sscanf(fgetl(fid),'%d, %d');
    NG = params(1); numFrames_em = params(2);

    data = fscanf(fid,'%f, %f, %f',[3, NG*numFrames_em]);
    fclose(fid);

    G_local = data(:,1:NG);
    G0 = mean(G_local,2);
    g = G_local - G0;

    Rs = zeros(3,3,numFrames_em);
    ps = zeros(3,numFrames_em);

    for k = 1:numFrames_em
        idx = (k-1)*NG+1 : k*NG;
        G = data(:,idx);

        [R,p] = point_registration(g, G);
        Rs(:,:,k) = R;
        ps(:,k) = p;
    end

    [~, bPost_em] = pivot_calibration(Rs, ps);

    %% OPTICAL PIVOT pt. 5

    optpivot_file = sprintf('%s-%s-optpivot.txt', prefix, s);
    fid = fopen(optpivot_file,'r');

    params = sscanf(fgetl(fid),'%d, %d, %d');
    ND = params(1); NH = params(2);
    numFrames_op = params(3);

    data = fscanf(fid,'%f, %f, %f',[3, (ND+NH)*numFrames_op]);
    fclose(fid);

    H0 = data(:,ND+1:ND+NH);
    H_local = H0 - mean(H0,2);

    Rs = zeros(3,3,numFrames_op);
    ps = zeros(3,numFrames_op);

    for k = 1:numFrames_op
        idx = (k-1)*(ND+NH);

        D = data(:,idx+1:idx+ND);
        H = data(:,idx+ND+1:idx+ND+NH);

        [Rbase,pbase] = point_registration(d,D);
        [Rprobe,pprobe] = point_registration(H_local,H);

        Rs(:,:,k) = Rbase' * Rprobe;
        ps(:,k)   = Rbase' * (pprobe - pbase);
    end

    [~, bPost_opt] = pivot_calibration(Rs, ps);

    %% output check !! change this f=to compare our output file to the output file given for debug only

    if isDebug
        aux_file = sprintf('%s-%s-auxilliary1.txt', prefix, s);

        if exist(aux_file, 'file')
            fprintf('\n------ AUX CHECK ------\n');

            txt = fileread(aux_file);

            em_actual = parse_triplet(txt, 'EM pivot post actual position ='); % check later
            em_est = parse_triplet(txt, 'EM pivot post est    position =');
            opt_actual = parse_triplet(txt, 'Optical pivot post actual position =');
            opt_est = parse_triplet(txt, 'Optical pivot post est    position =');

            if ~isempty(em_actual) % maybe add an output file check? to check that C_expected is the same
                fprintf('EM Actual: [%8.4f %8.4f %8.4f]\n', em_actual);
                fprintf('EM Estimated:   [%8.4f %8.4f %8.4f]\n', em_est);
                fprintf('EM Calculated:   [%8.4f %8.4f %8.4f]\n', bPost_em);
                fprintf('EM error (Calc- Act):  %.6f mm\n', norm(bPost_em - em_actual)); % need to fix this !!!!
                disp(bPost_em - em_actual);
                fprintf('EM error (Calc- Est):  %.6f mm\n', norm(bPost_em - em_est));
                disp(bPost_em - em_est);
            end

            if ~isempty(opt_actual)
                fprintf('OPT Actual: [%8.4f %8.4f %8.4f]\n', opt_actual);
                fprintf('OPT Estimated: [%8.4f %8.4f %8.4f]\n', opt_est);
                fprintf('OPT Calculated:   [%8.4f %8.4f %8.4f]\n', bPost_opt);
                fprintf('OPT error (Calc- Act):  %.6f mm\n', norm(bPost_opt - opt_actual));
                fprintf('OPT error (Calc- Est):  %.6f mm\n', norm(bPost_opt - opt_est));
            end
        end
    else
        fprintf('EM ours:   [%8.4f %8.4f %8.4f]\n', bPost_em);
        fprintf('OPT ours:   [%8.4f %8.4f %8.4f]\n', bPost_opt);
    end

    %% OUTPUT FILE

    % Saving to an output file :P (pt 3.d?)
    % folder exists
    output_folder = 'Output_Files';

    % 2. Setup file paths
    filename = sprintf('%s-%s-output1.txt', prefix, s);
    output_path = fullfile(output_folder, filename);

    fid = fopen(output_path, 'w');

    fprintf(fid, '%d, %d, %s\n', NC, numFrames, filename);
    fprintf(fid, '  %.2f,   %.2f,   %.2f\n', bPost_em(1), bPost_em(2), bPost_em(3));
    fprintf(fid, '  %.2f,   %.2f,   %.2f\n', bPost_opt(1), bPost_opt(2), bPost_opt(3));
    for f = 1:numFrames
        for j = 1:NC
            % Access all 3 coordinates (row, column, page)
            fprintf(fid, '  %.2f,   %.2f,   %.2f\n', ...
                C_expected(1, j, f), ...
                C_expected(2, j, f), ...
                C_expected(3, j, f));
        end
    end

    fclose(fid);
    fprintf('Done processing dataset: %s (Saved to %s)\n', s, output_path);

    if isDebug
        our_file = fullfile("Output_Files", sprintf('%s-%s-output1.txt', prefix, s));
        sol_file = fullfile("HW3-PA1", sprintf('%s-%s-output1.txt', prefix, s));
        if exist(sol_file, 'file') && exist(our_file, 'file')

            fprintf('------ Comparing OUR vs SOLUTION: %s ------\n', s);

            fid_our = fopen(our_file, 'r');
            fid_sol = fopen(sol_file, 'r');

            % Skip headers
            fgetl(fid_our);
            fgetl(fid_sol);

            % Read pivot tips
            our_em  = sscanf(fgetl(fid_our), '%f, %f, %f');
            our_opt = sscanf(fgetl(fid_our), '%f, %f, %f');

            sol_em  = sscanf(fgetl(fid_sol), '%f, %f, %f');
            sol_opt = sscanf(fgetl(fid_sol), '%f, %f, %f');

            fprintf('EM Tip Error:  %.6f mm\n', norm(our_em - sol_em));
            fprintf('Opt Tip Error: %.6f mm\n', norm(our_opt - sol_opt));

            % Compare all C_expected points
            max_err = 0;

            for f = 1:numFrames
                for j = 1:NC
                    our_c = sscanf(fgetl(fid_our), '%f, %f, %f');
                    sol_c = sscanf(fgetl(fid_sol), '%f, %f, %f');

                    err = norm(our_c - sol_c);
                    if err > max_err
                        max_err = err;
                    end
                end
            end

            fprintf('Max C_expected Error: %.6f mm\n', max_err);
            fclose(fid_our);
            fclose(fid_sol);
        else
            fprintf(' files  r missing.\n');
        end
    end
end


%% HELPER

function v = parse_triplet(txt, label)
expr = [regexptranslate('escape', label), '\s*([-\d\.]+),\s*([-\d\.]+),\s*([-\d\.]+)'];
tokens = regexp(txt, expr, 'tokens', 'once');

if isempty(tokens)
    v = [];
else
    v = [str2double(tokens{1});
        str2double(tokens{2});
        str2double(tokens{3})];
end
end