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
[filename, path] = uigetfile('*.tif','Select the video file');
addpath(path);

% Ask user the input the number of videos
endvidnum = input('End video number =');

% Get common parameters

vidfps = 45/50;

%{
VidObj = VideoReader(filename);

nVidFrame = VidObj.NumberOfFrames;
vidHeight = VidObj.Height;
vidWidth = VidObj.Width;
vidfps = VidObj.FrameRate;
vidDuration = VidObj.Duration;
%}

%% Crop-out the ROI

% Read out the first frame
sampleframe = imread(fullfile(path,filename));

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


%% Start batch processing
Final_data = [];

for j = str2double(filename(end-4)) : endvidnum
    tic
    
    %% Reconstitute filename
    filename2 = [filename(1:end-5), num2str(j),'.tif'];
    disp(['Processing Video: ', filename2])
    
    %% Load frames and adjust fps
    % Ajudt how many frames to skip during loading
    frames2skip = 1; %round(vidfps/targetfps);

    % Obtain the number of frames in the video
    nVidFrame = length(imfinfo(fullfile(path,filename2)));

    % Calculate how many frames to load
    nframe2load = nVidFrame; %length(firstframe2load : frames2skip : nVidFrame);

    % Prime the video stack
    Vidstack = uint8( zeros(cropindices(4), cropindices(3), nframe2load));

    % Use progress bar if needed
    if quietmode==0
        dispbar=waitbar(0,['Processing Video #', num2str(j)]);
    end

    % Load it!
    for i = firstframe2load : frames2skip : nVidFrame
        
        % Read out frame
        Mov = imread(fullfile(path,filename2),i);

        % Discard the unchosen channels
        % Mov=Mov(:,:,RGBchannel);

        % Get current frame
        currentframe = Mov(cropindices(2):cropindices(2)+cropindices(4)-1,...
        cropindices(1):cropindices(1)+cropindices(3)-1);

        % Load & apply threshold & filter by areas
        Vidstack(:,:,(i - firstframe2load) / frames2skip + 1) = ...
            largestarea(im2bw(currentframe,threshold));

        if quietmode==0
            % Preview, but slows down the processing
            figure(102)
            imshow(Vidstack(:,:,(i - firstframe2load) / frames2skip + 1),[]);

            % Update the waitbar
            waitbar(i/nVidFrame,dispbar)
        end
    end

    if quietmode==0
        close(102)
        close(dispbar)
    end

    %% Calculate pixel subtration
    Pixeldiff = squeeze(sum(sum(abs(diff(Vidstack, 1, 3)), 1), 2));
    
    Final_data = [Final_data ; Pixeldiff]; %#ok<AGROW>
    
    % Make a plot
    %{
    if strcmp(filename,filename2)
        plot(1/vidfps:1/vidfps:(nframe2load-1)/vidfps,Pixeldiff)
        xlabel('Time(s)')
        ylabel('Pixel Difference')
    end
    %}
    
    save(fullfile(path,'Processed data',[filename2(1:end-4),'.mat']))
    toc
end

%% save and plot final data
% Plot
plot((1:length(Final_data))/vidfps/60, Final_data)
xlabel('Time(min)')
ylabel('Pixel Difference')

% Save
keep Final_data path
save(fullfile(path,'Processed data','Finaldata.mat'))

