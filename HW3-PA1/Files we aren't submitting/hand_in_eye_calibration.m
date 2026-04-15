% inputs: series of robot configs Ei and series of sensor readings of the cal object Si
% ouput: X transformation between the EE frame and the sensor
% W9-L2-Slide 17-22

% iterate through the sequences?
% A = E1'*E2 = E(i)'*E(i+1)
% B = S1*S2' = S(i)*S(i+1)'

% solve rotation using quaternion approach: Ra*Rx = Rx*Rb
% Rot2quat for Rx, Rb, and Ra to get qx qa and qb

% make M Matrix (slide 19) out of qa and qb
% M(1,1) = qa(1)-qb(1) %subtract scalar parts
% M(1,2) = -(qa(2:4)-qb(2:4))' %subtract vector parts and take transpose
% M(2,1) = qa(2:4)-qb(2:4) %subtract vector portions
% M(2,2) = (qa(1)-qb(1))*eye(3)+skewSym(qa(2:4)+qb(2:4))

% stack all M matrix for all successive measurements
% use SVD to find V like in point reg fuc but with the constriant norm(qx)
% = 1
%[~,~,V] = SVD(M)
%extract V(:,4) = qx
% quat2Rot(qx) = Rx

% 2: solv translation
% (Ra,k-I)*px = Rx*pb.k-pa,k
%solve with least squares...

