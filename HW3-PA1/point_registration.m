function [R, p] = point_registration(A, B) % W9-L1 Slide 5 - 8
    % A: source points (3 x N)
    % B: target points (3 x N)
    
    % Step 1: Compute centroids
    centroid_A = mean(A, 2);
    centroid_B = mean(B, 2);
    
    % Step 2: Center the points
    Am = A - centroid_A;
    Bm = B - centroid_B;
    
    % Step 3.1 Compute the covariance matrix H
    H = Am * Bm';
    
    % Step 3.2 Find optimal rotation using SVD
    [U, ~, V] = svd(H);
    R = V * U';
   
    % reflection case to ensure a right-handed system (This is step 3.4
    % det(R) doesn't equal 1 basically from beginning of course this is a
    % reflection
    if det(R) < 0
        V(:,3) = V(:,3) * -1;
        % step 3.3
        R = V * U';
    end
    
    % Step 4: translation
    p = centroid_B - R * centroid_A;
end