function [ lbp_bag_feature, rgb_bag_feature ] = update_feature( lbp, rgb, lbp_sim, rgb_sim, lbp_p, rgb_p )
%% function [ lbp_bag_feature, rgb_bag_feature ] = update_feature( lbp,
%% rgb, lbp_sim, rgb_sim, lbp_p, rgb_p )
%%
%% This function selects good patches to update codebook. The number of
%% choosen patches is determined by patch similarity. If patch similarity
%% is below a threshold th, we choose p1 good patches; otherwise we choose
%% p2 good patches. Note that the is empirical and may be not optimal.  
%%  
%% Function specification:
%% Input
%%      lbp                 :       LBP features of patches extracted from 
%%                                  the tracked object
%%      rgb                 :       RGB features of patches extracted from 
%%                                  the tracked object
%%      lbp_sim             :       LBP similarities exp(-dist)
%%      rgb_sim             :       RGB similarities exp(-dist)
%%      lbp_p               :       LBP patch similarity
%%      rgb_p               :       RGB patch similarity
%% Output
%%      lbp_bag_feature     :       selected LBP features 
%%      rgb_bag_feature     :       selected RGB features
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

p1 = 3; p2 = 5;         %% number of good patches
th = 0.0034;            %% threshold to choose p1 or p2

%% sort similarities exp(-dist)
[lbp_tmp, lbp_idx] = sort(lbp_sim, 2, 'descend');
[rgb_tmp, rgb_idx] = sort(rgb_sim, 2, 'descend');

%% extract LBP features
if lbp_p >= th
    lbp_bag_feature = lbp(lbp_idx(1:p2),:);
else
    lbp_bag_feature = lbp(lbp_idx(1:p1),:);
end

%% extract RGB features
if rgb_p >= th
    rgb_bag_feature = rgb(rgb_idx(1:p2),:);
else
    rgb_bag_feature = rgb(rgb_idx(1:p1),:);
end
