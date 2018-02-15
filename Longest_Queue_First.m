function [ active_phase ] = Longest_Queue_First(queue_length)
%UNTITLED3 Summary of this function goes here
%   for signal 5 it's the same as the given example:
%WL WT/R NL NT/R EL ET/R SL ST/R
%1  2    3   4   5  6    7   8

TO_FROM = [0 6 1 6
           2 0 2 5
           8 3 0 8
           7 4 4 0];

%             A B C D
%          A [0 6 1 6
%          B  2 0 2 5
%          C  8 3 0 8
%          D  7 4 4 0];
%again solve this with some mapping
config_corr = [7 3
               1 5
               2 6
               4 8];
       
config_mat(1,:,:) = [0 0 0 0
                    0 0 0 0
                    0 1 0 0 
                    1 0 0 0];           
            
config_mat(2,:,:) = [0 0 1 0
                    0 0 0 1
                    0 0 0 0
                    0 0 0 0];
                        
config_mat(3,:,:) = [0 1 0 1
                    1 0 1 0
                    0 0 0 0
                    0 0 0 0];
            
config_mat(4,:,:) = [0 0 0 0
                    0 0 0 0
                    1 0 0 1
                    0 1 1 0];
              %W      N       E      S
% Demand mean  219    1443    184    —
% Demand SD    10     82      18     —
% Left         0.3853 0.0447  0.2889 0.0312
% Through      0.4391 0.9407  0.5804 0.8982
% Right        0.1756 0.0147  0.1307 0.0706
%              1/6    3/8     5/2    4/7                 
lambda_mat = [0 .4391 .3853 .1756
              .5804 0 .1307 .2889
              .0147 .0447 0 .9407
              .0312 .0706 .8982 0];
%queue length is going to be fed in as a list of queues of index:
%WL WT/R NL NT/R EL ET/R SL ST/R
%1  2    3   4   5  6    7   8
% in the fture we can importa  mapping parameter to make this.
% queue_mapping()

Q = [0 queue_length(2) queue_length(1) queue_length(2)
     queue_length(6) 0 queue_length(6) queue_length(5)
     queue_length(4) queue_length(3) 0 queue_length(4)
     queue_length(7) queue_length(8) queue_length(8) 0];
W = zeros(4,1);

for k = 1:1:4
sumthing = 0;

    for i= 1:1:size(Q,1)
    for j = 1:1:size(Q,2)
        sumthing = sumthing + Q(i,j)*config_mat(k,i,j); 
    end    
    end
    W(k) = sumthing;
end


Kmat = [W(1)+W(2)+W(3), W(1)+W(2)+W(4),W(1)+W(3)+W(4),W(2)+W(3)+W(4)];

            
[maxval,phase_index] = max(Kmat);
active_phase = config_corr(phase_index,:);

end

