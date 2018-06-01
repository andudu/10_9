function [ LBPHIST SZ ] = uniform_PR_LBPfeatures(Image,ImageSize,BlockSize,PR,MAPPING,MODE)
%%
%% [ LBPHIST SZ ] = uniform_PR_LBPfeatures(Image,ImageSize,BlockSize,PR,MAPPING,MODE)
%% 
%% Input:   
%%          Image       :   image data 
%%          ImageSize   :   the size of image data
%%          BlockSize   :   the size of image block
%%          PR          :   The LBP codes are computed using N sampling points on a 
%%                          circle of radius R and using mapping table
%%                          defined by MAPPING.
%%          MAPPING     :   
%%                           MAPPING = GETMAPPING(SAMPLES,MAPPINGTYPE) returns a mapping for
%%                           LBP codes in a neighbourhood of SAMPLES sampling
%%                           points. Possible values for MAPPINGTYPE are:
%%                                              'u2'   for uniform LBP      
%%                                              'ri'   for rotation-invariant LBP
%%                                              'riu2' for uniform rotation-invariant LBP.
%%          MODE        £º   'h' or 'hist'  to get a histogram of LBP codes
%%                           'nh'           to get a normalized histogram
%% Output:
%%          LBPHIST     :   the lbp histogram of Image Block
%%
%% COPYRIGHT:   DIPLAB      wangdong    2008-12-08
%%
LBPHIST = [];
P = PR(1);
R = PR(2);
regionH = BlockSize(1);
regionW = BlockSize(2);
sx = ImageSize(2);
sy = ImageSize(1);
numberx = floor(sx/regionW);
numbery = floor(sy/regionH);

X = zeros(regionH,regionW);
for m = 1:numbery   
    for n = 1:numberx   
        a1 = 1+(m-1)*regionH;
        a2 = m*regionH;
        b1 = 1+(n-1)*regionW;
        b2 = n*regionW;
        X = Image(a1:a2,b1:b2);
        LBPHIST_TEMP = lbp(X,R,P,MAPPING,MODE);
        LBPHIST = cat(2,LBPHIST,LBPHIST_TEMP);
    end
end

SZ = size(LBPHIST);
SZ = SZ(2);


