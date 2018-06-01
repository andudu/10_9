%% Bag of Features Tracking Main Entry
%%
%% For more details, refer to
%%      Fan Yang, Huchuan Lu and Yen-Wei Chen, Bag of Features Tracking£¬
%%      International Conference on Pattern Recognition (ICPR), Istanbul, Turkey, 2010.
%%
%% Author: Fan Yang and Huchuan Lu, IIAU-Lab, Dalian University of
%% Technology, China
%% Date: 09/2010
%% Any bugs and problems please mail to <fyang.dut@gmail.com>

clc;
clear;
trackparam;		  %% read tracking parameters
warning('off');   %% close warning information
rand('state',0);  randn('state',0);

%% read sequence information
temp = importdata([dataPath 'datainfo.txt']);   %% specify path of sequence
LoopNum = temp(3);                              %% number of frames
iframe = imread([dataPath '1.jpg']);            %% read 1st frame
frame = double(rgb2gray(iframe))/256;           %% normalize

%% parameters required by IVT
if ~exist('opt','var')        opt = [];  end
if ~isfield(opt,'tmplsize')   opt.tmplsize = [32 32];  end                  
if ~isfield(opt,'numsample')  opt.numsample = 200;  end                    
if ~isfield(opt,'affsig')     opt.affsig = [4,4,.02,.02,.005,.001];  end   
if ~isfield(opt,'condenssig') opt.condenssig = 0.01;  end               
if ~isfield(opt,'maxbasis')   opt.maxbasis = 16;  end                 
if ~isfield(opt,'batchsize')  opt.batchsize = 5;  end                   
if ~isfield(opt,'errfunc')    opt.errfunc = 'L2';  end                   
if ~isfield(opt,'ff')         opt.ff = 1.0;  end                        
if ~isfield(opt,'minopt')
  opt.minopt = optimset; opt.minopt.MaxIter = 25; opt.minopt.Display='off';
end
  
%% extract image sample for initializing IVT tracker
tmpl.mean = warpimg(frame, param0, opt.tmplsize);       
tmpl.basis = [];                                     
tmpl.eigval = [];                                
tmpl.numsample = 0;                                  
tmpl.reseig = 0;                                  
sz = size(tmpl.mean);       %% size of image block                                   
param = [];                 
param.est = param0;         %% initial affine parameters                        
param.wimg = tmpl.mean;     %% used to store tracked object                   

%% draw initial tracking window    
drawopt = drawtrackresult([], 0, iframe, tmpl, param);
drawopt.showcondens = 0;  drawopt.thcondens = 1/opt.numsample;

%% other parameters
wimgs = [];                 %% store images for IVT update          
rst = [];                   %% store affine parameters of tracked objects
lbp_trainbag = [];          %% LBP features to construct codebook 
rgb_trainbag = [];          %% RGB features to construct codebook             
lbp_histogram_all = [];     %% trained LBP bags
rgb_histogram_all = [];     %% trained RGB bags
lbp_centers = [];           %% LBP codebook
rgb_centers = [];           %% RGB codebook
codebook_size = 20;         %% size of codebook
patchnum = 50;              %% number of patches within an image block
ff = 0.9;                   %% forget factor
train_f = 5;                %% number of training frames

%% tracking start
disp('tracking start...');
for f = 1:LoopNum
    iframe = imread([dataPath int2str(f) '.jpg']);
    frame = double(rgb2gray(iframe))/256;
    cframe = double(iframe);
    
    fno = sprintf('%d', f);
    disp(['now processing frame ' fno '...']);
    %% do tracking
    [param, lbp_bag_feature, rgb_bag_feature] = bof_tracking(frame, cframe, tmpl, param, opt, patchnum, f,...
                                                             lbp_histogram_all, rgb_histogram_all, ...
                                                             rgb_centers, lbp_centers, codebook_size, train_f);
    lbp_trainbag = [lbp_trainbag; lbp_bag_feature];
    rgb_trainbag = [rgb_trainbag; rgb_bag_feature];
    
    %% training to form codebooks and bags
    if f == train_f
        lbp_centers = form_codebook(lbp_trainbag', codebook_size);                       %% LBP codebook
        rgb_centers = form_codebook(rgb_trainbag', codebook_size);                       %% RGB codebook
        lbp_histogram_all = do_vq(lbp_trainbag, lbp_centers, codebook_size, patchnum, f);   %% LBP trained bags
        rgb_histogram_all = do_vq(rgb_trainbag, rgb_centers, codebook_size, patchnum, f);   %% RGB trained bags
        lbp_trainbag = [];
        rgb_trainbag = [];
    end
    
    %% codebook update
    if f > train_f && mod(f,train_f) == 0
        lbp_centers = update_codebook(lbp_trainbag', lbp_centers, codebook_size, ff);       %% update LBP codebook
        rgb_centers = update_codebook(rgb_trainbag', rgb_centers, codebook_size, ff);       %% update RGB codebook
        lbp_trainbag = [];
        rgb_trainbag = [];
    end
  
    %% IVT update, extracted from Lim and Ross's code 
    wimgs = [wimgs, param.wimg(:)];  
    if (size(wimgs,2) >= opt.batchsize) 
        if (isfield(param,'coef'))
            ncoef = size(param.coef,2);
            recon = repmat(tmpl.mean(:),[1,ncoef]) + tmpl.basis * param.coef;
            [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
            sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);          %%sklm:   incremental SVD algorithm
            param.coef = tmpl.basis'*(recon - repmat(tmpl.mean(:),[1,ncoef]));
        else
            [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
            sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
        end
        wimgs = [];     
        if (size(tmpl.basis,2) > opt.maxbasis)         
            tmpl.reseig = opt.ff * tmpl.reseig + sum(tmpl.eigval(opt.maxbasis+1:end));
            tmpl.basis  = tmpl.basis(:,1:opt.maxbasis);  
            tmpl.eigval = tmpl.eigval(1:opt.maxbasis);   
            if (isfield(param,'coef'))
                param.coef = param.coef(1:opt.maxbasis,:); 
            end
        end  
    end
  
    %% draw tracking result
    [drawopt, pp] = drawtrackresult(drawopt, f, iframe, tmpl, param); 
  
    %% store tracking result
    rst = [rst; param.est'];                                                  %% affine parameters of the tracked object  
    if (isfield(opt,'dump') && opt.dump > 0)          
        imwrite(frame2im(getframe(gcf)),sprintf('result/%s/%s.%04d.jpg',title,title,f));   %% save result images
    end
end

disp('tracking end...');

%% save affine parameters of tracking results
strFileName = sprintf('result/%s/%s.mat', title, title);
save(strFileName, 'rst');

