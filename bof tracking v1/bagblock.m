function [lbp_bag_feature, rgb_bag_feature] = bagblock( image, r, b, g, patchsize, patchnum )
%% function [lbp_bag_feature, rgb_bag_feature] = bagblock( image, r, b, g, patchsize, patchnum )
%% Use this function to extract LBP and RGB features from the collection of
%% patches within a normalized image block. Locations of centers of patches 
%% are randomly determined while the size of patch is constantly 12x12.
%% 
%% Function specification:
%% Input
%%      image               :           input image block (gray)
%%      r                   :           input image block (red color)
%%      b                   :           input image block (blue color)
%%      g                   :           input image block (green color)
%%      patchsize           :           size of patch
%%      patchnum            :           number of patches
%% Output
%%      lbp_bag_feature     :           LBP features used for training and
%%                                      update [num x dim] 
%%      rgb_bag_feature     :           RGB features used for training and
%%                                      update [num x dim]
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

%% parameters for uniform LBP
MODE = 'nh';        
PR = [ 8 2 ];
MAPPING = getmapping(8,'u2');

bin = 4;       %% number of bins for each color channel

%% store features
lbp_bag_feature = [];       
rgb_bag_feature = [];

%% extract patches and respective features
blocksize = size(image);
y = patchsize(1)/2;
x = patchsize(2)/2;
patch_centy = floor(y + rand(1,patchnum)*(blocksize(2)-patchsize(2)));      %% patch centers y
patch_centx = floor(x + rand(1,patchnum)*(blocksize(2)-patchsize(2)));      %% patch centers x
for i = 1: patchnum
    patch = image(patch_centy(i)-y+1 : patch_centy(i)+y, patch_centx(i)-x+1 : patch_centx(i)+x);
    r_patch = r(patch_centy(i)-y+1 : patch_centy(i)+y, patch_centx(i)-x+1 : patch_centx(i)+x);
    b_patch = b(patch_centy(i)-y+1 : patch_centy(i)+y, patch_centx(i)-x+1 : patch_centx(i)+x);
    g_patch = g(patch_centy(i)-y+1 : patch_centy(i)+y, patch_centx(i)-x+1 : patch_centx(i)+x);
    lbp_bag_feature = [ lbp_bag_feature; uniform_PR_LBPfeatures(patch, patchsize, patchsize, PR, MAPPING, MODE) ];
    rgb_bag_feature = [ rgb_bag_feature; rgb_hist(r_patch,g_patch,b_patch,bin) ];
end




