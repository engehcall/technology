function [scaled_feature] = get_scaled_feature(orig_f, wsize)
% USAGE: function to compute the scaled feature
% 
% OUTPUT: 
%   scaled_feature = output scaled feature (wsize+1)*(wsize+1)
% 
% INPUT: 
%   orig_f = original feature (24x24) (actually, 25x25 after zero padding)
%   wsize = size of the final scaled feature (square window)
%
% CREATED BY:
%   Dhiraj Goel, Feb 2006

nonzero_elements_idx = find(orig_f ~= 0);
[nRows nCols] = size(orig_f);
if (nRows ~= nCols) 
    disp('Error: Base window is not square');
    return;
end

if (nRows ~= 25)
    disp('Warning: Size of base window is not 24');     
    % due to zero padding, the size becomes 25x25
end

% scale the indices of non zero elements to get the new "scaled" matrix
wsize = wsize + 1;  % zero padding

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
scale_factor = (wsize-1)/(nRows-1);  % actual patch sizes..w/o padding

% declare the scaled feature
scaled_feature = zeros(wsize);

for i = 1:length(nonzero_elements_idx)
   curr_col = ceil(nonzero_elements_idx(i)/nRows);
   curr_row = nonzero_elements_idx(i) - nRows*(curr_col-1);
   
   new_row = max(round(curr_row * scale_factor),1);
   new_col = max(round(curr_col * scale_factor),1);
   
   new_row = min(new_row, wsize);
   new_col = min(new_col, wsize);
%   keyboard;
   scaled_feature(new_row, new_col) = orig_f(curr_row, curr_col);
   
end

end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% new algo
% wsize --> padded
% nRows --> padded

scale_factor = (wsize-1)/(nRows-1);  % actual patch sizes..w/o padding

% declare the scaled feature
scaled_feature = zeros(wsize);

% find the [x y] of nonzero elements in orig_f
[y x] = find(orig_f ~= 0);

% find the scaled feature point for the first non zero element
if (y(1) == 1)
    first_row = 1;
else 
    first_row = max(round(y(1) * scale_factor),1);
end

if (x(1) == 1)
    first_col = 1;
else
    first_col = max(round(x(1) * scale_factor),1);
end

scaled_feature(first_row, first_col) = orig_f(y(1), x(1));

last_row = first_row;
last_col = first_col;

% find the scaled points for the remaining elements
for j = 2:length(x)
    
    if ( x(j) == x(j-1) ) % same col
        new_row_offset = max(round((y(j)-y(j-1)) * scale_factor),1);
        new_row = last_row + new_row_offset;
        new_col = last_col;
        
        scaled_feature(new_row, new_col) = orig_f(y(j),x(j));
        
        last_col = new_col;
        last_row = new_row;
        
    else    
        % new col --> same row as first_element, diff col
        new_row = first_row;
        new_col_offset = max(round((x(j)-x(j-1))*scale_factor),1);
        new_col = last_col + new_col_offset;
        
        scaled_feature(new_row, new_col) = orig_f(y(j),x(j));
        
        last_col = new_col;
        last_row = new_row;       
    end

end


% check if the nonzero elements are in range
[y x] = find(scaled_feature ~= 0);

max_row = max(y);
max_col = max(x);

if (max_row > wsize)
    offset = max_row - wize;
    
    % shift all the rows up by this amount
    scaled_feature = scaled_feature(offset+1:end,:);
end

if (max_col > wsize)
    offset = max_col - wsize;
    
    scaled_feature = scaled_feature(:,offset+1:end);

end









