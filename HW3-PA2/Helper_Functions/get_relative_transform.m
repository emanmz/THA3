function [R_rel, t_rel] = get_relative_transform(q1, t1, q2, t2)
    % Standard relative motion: T_rel = T1^-1 * T2
    R1 = quat2rot(q1);
    R2 = quat2rot(q2);
    
    R_rel = R1' * R2;
    t_rel = (R1' * (t2 - t1)')'; % Result is a 1x3 row vector
end