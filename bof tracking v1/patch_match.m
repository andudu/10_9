function [patch_sim, hist_sim, patch_conf] = patch_match( bag_feature, centers, patchnum, codesize, hist_all, sigma )
%% function [patch_sim, hist_sim, patch_conf] = patch_match( bag_feature, centers, patchnum, codesize, hist_all, sigma )
%%
%% Use this function to compare trained samples with testing samples and
%% compute similarities. 
%%
%% Function specification:
%% Input
%%      bag_feature     :       testing features [dim x num]
%%      centers         :       codebook [dim x codebook size]
%%      patchnum        :       number of patches
%%      codesize        :       size of codebook
%%      hist_all        :       all trained histogram [num x bin]
%%      sigma           :       used in exp chi-square distance computation
%% Output
%%      patch_sim       :       patch similarity, sum(patch_conf)
%%      hist_sim        :       bag similarity
%%      patch_conf      :       similarity exp(-dist) for each patch [1 x patchnum]
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

distance = Inf * ones(patchnum, codesize);      %% initialize distance of codewords with patches
histogram = zeros(1,codesize);                  %% initialize bag
patch_conf = Inf * ones(1,patchnum);            %% initialize similarity exp(-dist) for each patch
hist_conf = -Inf * ones(1,size(hist_all,1));    %% initialize bag similarity
patch_sim = 0;                                  %% initialize patch similarity

%% compute patch similarity and build bag 
for p = 1:patchnum
  for c = 1:codesize
    distance(p,c) = norm(centers(:,c) - double(bag_feature(:,p)));
  end    
  [tmp,descriptor_vq] = min(distance(p,:));
  patch_conf(p) = exp(-tmp);
  patch_sim = patch_sim + patch_conf(p);
  histogram(descriptor_vq) = histogram(descriptor_vq) + 1;
end

%% compute bag similarity 
for n = 1:size(hist_all, 1)
    hist_conf(n) = expChiSquare(histogram, hist_all(n, :), size(histogram,2), sigma);
end
hist_sim = max(hist_conf);