%% Parameters
% Define the threshold
pixthresh = 500;

% Define minimal chain length
min_chainlength = 300;

% Deine the max number of entries tolerated by the program
maxgap = 1;

% FPS
fps = 1;

%% Processing
% Find the chains
chainmat = chainfinder(Pixeldiff <= pixthresh);

% Tolerate gaps (may result in greater false positives)
chainmat = chainconnector(chainmat,maxgap);

% Trim the chain
chainmat_trim = chainmat(chainmat(:,2) >= min_chainlength,:);

%% Plotting
% Find out the number of frames
nframes = length(Pixeldiff);

% Make the figure
figure(101)
set(101, 'Position', [50,50,1300,600], 'Color', [1 1 1])

plot((1:nframes)/fps/60/60, Pixeldiff, 'Color', [0 ,0.28, 0.94])

xlabel('Time(hour)', 'FontSize', 15)
ylabel('Pixel diff', 'FontSize', 15)

set(gca,'FontSize',15)

% Obtain y-axis extrema
ylim = get(gca,'YLim');

% Add text and lines to signify chains
hold on

for i = 1 : size(chainmat_trim,1)
    % Draw lines
    line([chainmat_trim(i,1),chainmat_trim(i,1)+chainmat_trim(i,2)-1]/fps/60/60,...
        [pixthresh,pixthresh],'Color',[0.93,0.13,0.14],...
        'LineWidth',5);
    
    % Write when each chain starts
    if mod(i,2) ~= 0
        text(chainmat_trim(i,1)/fps/60/60, 0.9*ylim(2),...
        num2str(round(chainmat_trim(i,1)*fps/60)), 'Color', [0.93,0.13,0.14],...
        'FontSize', 11);
    else
        text(chainmat_trim(i,1)/fps/60/60, 0.85*ylim(2),...
        num2str(round(chainmat_trim(i,1)*fps/60)), 'Color', [0.93,0.13,0.14],...
        'FontSize', 11);
    end
end

hold off

% Save the figure
savefig(gcf, fullfile(path, [filename(1:end-4), '-sleep_bouts.fig']));

%% Plot histogram of rest bout durations

% Filter out bouts with duration shorter than 1 min
chainmat2 = chainmat(chainmat(:,2) > 60,2);

% Convert units to minutes
chainmat2 = chainmat2/60;

% Plot the histogram of rest bout durations
figure; hist(chainmat2, 20);
set(gcf, 'Color', [1 1 1]);
xlabel('Minutes', 'fontweight', 'bold');
ylabel('Counts', 'fontweight', 'bold');
title('Rest bout durations', 'fontweight', 'bold');

% Save the file
savefig(gcf, fullfile(path, [filename(1:end-4), '-rest_bouts.fig']));


%% Print out summary info

disp('Mean length of rest bouts (>1 min): ');
disp(mean(chainmat2));

disp('Number of sleep bouts (>5 min): ');
disp(size(chainmat_trim,1));

disp('Mean length of sleep bouts (> 5 min): ');
disp(mean(chainmat_trim(:,2))/60);
