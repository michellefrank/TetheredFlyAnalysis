%% Parameters
% Define the threshold
pixthresh = 500;

% Define minimal chain length
min_chainlength = 100;

% Deine the max number of entries tolerated by the program
maxgap = 1;

% FPS
fps = 1;

%% Processing
% Find the chains
chainmat = chainfinder(Final_data <= pixthresh);

% Tolerate gaps (may result in greater false positives)
chainmat = chainconnector(chainmat,maxgap);

% Trim the chain
chainmat = chainmat(chainmat(:,2) >= min_chainlength,:);

%% Plotting
% Find out the number of frames
nframes = length(Final_data);

% Make the figure
figure(101)
set(101, 'Position', [50,50,1300,600], 'Color', [1 1 1])

plot((1:nframes)/fps/60/60, Final_data, 'Color', [0 ,0.28, 0.94])

xlabel('Time(hour)', 'FontSize', 15)
ylabel('Pixel diff', 'FontSize', 15)

set(gca,'FontSize',15)

% Obtain y-axis extrema
ylim = get(gca,'YLim');

% Add text and lines to signify chains
hold on

for i = 1 : size(chainmat,1)
    % Draw lines
    line([chainmat(i,1),chainmat(i,1)+chainmat(i,2)-1]/fps/60/60,...
        [pixthresh,pixthresh],'Color',[0.93,0.13,0.14],...
        'LineWidth',5);
    
    % Write when each chain starts
    if mod(i,2) ~= 0
        text(chainmat(i,1)/fps/60/60, 0.9*ylim(2),...
        num2str(round(chainmat(i,1)*fps/60)), 'Color', [0.93,0.13,0.14],...
        'FontSize', 11);
    else
        text(chainmat(i,1)/fps/60/60, 0.85*ylim(2),...
        num2str(round(chainmat(i,1)*fps/60)), 'Color', [0.93,0.13,0.14],...
        'FontSize', 11);
    end
end

hold off