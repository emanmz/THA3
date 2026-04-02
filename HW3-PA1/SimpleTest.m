%% Simple Test Case 
close all; clear all;
    % A: source points (3 x N)
    % B: target points (3 x N)
    % square thats translated 2 in x then rotated 90deg about z

    A = [ 0 0 2 2;
         0 2 2 0;
         0 0 0 0];

    B = [0 -2 -2 0;
         2 2 4 4;
         0 0 0 0];

    [R, p] = point_registration(A,B);

Bfunc =[];
  for i = 1:size(A,2)
      bi = R*A(:,i)+p;
      Bfunc = [Bfunc, bi];
      
  end
  disp('Bfunc')
  disp(Bfunc)
  disp('B')
  disp(B)