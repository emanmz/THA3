function [R, p] = point_registration(A, B) % W9-L1 Slide 5 - 8 or Slide 5-6, 12-15
    % A: source points (3 x N)
    % B: target points (3 x N)
    
    % Step 1: Compute centroids 
    centroid_A = mean(A, 2);
    centroid_B = mean(B, 2);
    
    % Step 2: Center the points
    Am = A - centroid_A;
    Bm = B - centroid_B;
    
    % Step 3: Calculate R with quaternion method 

    M = []; % Loop to make M matrix
    for i = 1:size(A,2)
    Mi = [0 (Bm(:, i)-Am(:,i))';
          Bm(:, i)-Am(:,i) skewSym(Bm(:, i)+Am(:,i))];

        M = [M; Mi];
    end

    [U, ~, V] = svd(M); % SVD on M matrix

    q = V(:,4);  % extract unit quaternion

    R = quat2rot(q(1), q(2), q(3), q(4)); % quaternion to rotation


    %SVD Method Below. uncomment if you think this method is going to be
    %better
    % 
    % % Step 3.1 Compute the covariance matrix H
    % H = Am * Bm';
    % 
    % % Step 3.2 Find optimal rotation using SVD
    % [U, ~, V] = svd(H);
    % R = V * U';
    % 
    % % reflection case to ensure a right-handed system (This is step 3.4
    % % det(R) doesn't equal 1 basically from beginning of course this is a
    % % reflection
    % if det(R) < 0
    %     V(:,3) = V(:,3) * -1;
    %     % step 3.3
    %     R = V * U';
    % end
    
    % Step 4: translation
    p = centroid_B - R * centroid_A;
end