function Vq = arcInterpolator(steering2Interp,heading2Interp,depth2Interp,speed2Interp) %#codegen
% 
%   NOTE: ARC_Interpolation_Table.mat must be in the same directory!
%
% steering2Interp, is the scalar value the user wishes to interpolate the
%   steering between. Values are limited to between -15 and 15 degrees.
%
% heading2Interp, is the scalar value the user wishes to interpolate the
%   heading between. Values are limited to between 0 and 180 degrees.
%
% depth2Interp, is the scalar value the user wishes to interpolate the
%   water depth between. Values are limited to between 0.0488 and 0.2095
%   meters.
%
% speed2Interp, is the scalar value the user wishes to interpolate the
%   vehicle speed between. Values are limited to between 0.2045 and 0.89
%   meters per second.
%
% The purpose of arcInterpolator.m is to interpolates between sample points 
% of ARC_Interpolation_Table to find forces and moments on the vehicle at
% the users desired input points. This is done by using MATLABS
% scatteredInterpolant function normalized points from the
% ARC_Interpolation_Table. The function returns the vector Vq which is the
% result of the interpolation.
%
% arcInterpolator and its internal functions are slight modifications to
% functions found in interpolation_app. Where the app assumes you are
% interested in only a couple of points, this function is meant to be run
% in a loop for continuous interpolated forces and moments to be generated.
%
%This code was originally written in MATLAB and is realeased as a C++ file 
% to enable use with other applications and or scripting languages. 


% Declare the interpolation table as a persistent vairable to store the
% .mat file for use between function calls, i.e. the function only need be
% loaded once.
persistent interpHydro

% if this is the first time the function has been called load the file.
if isempty(interpHydro)
    load 'ARC_Interpolation_Table.mat'
end

% verify inputs are in sample range, if not correct them
A = [steering2Interp,heading2Interp,depth2Interp,speed2Interp];
X = checkFileLimits(A);
steering2Interp = X(1);
heading2Interp = X(2);
depth2Interp = X(3);
speed2Interp = X(4);

% find the wheel angle parameters required to processes the users desired
% steering2Interp value
[steeringSelect,steering2Interp] = findWheelAngle(steering2Interp);

% Get the handles for all the forces in ARC_Interpolation_Table
fields = fieldnames(interpHydro);
% initialize Vq to a 1 x 12 (length of fields)
Vq = zeros(1,length(fields));

% if the steering specified is on a sample point, we don't require doing
% the extra computation.
if length(steeringSelect) == 1
    % P will be the same for all fields so just get it once
    P = interpHydro.Fx.(steeringSelect).P;
    Values = interpHydro.Fx.(steeringSelect).Values;
    % normalize P, this ensures F is a smooth 4D surface
    [normP,C,S] = normalize(P);
    % generate the scatteredInterpolant, we will update the values it uses
    % in the loop but it is quicker to create it once and do that then
    % recreate it each loop
    F = scatteredInterpolant(normP,Values);
    % linear provides the best solution for our data
    F.Method = 'linear';
    % normalize each of the users input points so that the correct value
    % can be found
    normHeading2Interp = (heading2Interp-C(1))/S(1);
    normDepth2Interp = (depth2Interp-C(2))/S(2);
    normSpeed2Interp = (speed2Interp-C(3))/S(3);
    % write the first value to Vq since you've got it already
    Vq(1) = F(normHeading2Interp,normDepth2Interp,normSpeed2Interp);
    % loop over remaining fields
    for i=2:length(fields)
        % update Values and F.Values only
        Values = interpHydro.(fields{i}).(steeringSelect).Values;
        F.Values = Values;
        Vq(i) = F(normHeading2Interp,normDepth2Interp,normSpeed2Interp);
    end
else
    % more than one steering to deal with   
    % loop over all forces and moments
    for i = 1:length(fields)
        % initialize a temp values where we will write our first
        % interpolation to
        tempV = zeros(1,length(steeringSelect));
        for j = 1:length(steeringSelect)
            P = interpHydro.(fields{i}).(steeringSelect{j}).P;
            [normP,C,S] = normalize(P);
            Values = interpHydro.(fields{i}).(steeringSelect{j}).Values;
            F = scatteredInterpolant(normP,Values);
            F.Method = 'linear';
            % normalize each heading to the respecitve scale for that steering,
            % need to match each normP
            normHeading2Interp = (heading2Interp-C(1))/S(1);
            normDepth2Interp = (depth2Interp-C(2))/S(2);
            normSpeed2Interp = (speed2Interp-C(3))/S(3);
            tempV(j) = F(normHeading2Interp,normDepth2Interp,normSpeed2Interp);
        end
        % now interpolate between the steering values on the rangle A
        A = steering2Interp(1:3);
        % using makima, could use linear or cubic, there's not a huge
        % difference observed here, getting F smooth is more important
        Vq(i) = interp1(A,tempV,steering2Interp(end),'linear');
    end
end

%% checkFileLimits function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = checkFileLimits(A)
% function checks each column of A for values that exceed the 
% limits imposed by the different sample points. If a value is over
% the limit it is capped to the limit and a warning is 
% displayed to the user
    wheelAngleLimits = [-15, 15];
    headingLimits = [0, 180];
    depthLimits = [4.88/100, 20.95/100];
    speedLimits = [20.45/100, 89/100];

    allowedValues = [wheelAngleLimits;headingLimits;depthLimits;...
                     speedLimits];
    X = zeros(size(A));
    for a = 1:size(A,2)
        X(:,a) = A(:,a);
        % Find elements in the column that fall outside of the
        % allowed range
        outofRangeLow = A(:,a) < allowedValues(a,1);
        outofRangeHigh = A(:,a) > allowedValues(a,2);
        % Replace out-of-range elements with the nearest allowed
        % value
        if any(outofRangeLow)
            message = {'Element out of range, LOW!'};
            warndlg(message,'Warning');
            X(outofRangeLow,a) = allowedValues(a,1);
            fprintf('Element at [%d,%d] out of range, replaced with %4.3f\n',outofRangeLow,a,allowedValues(a,1));
        elseif any(outofRangeHigh)
            message = {'Element out of range, HIGH!'};
            warndlg(message,'Warning');
            X(outofRangeHigh,a) = allowedValues(a,2);
            fprintf('Element at [%d,%d] out of range, replaced with %4.3f\n',outofRangeHigh,a,allowedValues(a,2));
        end
    end
end % checkFileLimits

%%
function [steeringSelect,steering2Interp] = findWheelAngle(steeringValue)
%
% A function that takes in a user determined steeringValue and returns the
% steeringSelect string array for accessing interpHydro and steering2Interp
% an array of values for which the interpolation function will use to
% interpolate between sample steering values.
%   Examples of function
%   Ex 1. Passing value at sample point -15, 0 or 15
%   [steeringSelect, steering2Interp] = findWheelAngle(0)
%   findWheelAngle will return steeringSelect = 'Center' and
%   Steering2Interp = 0;
%
%   Ex 2. Passing value between sample points
%   [steeringSelect, steering2Interp] = findWheelAngle(5)
%   findWheelAngle will return steeringSelect = 
%   ["Starboard","Center","Port"] and Steering2Interp = [-15, 0, 15, 5];
%   This allows the interpreting function to use as many points as possible
%   to fit the interpolated value to

    if steeringValue > 0
        if steeringValue == 15
            steeringSelect = "Port";
            steering2Interp = 15;
        else
            steeringSelect = ["Starboard","Center","Port"];
            steering2Interp = [-15,0,15,steeringValue];
        end
    elseif steeringValue < 0
        if steeringValue == -15
            steeringSelect = "Starboard";
            steering2Interp = -15;
        else
            steeringSelect = ["Starboard","Center","Port"];
            steering2Interp = [-15,0,15,steeringValue];
        end
    else
        steeringSelect = "Center";
        steering2Interp = 0;
    end
end

end