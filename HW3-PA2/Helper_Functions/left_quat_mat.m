function L = left_quat_mat(q)
    w = q(1); x = q(2); y = q(3); z = q(4);
    L = [w -x -y -z;
         x  w -z  y;
         y  z  w -x;
         z -y  x  w];
end