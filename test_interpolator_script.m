% arcInterpolator test script
% a script for testing the arcInterpolator function

% have the user select a test file
[interpolationfile,interpolationpath] = uigetfile("*.txt",'Select an interpolation file');
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

mySteering = A(:,1);
myHeading = A(:,2);
myDepth = A(:,3);
mySpeed = A(:,4);

num = height(A);
v = zeros(num,12);
for i = 1:num
    v(i,:) = arcInterpolator(mySteering(i),myHeading(i),...
        myDepth(i),mySpeed(i));
end

