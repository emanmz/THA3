function [R] = quat2rot(q0, q1, q2, q3)

% a unit quaternion
mag = sqrt(q0^2 + q1^2 + q2^2 + q3^2);
q0 = q0/mag; q1 = q1/mag; q2 = q2/mag; q3 = q3/mag;

% 2. Calculate matrix elements based on formulas:
% Diagonal elements
r11 = q0^2 + q1^2 - q2^2 - q3^2; %
r22 = q0^2 - q1^2 + q2^2 - q3^2; %
r33 = q0^2 - q1^2 - q2^2 + q3^2; %

% Off-diagonal elements (Row 1)
r12 = 2*(q1*q2 - q0*q3); %
r13 = 2*(q0*q2 + q1*q3); %

% Off-diagonal elements (Row 2)
r21 = 2*(q0*q3 + q1*q2); %
r23 = 2*(q2*q3 - q0*q1); %

% Off-diagonal elements (Row 3)
r31 = 2*(q1*q3 - q0*q2); %
r32 = 2*(q0*q1 + q2*q3); %

% 3. Assemble the SO(3) Rotation Matrix
R = [r11, r12, r13;
    r21, r22, r23;
    r31, r32, r33];
end