% script to generate features in struct form to be used by C code
clear all;

load ('output/features.mat');
%load ('output/10f+50f/TrainResults_Stage1_10f.mat');
%load ('output/TrainResults_Stage2.mat');
%load ('output/TrainResults_Stage3.mat');
%load ('output/10f+50f/TrainResults_Stage2_50f_used_as_stage4.mat');
load ('output/TrainResults_Stage6_used_as_stage5.mat');

%-------------------------------------
fNbestArray = fNbestArray5;
thetaBestArray = thetaBestArray5;
pBestArray = pBestArray5;
alpha_t_Array = alpha_t_Array5;

% scaling the feature parameters (so that floating point is not required)
% since cmucam3 doesn't have floating points, let's multiply all
% "alpha" by a factor of '50', (all that matters is relative
% magnitude of alpha, this way we preserve that, w/o losing out
% on accuracy due to lack of floating point)
scale_factor = 100;
thetaBestArray = round(thetaBestArray * scale_factor);
alpha_t_Array = round(alpha_t_Array * scale_factor);

% final threshold (stage dependent)
alpha_thresh = round(scale_factor + sum(alpha_t_Array)/2); 
%-----------------------------------------

% fNbestArray, thetaBestArray, pBestArray, alpha_t_Array, f
num_feat = length(fNbestArray);
num_scales = 4;
scales = [30, 38, 48 , 60];
%scales = scales + 1;   % the scaling function assumes "features" are zero padded

%cc3_feature 
%x = zeros(9,1);
%y = zeros(9,1);
%val_at_corners = zeros(9,1);
%parity = 0;
%thresh = 0;
%alpha = 0;

fid = fopen('C:\cygwin\home\Dhiraj\cmucam3\cc3\trunk\projects\viola-jones\feat_for_C_stage5.txt','W');

fprintf(fid, '{ \n');
for curr_feat_idx = 1:num_feat
     fprintf(fid, '{ \n');  % for every feature
        
      % parameters that are constant for a particular feat, across all
      % scales
      parity = pBestArray(curr_feat_idx);
      thresh = thetaBestArray(curr_feat_idx);
      alpha = alpha_t_Array(curr_feat_idx);
 
      curr_feat = reshape(f(:,fNbestArray(curr_feat_idx)),25,25);
    %  curr_feat = curr_feat(1:24,1:24);   % clip the last extra col & row  
      for curr_scale_idx = 1:num_scales
          % get all the requires parameters for this feature at this scale
          feat = get_scaled_feature(curr_feat, scales(curr_scale_idx));
          [y x] = find(feat ~= 0);
                   
          val_at_corners = [];
          for i = 1:length(y)
                  val_at_corners = [val_at_corners; feat(y(i),x(i))];
          end
          
          % in C, index starts from zero
          x = x - 1; 
          y = y - 1; 
          
          % append zeros to make these arrays generic across all types of
          % features
          while ( length(y) ~= 9)
             y = [y; 0];
             x = [x; 0];
             val_at_corners = [val_at_corners; 0];
          end
          
          % print the parameters for this feature
            fprintf(fid, '{ ');   % beginning
            fprintf(fid, '{%d, %d, %d, %d, %d, %d, %d, %d, %d}, ', x(1), x(2), x(3), x(4), x(5), x(6), x(7), x(8), x(9));
            fprintf(fid, '{%d, %d, %d, %d, %d, %d, %d, %d, %d}, ', y(1), y(2), y(3), y(4), y(5), y(6), y(7), y(8), y(9));
            fprintf(fid, '{%d, %d, %d, %d, %d, %d, %d, %d, %d}, ', val_at_corners(1), val_at_corners(2), val_at_corners(3), val_at_corners(4), val_at_corners(5), val_at_corners(6), val_at_corners(7), val_at_corners(8), val_at_corners(9));
            fprintf(fid, '%d, ', parity);
            fprintf(fid, '%4.0d, ', round(thresh));
            fprintf(fid, '%4.0d', round(alpha));
            fprintf(fid, ' }, \n'); % end
      end
      
      fprintf(fid, '}, \n');
end

fprintf(fid ,'};');
fclose(fid);
          
          