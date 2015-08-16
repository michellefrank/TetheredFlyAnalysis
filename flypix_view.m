%% Parameters

ViewingFPS = 20;

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
    
    % Only use 1 channel from the RGB frame
    newVidstack(:,:,i-startframe+1) = tempim(:,:,1);
end
textprogressbar('Done!');

%% Play the video
implay(newVidstack, Viewing FPS)