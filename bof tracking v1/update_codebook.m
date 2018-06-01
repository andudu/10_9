function newcenters = update_codebook(bag_feature, centers, codebook_size, ff)
%% function newcenters = update_codebook(bag_feature, centers,
%% codebook_size, ff)
%%
%% This function performs codebook update.
%%
%% Function specification:
%% Input
%%      bag_feature         :       new features [dim x num]
%%      centers             :       old codebook [dim x codebook size]
%%      codebook_size       :       size of codebook
%%      ff                  :       forget factor
%% Output
%%      newcenters          :       new codebook [dim x codebook size]
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

Max_Iterations = 10;      %% Max number of k-means iterations
Verbosity = 0;            %% Verbsoity of Mark's code

cluster_options.maxiters = Max_Iterations;
cluster_options.verbose  = Verbosity;

descriptors = [bag_feature ff * centers];
%% OK, now call kmeans clustering routine by Mark Everingham
[newcenters,sse] = vgg_kmeans(double(descriptors), codebook_size, cluster_options);

