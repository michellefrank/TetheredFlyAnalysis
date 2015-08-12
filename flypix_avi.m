%% Set parameters
% Set target fps
targetfps = 1;

% First frame to load
firstframe2load = 1;

% Channel to choose: red = 1, blue = 2, or green = 3
RGBchannel = 1;

% Choose 1 if don't want to see the progress of processing
quietmode = 1;

%% Load video
% Specify video name and path
[filename, path] = uigetfile('*.avi','Select the video file');
addpath(path);

% Get common parameters
VidObj = VideoReader(filename);

nVidFrame = VidObj.NumberOfFrames;
vidHeight = VidObj.Height;
vidWidth = VidObj.Width;
vidfps = VidObj.FrameRate;
vidDuration = VidObj.Duration;

%% Crop-out the ROI

% Read out the first frame
sampleframe = read(VidObj , 1);

% Only use the Red channel
sampleframe = sampleframe(:,:,RGBchannel);

% Manually select ROI
[sampleframe_cr, cropindices] = imcrop(sampleframe);
cropindices = floor(cropindices);
close(gcf)

%% Set threshold
figure(101)
set(101,'Position',[100 50 1000 600])

% Showcase all the threshold levels
for i = 1 : 20
    subplot(4,5,i);
    imshow(largestarea(im2bw(sampleframe_cr, i/20)));
    text(10,15,num2str(i/20),'Color',[1 0 0]);
end

% Input the threshold
threshold = input('Threshold=');
close(101)

%% Remove the tethering bar
figure(101)

% Manually select bar ROI
[~, cropindices_bar] = imcrop(sampleframe_cr);
cropindices_bar = max(floor(cropindices_bar),1);
close(101)

%% Load frames and adjust fps
% Ajudt how many frames to skip during loading
frames2skip=round(vidfps/targetfps);

% Calculate how many frames to load
nframe2load=length(firstframe2load : frames2skip : nVidFrame);

% Prime the video stack
Vidstack = uint8( zeros(cropindices(4), cropindices(3), nframe2load));

% Use progress bar if needed
if quietmode==0
    dispbar=waitbar(0,'Loading Data Video');
else
    textprogressbar('Processing: ');
end

% Load it!
for i = firstframe2load : frames2skip : nVidFrame
    % Read out frame
    Mov = read(VidObj , i);
    
    % Discard the unchosen channels
    Mov=Mov(:,:,RGBchannel);
    
    % Get current frame
    currentframe = Mov(cropindices(2):cropindices(2)+cropindices(4)-1,...
    cropindices(1):cropindices(1)+cropindices(3)-1);
    
    % Remove the tethering bar
    currentframe(cropindices_bar(2):cropindices_bar(2)+cropindices_bar(4)-1,...
        cropindices_bar(1):cropindices_bar(1)+cropindices_bar(3)-1)=0;

    % Load & apply threshold & filter by areas
    Vidstack(:,:,(i - firstframe2load) / frames2skip + 1) = ...
        largestarea(im2bw(currentframe,threshold));

    if quietmode==0
        % Preview, but slows down the processing
        imshow(Vidstack(:,:,(i - firstframe2load) / frames2skip + 1),[]);
        
        % Update the waitbar
        waitbar(i/nVidFrame,dispbar)
    else
        textprogressbar(i/(nVidFrame - firstframe2load)*100);
    end
end

if quietmode==0
    close(dispbar)
else
    textprogressbar('Done!');
end

%% Calculate pixel subtration
Pixeldiff = squeeze(sum(sum(abs(diff(Vidstack, 1, 3)), 1), 2));

plot((1+1/targetfps):1/targetfps:nframe2load,Pixeldiff)
xlabel('Time(s)')
ylabel('Pixel Difference')

% Save data
save(fullfile(path,'Processed data',[filename(1:end-4),'.mat']))
