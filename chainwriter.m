function [ chainvec ] = chainwriter( size, chainmat )
%chainwriter writes out a chain of 0 and 1 based on the given chain size
%and chainmat

% Prime the chain
chainvec = zeros(size, 1);

% Write out the 1's in the chain
for i = 1 : size(chainmat,1)
    chainvec(chainmat(i,1):chainmat(i,1)+chainmat(i,2)-1) = 1;
end

end

