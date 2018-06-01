%% Use this script to load sequence and initial parameters. It is extracted 
%% and modified from Lim and Ross's code of IVT.  
%%
%% Following is a description of the options you can adjust for
%% tracking, each proceeded by its default value.
%%
%% For a new sequence , you will certainly have to change p.
%% To set the other options, first try using the values given for one of 
%% the demonstration sequences, and change parameters as necessary.
%%
%% p = [px, py, sx, sy, theta]; 
%% The location of the target in the first frame.
%% px and py        :        th coordinates of the centre of the box£»
%% sx and sy        :        the size of the box in the x (width) and y 
%%                           (height) dimensions, before rotation
%% theta            :        the rotation angle of the box
%% numsample        :        The number of samples used in the condensation
%%                           algorithm/particle filter.  Increasing this 
%%                           will likely improve the results, but make the 
%%                           tracker slower.
%% condenssig       :        The standard deviation of the observation 
%%                           likelihood.
%% ff               :        The forgetting factor of IVT. When doing the 
%%                           incremental update, 1 means remember all past 
%%                           data, and 0 means remeber none of it.
%% batchsize        :        How often to update the eigenbasis of IVT
%% affsig           :        These are the standard deviations of
%%                           the dynamics distribution, that is how much 
%%                           we expect the target object might move from 
%%                           one frame to the next.  The meaning of each
%%                           number is as follows:
%% affsig(1)        =        x translation (pixels, mean is 0)
%% affsig(2)        =        y translation (pixels, mean is 0)
%% affsig(3)        =        rotation angle (radians, mean is 0)
%% affsig(4)        =        x scaling (pixels, mean is 1)
%% affsig(5)        =        y scaling (pixels, mean is 1)
%% affsig(6)        =        scaling angle (radians, mean is 0)
%% tmplsize         :        The resolution at which the tracking window is
%%                           sampled.If your initial window (given by p) is
%%                           very large you may need to increase this.
%% maxbasis         :        The number of basis vectors to keep in the 
%%                           learned apperance model.
%%
%% Change 'title' to choose the sequence you wish to run.
%%
%% Setting dump_frames to true will cause all of the tracking results
%% to be written out as .jpg images in the subdirectory ./result/title.


%% specify sequence title
% title = 'boy';
title = 'occlusion1';
% title = 'ShopAssistant2cor';
% title = 'OneStopEnter1front';

%% save results or not
dump_frames = true;   
% dump_frames = false;  

%% select sequence and respective parameters 
switch (title)
    
    case 'ShopAssistant2cor';  p = [151,66,20,60,0.00];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
            'batchsize',5, 'affsig',[4,4,.003,.001,.004,.0001]);
    
    case 'occlusion1';         p = [149,82,54,60,0.02];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
            'batchsize',5, 'affsig',[4,4,.008,.006,.002,.001]);
    
    case 'boy';         p = [148,146,40,42,-0.08];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
            'batchsize',5, 'affsig',[5,5,.015,.008,.002,.001]);
        
    case 'OneStopEnter1front';  p = [35,134,20,58,0.00];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
            'batchsize',5, 'affsig',[5,5,.008,.002,.001,.001]);
        
    otherwise;  error(['unknown title ' title]);
end

%% load sequence
dataPath = ['data\' title '\'];

%% initial affine parameters
param0 = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];     %%p = [px, py, sx, sy, theta];   
param0 = affparam2mat(param0);

%% create folder to save results
opt.dump = dump_frames;
if ~isdir(['result/' title])
    mkdir('result/', title);
end


