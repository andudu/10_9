function [param, lbp_bag_feature, rgb_bag_feature] = bof_tracking(frm, cfrm, tmpl, param, opt, ...
                                                                  patchnum, f, lbp_histogram_all, rgb_histogram_all, ...
                                                                  rgb_centers, lbp_centers, codebook_size, train_f)
%% function [param, lbp_bag_feature, rgb_bag_feature] = bof_tracking(frm, cfrm, tmpl, param, opt, ...
%%                                                                   patchnum, f, lbp_histogram_all, rgb_histogram_all, ...
%%                                                                   rgb_centers, lbp_centers, codebook_size, train_f)
%%
%% This function is used for main tracking procedure. It includes particle 
%% sampling to generate candidates, training samples extraction, similarity 
%% computation and update samples collection, etc. Note that the threshold 
%% for refinement is empirical and may be not optimal.  
%% 
%% Function specification:
%% Input
%%      frm                 :       input frame (gray)
%%      cfrm                :       input frame (color)
%%      tmpl                :       structure to save images used for IVT
%%      param               :       structure to save affine params and image 
%%                                  of tracked object, etc.  
%%      opt                 :       structure to save sampling params (particle 
%%                                  number, sampling radius, forget factor of IVT, etc.)
%%      patchnum            :       number of extracted patches
%%      f                   :       frame index
%%      lbp_histogram_all   :       LBP trained bags [num x bin]
%%      rgb_histogram_all   :       RGB trained bags [num x bin]
%%      rgb_centers         :       RGB codebook [dim x codebook size]
%%      lbp_centers         :       LBP codebook [dim x codebook size]
%%      codebook_size       :       size of codebook
%%      train_f             :       number of training frames
%% Output
%%      param               :       see above 
%%      lbp_bag_feature     :       LBP features used for training and
%%                                  update [num x dim] 
%%      rgb_bag_feature     :       RGB features used for training and
%%                                  update [num x dim] 
%%
%% For details of IVT, please refer to 
%%      J. Lim, D. Ross, R. Lin, and M. Yang, ¡°Incremental learning
%%      for visual tracking,¡± in Proc. NIPS¡¯04, 2005, pp. 793¨C800.
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

n = opt.numsample;          %% number of particles
sz = size(tmpl.mean);       %% size of image block
N = sz(1)*sz(2);            %% number of pixels
patchsize = [12 12];        %% size of patch       
sigma = 0.05;               %% used in exp chi-square distance to compute bag similarity
th_r = 0.0035;              %% threshold of refinement

%% particle sampling
param.param = repmat(affparam2geom(param.est(:)), [1,n]);
param.param = param.param + randn(6,n).*repmat(opt.affsig(:),[1,n]);    %% Gaussian sampling
wimgs = warpimg(frm, affparam2mat(param.param), sz);                    %% sampled image blocks (gray)
diff = repmat(tmpl.mean(:),[1,n]) - reshape(wimgs,[N,n]);               %% difference with average image 
rwimgs = warpimg(double(cfrm(:,:,1)), affparam2mat(param.param), sz);   %% sampled image blocks (color)
bwimgs = warpimg(double(cfrm(:,:,2)), affparam2mat(param.param), sz);   %% sampled image blocks (color)
gwimgs = warpimg(double(cfrm(:,:,3)), affparam2mat(param.param), sz);   %% sampled image blocks (color)

%% IVT tracker, extracted from Lim and Ross's code
coefdiff = 0;
if (size(tmpl.basis,2) > 0)
    coef = tmpl.basis'*diff;
    diff = diff - tmpl.basis*coef;
    if (isfield(param,'coef'))
        coefdiff = (abs(coef)-abs(param.coef))*tmpl.reseig./repmat(tmpl.eigval,[1,n]);
    else
        coefdiff = coef .* tmpl.reseig ./ repmat(tmpl.eigval,[1,n]);
    end
    param.coef = coef;
end
if (~isfield(opt,'errfunc'))  opt.errfunc = [];  end
switch (opt.errfunc)
    case 'robust';
        param.conf = exp(-sum(diff.^2./(diff.^2+opt.rsig.^2))./opt.condenssig)';
    case 'ppca';
        param.conf = exp(-(sum(diff.^2) + sum(coefdiff.^2))./opt.condenssig)';
    otherwise;
        param.conf = exp(-sum(diff.^2)./opt.condenssig)';
end
param.conf = param.conf ./ sum(param.conf);
    
%% training
if f <= train_f
    [maxprob,maxidx] = max(param.conf);
    param.est = affparam2mat(param.param(:,maxidx));
    param.wimg = wimgs(:,:,maxidx);
    param.err = reshape(diff(:,maxidx), sz);
    param.recon = param.wimg + param.err;
    r = rwimgs(:,:,maxidx);
    b = gwimgs(:,:,maxidx);
    g = bwimgs(:,:,maxidx);
    [lbp_bag_feature, rgb_bag_feature] = bagblock( param.wimg, r, b, g, patchsize, patchnum );  %% collect training samples
    
%% tracking
else
    lbp_pconf = []; lbp_hconf = [];           %% initialize LBP smilarities  
    rgb_pconf = []; rgb_hconf = [];           %% initialize RGB smilarities
    lbp_feature = []; rgb_feature = [];       %% collect features for update
    lbp_sim = []; rgb_sim = [];               %% store similarity exp(-dist) of each pach 
    
    %% compute similarities of each candidate
    for i = 1:size(wimgs, 3)
        r = rwimgs(:,:,i);
        b = gwimgs(:,:,i);
        g = bwimgs(:,:,i);
        [lbp_bag_feature, rgb_bag_feature] = bagblock( wimgs(:,:,i), r, b, g, patchsize, patchnum );
        
        %% all similarities are computed here
        [lbp_psim, lbp_hsim, tmp_lbp_pconf] = patch_match( lbp_bag_feature', lbp_centers, patchnum, codebook_size, lbp_histogram_all, sigma );
        [rgb_psim, rgb_hsim, tmp_rgb_pconf] = patch_match( rgb_bag_feature', rgb_centers, patchnum, codebook_size, rgb_histogram_all, sigma );
        lbp_feature = [lbp_feature; lbp_bag_feature];
        rgb_feature = [rgb_feature; rgb_bag_feature];
        lbp_sim = [lbp_sim; tmp_lbp_pconf];
        rgb_sim = [rgb_sim; tmp_rgb_pconf];
        lbp_pconf = [lbp_pconf lbp_psim];
        lbp_hconf = [lbp_hconf lbp_hsim];
        rgb_pconf = [rgb_pconf rgb_psim];
        rgb_hconf = [rgb_hconf rgb_hsim];
    end

    lbp_pconf = lbp_pconf ./ sum(lbp_pconf);            %% patch similarity
    rgb_pconf = rgb_pconf ./ sum(rgb_pconf);
    lbp_hconf = lbp_hconf ./ sum(lbp_hconf);            %% bag similarity
    rgb_hconf = rgb_hconf ./ sum(rgb_hconf);
    ratio = lbp_hconf ./ (lbp_hconf + rgb_hconf);       %% compute bag weight
    
    %% reform data to avoid ratio = NaN
    tmp = isnan(ratio);
    idx = find(tmp == 1);
    ratio(idx) = 0.5;
    
    bow_conf = ratio .* lbp_pconf + (1-ratio) .* rgb_pconf;     %% use bag sim to weight patch sim
    bow_conf = bow_conf ./ sum(bow_conf);                       %% normalize
    
    %% find the object
    dd = max(bow_conf);                                         %% find maximum
    if dd >= th_r                                               %% refinement inactive
        param.conf = bow_conf';
        [maxprob,maxidx] = max(param.conf);                     
        param.est = affparam2mat(param.param(:,maxidx));        %% affine param of the tracked object
        param.wimg = wimgs(:,:,maxidx);
        param.err = reshape(diff(:,maxidx), sz);
        param.recon = param.wimg + param.err;
    else                                                        %% refinement active
        [maxprob1,maxidx1] = max(param.conf);                   %% best of IVT tracker
        [maxprob,maxidx] = max(bow_conf);                       %% best of original bof tracker
        
        %% combination of IVT tracker and bof tracker, the same as that we 
        %% report in the paper. It can handle pose changes well and produce 
        %% stable results, but tends to fail under some complex situations.
        param.est = 0.7*affparam2mat(param.param(:,maxidx1))+0.3*affparam2mat(param.param(:,maxidx));
        
        %% alternatively, you can also use the previous result to weight
        %% the current result without IVT refinement. Then IVT is only used
        %% to collect training samples and can be substituted by other 
        %% methods. This strategy is more robust to complex background than 
        %% the above method, but results may be less stable, especially when 
        %% occlusion occurs.
        %  param.est = 0.7*param.est+0.3*affparam2mat(param.param(:,maxidx));       %% uncomment it if you do not 
                                                                                    %% use IVT to refine results 
        
        param.wimg = warpimg(frm, param.est, sz);
        param.err = reshape(tmpl.mean(:) - param.wimg(:),sz);
        param.recon = param.wimg + param.err;
    end

    %% collect good patches for update
    [ lbp_bag_feature, rgb_bag_feature ] = update_feature( lbp_feature(patchnum*(maxidx-1)+1:patchnum*maxidx,:),...
                                           rgb_feature(patchnum*(maxidx-1)+1:patchnum*maxidx,:),...
                                           lbp_sim(maxidx,:), rgb_sim(maxidx,:),...
                                           lbp_pconf(maxidx), rgb_pconf(maxidx));
end
