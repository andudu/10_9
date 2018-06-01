This code is a Matlab implementation of the Bag of features tracking algorithm
described in
       Fan Yang, Huchuan Lu and Yen-Wei Chen, Bag of Features Tracking£¬
       International Conference on Pattern Recognition (ICPR), Istanbul, Turkey, 2010.

All important functions are commented. For details, please refer to the explanatory 
notes of respective .m files. 

The main function is tracker.m. Run it to see how tracking proceeds. The tracking 
results are saved in individual folders in the subdirectory ./result/ as .jpg format.
The affine parameters of the tracked object are also saved in the same folder in a
.mat file with the same name as the sequence. 

Images of sequences are in the subdirectory ./data/. We provide two of our own 
sequences and a public sequence. You can change initial parameters to run other 
sequences. Also, you can add your own testing sequences by specifying necessary 
parameters.

We thank for Fergus's code of bag of features and Lim and Ross's code of IVT 
and transformation of affine parameters.  

This code is the preliminary version. We appreciate any comments/suggestions. 
Questions regarding the code can be directed to Fan Yang (fyang.dut@gmail.com).

Fan Yang and Huchuan Lu, 
IIAU-Lab, Dalian University of Technology, China,
Sep. 2010