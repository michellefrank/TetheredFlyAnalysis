%% Parameters
% FPS when viewing the video
ViewingFPS = 20;

% Threshold for the intensity of the pixel subtraction
pixthresh = 500;

% Threshold for sleep duration (number of frames)
sleep_thresh = 300;

% Where the circle will be drawn if the pixel subtraction is subthreshold
circle_position1 = [size(Vidstack,2) - 20, 20, 8]; %[x,y,rad]
circle_position2 = [size(Vidstack,2) - 20, 20, 15];

% Where to draw the counter for number of quiescent frames
counter_pos = [10, size(Vidstack,1) - 25];

%% Obstain start and end frames

plot(Pixeldiff);
startframe = input('Enter start frame =');
endframe = input('Enter end frame =');

%% Stamp in the pixel subtraction results
% Write out the sleep chain
sleepchain = chainwritter(chainmat);

newVidstack = Vidstack(:,:,startframe:endframe);

textprogressbar('Processing: ');

% initiate frame counter (to keep track of how many rest frames in a row
% have gone by)
rest_counter = 0;

for i = startframe : endframe
    % Update progress bar
    textprogressbar((i-startframe)/(endframe-startframe)*100);
    
    % Write the number (results in an RGB frame)
    tempim = insertText(Vidstack(:,:,i)*255, [10 10], num2str(Pixeldiff(i-1)));
    
    % Write a circle if below threshold
    if Pixeldiff(i-1) < pixthresh
        rest_counter = rest_counter + 1;
        if rest_counter >= sleep_thresh
            tempim = insertShape(tempim, 'FilledCircle', circle_position, 'Color', [255, 0, 0]);
        else
            tempim = insertShape(tempim, 'FilledCircle', circle_position, 'Color', [100, 0, 0]);
        end
    else
        rest_counter = 0;
    end
    
    % Insert a counter showing the number of frames below threshold
    tempim = insertText(tempim, counter_pos, num2str(rest_counter));
    
    % Only use 1 channel from the RGB frame
    newVidstack(:,:,i-startframe+1) = tempim(:,:,1);
end

textprogressbar('Done!');

%% Play the video
implay(newVidstack, ViewingFPS)