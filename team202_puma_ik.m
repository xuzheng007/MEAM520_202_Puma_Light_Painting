function thetas = team202_puma_ik(x, y, z, phi, theta, psi)
%% team202_puma_ik.m
%
% Calculates the full inverse kinematics for the PUMA 260.
%
% This Matlab file provides the starter code for the PUMA 260 inverse
% kinematics function of project 2 in MEAM 520 at the University of
% Pennsylvania.  The original was written by Professor Katherine J.
% Kuchenbecker. Students will work in teams modify this code to create
% their own script. Post questions on the class's Piazza forum. 
%
% The first three input arguments (x, y, z) are the desired coordinates of
% the PUMA's end-effector tip in inches, specified in the base frame.  The
% origin of the base frame is where the first joint axis (waist) intersects
% the table. The z0 axis points up, and the x0 axis points out away from
% the robot, perpendicular to the front edge of the table.  These arguments
% are mandatory.
%
%     x: x-coordinate of the origin of frame 6 in frame 0, in inches
%     y: y-coordinate of the origin of frame 6 in frame 0, in inches
%     z: z-coordinate of the origin of frame 6 in frame 0, in inches
%
% The fourth through sixth input arguments (phi, theta, psi) represent the
% desired orientation of the PUMA's end-effector in the base frame using
% ZYZ Euler angles in radians.  These arguments are mandatory.
%
%     phi: first ZYZ Euler angle to represent orientation of frame 6 in frame 0, in radians
%     theta: second ZYZ Euler angle to represent orientation of frame 6 in frame 0, in radians
%     psi: third ZYZ Euler angle to represent orientation of frame 6 in frame 0, in radians
%
% The output (thetas) is a matrix that contains the joint angles needed to
% place the PUMA's end-effector at the desired position and in the desired
% orientation. The first row is theta1, the second row is theta2, etc., so
% it has six rows.  The number of columns is the number of inverse
% kinematics solutions that were found; each column should contain a set
% of joint angles that place the robot's end-effector in the desired pose.
% These joint angles are specified in radians according to the
% order, zeroing, and sign conventions described in the documentation.  If
% this function cannot find a solution to the inverse kinematics problem,
% it will pass back NaN (not a number) for all of the thetas.
%
% Please change the name of this file and the function declaration on the
% first line above to include your team number rather than 200.


%% CHECK INPUTS

% Look at the number of arguments the user has passed in to make sure this
% function is being called correctly.
if (nargin < 6)
    error('Not enough input arguments.  You need six.')
elseif (nargin == 6)
    % This the correct way to call this function, so we don't need to do
    % anything special.
elseif (nargin > 6)
    error('Too many input arguments.  You need six.')
end


%% ROBOT DIMENSIONS

% Define the robot's measurements
a = 13.0; % inches
b =  2.5; % inches
c =  8.0; % inches
d =  2.5; % inches
e =  8.0; % inches
f =  2.5; % inches

%% Robot Parameters

% Define joint limits
theta1_min = degtorad(-180);
theta1_max = degtorad(110);
theta2_min = degtorad(-75);
theta2_max = degtorad(240);
theta3_min = degtorad(-235);
theta3_max = degtorad(60);
theta4_min = degtorad(-580);
theta4_max = degtorad(40);
theta5_min = degtorad(-120);
theta5_max = degtorad(110);
theta6_min = degtorad(-215);
theta6_max = degtorad(295);

theta_mins = [theta1_min, theta2_min, theta3_min, theta4_min, theta5_min, theta6_min];
theta_maxs = [theta1_max, theta2_max, theta3_max, theta4_max, theta5_max, theta6_max];


%% CALCULATE INVERSE KINEMATICS SOLUTION(S)

% For now, just set the first solution to NaN (not a number) and the second
% to zero radians.  You will need to update this code.
% NaN is what you should output if there is no solution to the inverse
% kinematics problem for the position and orientation that were passed in.
% For example, this would be the correct output if the desired position for
% the end-effector was outside the robot's reachable workspace.  We use
% this sentinel value of NaN to be sure that the code calling this function
% can tell that something is wrong and shut down the PUMA.

% Calculate theta1
th1_1 = atan2(y, x) - atan2((b + d), (sqrt(x^2 + y^2 - (b+d)^2))) + pi;
th1_2 = atan2(y, x) - atan2((b + d), (sqrt(x^2 + y^2 - (b+d)^2)));

% Calculate theta2
th3_1 = acos((x^2 + y^2 - (b + d)^2 + (z - a)^2 - c^2 - e^2)/(2*c*e)) - pi/2;
th3_2 = -acos((x^2 + y^2 - (b + d)^2 + (z - a)^2 - c^2 - e^2)/(2*c*e)) - pi/2;

% Calculate theta2
th2_1 = atan2((z - a), (sqrt(x^2 + y^2 - (b + d)^2))) - atan2((e*cos(th3_1)), (c - e*sin(th3_1)));
th2_2 = atan2((z - a), (sqrt(x^2 + y^2 - (b + d)^2))) - atan2((e*cos(th3_2)), (c - e*sin(th3_2)));

% DH matrices for joints 1-3
A1 = dh_kuchenbe(0,  pi/2,   a, th1_1);
A2 = dh_kuchenbe(c,     0,  -b, th2_1);
A3 = dh_kuchenbe(0, -pi/2,  -d, th3_1);

% Calculate rotation matrices
R06 = [1 0 0; 0 0 -1; 0 1 0];

T03 = A1*A2*A3;
R03 = T03(1:3, 1:3);

R36 = R03'*R06;

% Calculate wrist center
xc = x - f*R06(1, 3);
yc = y - f*R06(2, 3);
zc = z - f*R06(3, 3);

% Solve for Euler angles
theta_1 = atan2(sqrt(1 - R36(3, 3)^2), R36(3, 3));
theta_2 = atan2(-sqrt(1 - R36(3, 3)^2), R36(3, 3));

phi_1 = atan2(R36(2, 3), R36(1, 2));
phi_2 = atan2(-R36(2, 3), -R36(1, 2));

psi_1 = atan2(-R36(3, 1), R36(3, 2));
psi_2 = atan2(R36(3, 1), -R36(3, 2));

th1 = [th1_1 th1_2];
th2 = [th2_1 th2_2];
th3 = [th3_1 th3_2];
th4 = [phi_1 phi_2];
th5 = [theta_1 theta_2];
th6 = [psi_1 psi_2];

% You should update this section of the code with your IK solution.
% Please comment your code to explain what you are doing at each step.
% Feel free to create additional functions as needed - please name them all
% to start with team2XX_, where 2XX is your team number.  For example, it
% probably makes sense to handle inverse position kinematics and inverse
% orientation kinematics separately.


%% FORMAT OUTPUT

% Put all of the thetas into a column vector to return.
thetas = [th1; th2; th3; th4; th5; th6];

% By the very end, each column of thetas should hold a set of joint angles
% in radians that will put the PUMA's end-effector in the desired
% configuration.  If the desired configuration is not reachable, set all of
% the joint angles to NaN.