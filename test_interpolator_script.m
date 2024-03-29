% arcInterpolator test script
% a script for testing the arcInterpolator function

% have the user select a test file
%[interpolationfile,interpolationpath] = uigetfile("*.txt",'Select an interpolation file');
interpolationfile = 'multi field interpolation from file.txt';
formatSpec = '%f';
fileID = fopen(interpolationfile,'r');
temp = fscanf(fileID,formatSpec);
count = 1;
first = 1;
A = zeros(length(temp)/4,4);
% turn temp column vector into the A matrix of row vectors. Each row is a
% new interpolation query
for i = 1:length(temp)
    % check inputs of temp first
    if mod(i,4) == 0
        A(count,:) = temp(first:i);
        first = i+1;
        count = count+1;
    end
end
%A = [0,0,0.1,0.3;0,4,0.1,0.3;5,16,0.1,0.3;15,34,0.1,0.3;11,60,0.1,0.3;...
%    5,67,0.1,0.3;0,70,0.1,0.3];

mySteering = A(:,1);
myHeading = A(:,2);
myDepth = A(:,3);
mySpeed = A(:,4);

num = height(A);
v = zeros(num,12);
tic
for i = 1:num
    v(i,:) = arcInterpolator(mySteering(i),myHeading(i),...
        myDepth(i),mySpeed(i));
end
toc
