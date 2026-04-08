addpath("HW3-PA1");

letters = {'h', 'i', 'j', 'k'};
%letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};

for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-unknown-%s \n', s);

    % file names
    calbody_file = sprintf('pa1-unknown-%s-calbody.txt', s);
    fid_b = fopen(calbody_file, 'r');
    header_b = fgetl(fid_b);
    params_b = sscanf(header_b, '%d, %d, %d'); % ND,NA,NC
    ND = params_b(1); % Number of markers on the EM base
    NA = params_b(2); % number of optical markers on cal obj
    NC = params_b(3); % number EM markers on cal obj

    d = fscanf(fid_b, '%f, %f, %f', [3, ND]);
    a = fscanf(fid_b, '%f, %f, %f', [3, NA]);
    c = fscanf(fid_b, '%f, %f, %f', [3, NC]);
    fclose(fid_b);

    % Frame 1 measured points (D) from calreadings
    calreadings_file = sprintf('pa1-unknown-%s-calreadings.txt', s);
    fid_r = fopen(calreadings_file, 'r');
    % ND,NA,NC,Nframes,NAMECALREADINGS.TXT
    header_r = fgetl(fid_r);
    params_r = sscanf(header_r, '%d, %d, %d, %d'); % ND,NA,NC,Nframes
    numFrames = params_r(4);
    D = params_r(1);
    A = params_r(2);
    C = params_r(3);

    C_expected = zeros(3, NC, numFrames); % allocate before

    for b = 1:numFrames

        % go through the readings file and grab the date for every frame
        % need to use fscans
        D_read = fscanf(fid_r, '%f, %f, %f', [3,ND]); % Read ND points
        A_read = fscanf(fid_r, '%f, %f, %f', [3,NA]); % Read NA points
        C_read = fscanf(fid_r, '%f, %f, %f', [3,NC]); % Read NC points

        % FD
        [Rd, pd] = point_registration(d, D_read);
        FD = [Rd pd; 0 0 0 1];

        % FA
        [Ra, pa] = point_registration(a, A_read);
        FA = [Ra pa; 0 0 0 1];

        % convert c to 4x1
        c_4by4 = [c; ones(1, NC)];
        C_ex_4by4 = (FD \ FA) * c_4by4; %C expected 4x1

        % C expected 3x1
        C_expected(:,:,b) = C_ex_4by4(1:3,:);

        % 3. Calculate RMSE for THIS frame only
        % Make sure C_read is also relative to the base if that's what the assignment asks!
        % If C_read is in Tracker coords, then C_expected should just be FA * c_homog.
        %this is from gemini btw
        distortion_per_marker = sqrt(sum((C_read - C_expected(:,:,b)).^2, 1));
        mean_distortion = mean(distortion_per_marker);

        fprintf('Frame %d Average EM Distortion: %.4f mm\n', b, mean_distortion);    end
    fclose(fid_r);
end

% • “NAME-OUTPUT-1.TXT” – output file for problem 1 
