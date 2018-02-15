function [n_queues,full_queues,demand_per_second,n_queue_dist, queue_container,phase_list,phase_index_list,greentime,delay,stop_time,amber_time,hyperqueue_list] = Cheating()
%% We're going to cheat
% queue_container: container for all cars in each queue
% phase_list: contains index values for all queues in each phase buffered
% with zeros
% phase_index_list: assigns the index range for the phase list contained at
% each intersection
% greentime: lists all the 'greentime values for each phase'
% delay: lists all the delay values aggregated for each phase
% stop_time: lists by queue whether or not a vehicle will be able to stop
% in time.
% clear_time: lists by queue the length of time required for all cars to
% safely pass. 
%% Number of queues
n_queues = 36;

%% INIT ALL QUEUES AS NOT FULL

full_queues = zeros(1,n_queues);
%% *************************** VEHICLE DEMAND LEVELS AND VARIABLES **************************************************
%need a demand mapping system for source to actual queues because we only
%have a demand rating in terms of the direction
demand_per_hour = [1112, 179, 174, 270, 238, 528,101,219,184,1443];

%                     %W   N  E S
%                [    0    0 179 1112
%                     174    0   0    0
%                     270    0 238    0
%                     528    0 101    0
%                     219 1443 184    0]; %combined demand values
        
demand_per_second = 1./(3600./demand_per_hour);

%% *********************************** PHYSICAL QUEUE PROPERTIES *******************************************************************
% Redo this as well since we need distances for each queue in terms of the
% new numbering system. 

n_queue_dist = [  308 1729 308 308 ,...                                                                %ft crystal_springs_dist
                  707 707 308 308 315 315,...                                                 %second_ave_dist
                  667 667 667 315 315 622 622 622 345 345,...                        %third_ave_dist
                  670 670 345 345 640 290 290,...                                   %fourth_ave_dist
                  673 673 290 290 1105 1105 1200 1200];                                 %fifth_ave_dist
              
n_queue_dist = n_queue_dist.*0.3048; %transform queue distances from feet into meters because everyting in meters

%% Hyperqueue Variables
% The "hyperqueue" is all feeder queues. So it should be only present along
% the N S line because all other lines end in sink. So, all of these exit
% queues
% These are the collected "exit" queues which form the hyperqueues

% hyperqueues are going to include side streets entering the main arterial.

N_hyperqueues = [6 10 14 18
               0 10 14 18
               0 0 14 18
               0 0 0 18];

S_hyperqueues = [16 12 8 4
                 0 12 8 4
                 0 0 8 4
                 0 0 0 4];

 N_queue_hyperqueu_link = [3 1
  4 1
  9 2
  10 2
  19 20
  26 27];

 S_queue_hyperqueue_link = [7 4
                          8 4
                          14 3
                          15 3
                          23 2
                          24 2
                          30 1
                          31 1];

hyperqueue_list= [];

%% PHASE VARIABLES
%straight passthrough = 
% phase 5, 15, 32, 44, 62
phase_list= [1 0 0 0; 2 0 0 0; 3 0 0 0; 4 0 0 0; 1 4 0 0; 3 4 0 0;...
            %7
             5 0 0 0; 6 0 0 0; 7 0 0 0; 8 0 0 0; 9 0 0 0; 10 0 0 0; ...
             5 10 0 0; 7 8 0 0; 8 9 0 0; 9 10 0 0; 6 7 8 0; 6 8 10 0; 8 9 10 0;...
            %20
             11 0 0 0; 12 0 0 0; 13 0 0 0; 14 0 0 0; 15 0 0 0; 16 0 0 0; 17 0 0 0; ...
             18 0 0 0; 19 0 0 0; 20 0 0 0; 14 15 0 0; 19 20 0 0; 15 20 0 0; ...
             14 19 0 0; 11 12 13 0; 16 17 18 0; 12 13 17 18; ...
            %37
             21 0 0 0; 22 0 0 0; 23 0 0 0; 24 0 0 0; 25 0 0 0; 26 0 0 0; 27 0 0 0;...
             24 27 0 0; 23 26 0 0; 21 22 0 0; 23 24 0 0; 26 27 0 0;...
            %49 
             28 0 0 0; 29 0 0 0; 30 0 0 0;31 0 0 0; 32 0 0 0; 33 0 0 0; 34 0 0 0; 35 0 0 0;...
             28 29 0 0; 30 31 0 0; 32 33 0 0; 34 35 0 0; 29 33 0 0; 31 35 0 0;...
             28 32 0 0; 30 34 0 0];

phase_index_list = [1,6
                    7,19
                    20,36
                    37,48
                    49,64];
 
%% MID LOOP VARIABLES
% update this for the actual size of the queues

queue_container = zeros(1,36);
greentime = zeros(1,64);
delay = zeros(1,64);
stop_time = zeros(1,64);
amber_time = zeros(1,64);



%% ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ EXTRA STUFF BELOW ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
% and have each queue be a unique ID which i can then access in order to
% easily facilitate the algorithm. Each hyperqueue will also be addressed
% in that it will be a list of queue IDs that will be accessed. The goal of
% doing this will be to allow for dynamic assessment of all intersections
% by a uniform algorithm. 
% W N E S
%in order a tuple We will define W N E S proceeding CCW 

Queue_ID_list = [1,4     %crystal
                 5,10    %second
                 11,20   %third
                 21,27   %fourth
                 28,35]; %fifth
             
% So I've got a matrix containing the max and min index of the queues contained
% in each intersection. I need to now make the following additional
% matrices

% 1: Matrix of hyperqueues by queue number. Need to think about in which
% order the queues are numbered. Remember that all input queues are
% accociated with output queues. There's no accounting for u-turns, so we
% assume that they don't exist. Additionally, the model we are working with
% only deals with single output lanes. 
 %W N E S as defined where W and E are always sinks 
 
 %going to make a list of the sinks W N E S and buffer with 0s
 exit_queue_list = [1 3 0 %sink       %W
                    2 4 0 %sink       %N  
                    0 0 0 %sink       %E
                    1 2 0       % 4   %S
                    0 0 0  %sink      %W
                    6 9 0       % 6   %N
                    7 10 0 %sink      %E
                    5 8 0       % 8   %S
                    12 15 19 %sink    %W
                    13 16 20    % 10  %N
                    14 17 20 %sink    %E
                    11 15 18    % 12  %S
                    22 24 26 %sink    %W
                    22 25 27    % 14  %N
                    23 25 27 %sink    %E
                    21 24 25    % 16  %S 
                    29 31 34 %sink    %W
                    29 32 35    % 18  %N
                    30 33 35 %sink    %E
                    28 31 33]; %sink  %S
                
