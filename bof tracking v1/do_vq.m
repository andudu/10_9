function histogram_all = do_vq(trainbag, centers, codebook_size, patchnum, f)
%% function histogram_all = do_vq(trainbag, centers, codebook_size,
%% patchnum, f)
%% 
%% This function performs vector quantification (vq) to assign features to
%% bins of a histogram by computing the distance between features and codewords. 
%% The value of a bin represents the occurrence frequency of a codeword. We 
%% put all bags (histograms) together to form a matrix. The code is
%% modified from part of R. Fergus's bag of features code.
%%
%% Function specification:
%% Input
%%      trainbag        :       training features [num x dim] where num =
%%                              patchnum x number of image blocks
%%      centers         :       formed codebook [dim x codebook size]
%%      codebook_size   :       size of codebook
%%      patchnum        :       number of extracted patches
%%      f               :       number of image blocks (for training, it 
%%                              equals train_f)
%% Output
%%      histogram_all   :       formed bags [num x dim]
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com> 

histogram_all = [];                 %% to store all bags
nPoints = patchnum;                 %% patch number

%% Loop over all images
for i = 1:f
    %% extract feature from set of training features
    descriptor = trainbag((i-1)*nPoints+1 : i*nPoints, :)';
    
    %% Set distance matrix to all be large values
    distance = Inf * ones(nPoints,codebook_size);
    
    %% Loop over all centers and all points and get L2 norm btw. the two.
    for p = 1:nPoints
        for c = 1:codebook_size
            distance(p,c) = norm(centers(:,c) - double(descriptor(:,p)));
        end
    end
    
    %% Now find the closest center for each point
    [tmp,descriptor_vq] = min(distance,[],2);

    %% Now compute histogram over codebook entries for image
    histogram = zeros(1,codebook_size);
    for p = 1:nPoints
        histogram(descriptor_vq(p)) = histogram(descriptor_vq(p)) + 1;
    end
    histogram_all = [histogram_all; histogram];
end

