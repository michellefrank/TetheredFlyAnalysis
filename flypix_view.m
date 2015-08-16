%% Parameters
% FPS when viewing the video
ViewingFPS = 20;

% Threshold for the intensity of the pixel subtraction
pixthresh = 500;

% Where the circle will be drawn if the pixel subtraction is subthreshold
circle_position = [size(Vidstack,2) - 20, 20, 10]; %[x,y,rad]

%% Obstain start and end frames

plot(Pixeldiff);
startframe = input('Enter start frame =');
endframe = input('Enter end frame =');

%% Stamp in the pixel subtraction results
newVidstack = Vidstack(:,:,startframe:endframe);

textprogressbar('Processing: ');

for i = startframe : endframe
    % Update progress bar
    textprogressbar((i-startframe)/(endframe-startframe)*100);
    
    % Write the number (results in an RGB frame)
    tempim = insertText(Vidstack(:,:,i)*255, [10 10], num2str(Pixeldiff(i-1)));
    
    % Write a circle if below threshold
    if Pixeldiff(i-1) < pixthresh
        tempim = insertShape(tempim, 'FilledCircle', circle_position, 'Color', [255 , 0, 0]);
    end
    
    % Only use 1 channel from the RGB frame
    newVidstack(:,:,i-startframe+1) = tempim(:,:,1);
end
textprogressbar('Done!');

%% Play the video
implay(newVidstack, ViewingFPS)