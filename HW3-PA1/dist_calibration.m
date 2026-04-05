% i was gonna start pt 3

% distortion calibration data set (is this noisy data?)

% go through every distorted file (for i in length(letters)

% transformation FC between optical and em tracker coords Fd

% transformation between cal object and optical tracker Fc

% given Fd and Fc computer Ci (expected)

% output Ci (expected)
letters = {'h', 'i', 'j', 'k'};
for i = 1:length(letters)
    s = letters{i};
    fprintf('\nDataset: pa1-debug-%s \n', s);
    
    % file names
    calbody_file = sprintf('pa1-unknown-%s-calbody.txt', s);
    fid_b = fopen(calbody_file, 'r');
    header_b = fgetl(fid_b);
    params_b = sscanf(header_b, '%d, %d, %d'); % ND,NA,NC
    ND = params_b(1); % Number of markers on the EM base
    NA = params_b(2); % number of optical markers on cal obj
    NC = params_b(3); % number EM markers on calibration object

    d = fscanf(fid_b, '%f, %f, %f', [3, ND]);
    a = fscanf(fid_b, '%f, %f, %f', [3, NA]);
    c = fscanf(fid_b, '%f, %f, %f', [3, NC]);
    fclose(fid_b);

    % Frame 1 measured points (D) from calreadings
    calreadings_file = sprintf('pa1-unknown-%s-calreadings.txt', s);
    fid_r = fopen(calreadings_file, 'r');
    % ND,NA,NC,Nframes,NAMECALREADINGS.TXT 
    header_r = fgetl(fid_r);
    params_r = sscanf(header_r, '%d, %d, %d, %d'); % ND,NA,NC
    numFrames = params_r(4);
    C = params_r(3);
    A = params_r(2);
    D = params_r(1);
    fclose(fid_r);

    Ci_expected = zeros(3, NC, numFrames); % allocate bfore 

    for b = 1:numFrames

        % go through the readings file and grab the date for every frane
        % need to use fscans
        A_read = 0;
        D_read = 0;
        C_read = 0;
        % FD 
        [Rd, pd] = point_registration(d, D_read);

        % FA
        [Ra, pa] = point_registration(a, A_read);

        % C expected
        % = inv(FD) * Fa * ci
    end 
end 

