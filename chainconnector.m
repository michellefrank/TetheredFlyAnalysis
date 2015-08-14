function [ chainmat_c ] = chainconnector( chainmat , maxgap)
%chainconnector connects chains that are broken by small (user-defined)
%number of entries. Default gap is 1.
%   [ chainmat_c ] = chainconnector( chainmat , maxgap)

if nargin < 2
    maxgap = 1;
end


% Calculate where the initial chains end
chainends = chainmat(1:end-1,1) + chainmat(1:end-1,2) - 1;

% Figure out which chain gaps are toleratable
chainjoints = (chainmat(2:end,1) - chainends) <= (maxgap + 1);

% Find a chainmat of the toleratable gaps
chainjoints_chains = chainfinder(chainjoints);

% Find the final number of chains
n_chains = size(chainjoints_chains, 1);

% Prime the new chain mat
chainmat_c = zeros(n_chains, 2);

for i = 1 : n_chains
    % Find where this chain starts
    chainmat_c (i, 1) = chainmat(chainjoints_chains(i,1),1);
    
    % Find how long this chain is
    chainmat_c(i,2) = sum(chainmat(chainjoints_chains(i,1):...
        chainjoints_chains(i,1)+chainjoints_chains(i,2),2))...
        + (chainjoints_chains(i,2)+1) * maxgap;
end

% Label connected joined chains
conn_chains = [0;chainjoints];
conn_chains(chainjoints_chains(:,1)) = 1;

% Keep unjoined chains
unjoined_chains = chainmat(conn_chains==0,:);

% Combine joined and unjoined chains, and sort
chainmat_c = sortrows([chainmat_c;unjoined_chains]);

end
