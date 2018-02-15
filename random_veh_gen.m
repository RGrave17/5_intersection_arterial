function [vehicle_struct,full] = random_veh_gen(source_queue,queue_distance,UID,queue_container,vehicle_list,time_step_size)
%Random_veh_gen 
%   we're going to develop a random vehicle generator not so much to
%   generate random vehicles/drivers but more to figure out where they're
%   going to end up. 
full = 0;
%% OLD GIPPS PARAMS Do we need this?
desired_velocity = 35*0.44704;                      %m/s
time_headway = 1.5;                                 %seconds
max_acceleration = 1;                               %m/s^2
desired_deceleration = -3;                          %m/s^2
acceleration_exponent = 4;                          %????!?!?!?!?!??!
minimum_distance = 1;                               %meters
vehicle_length = 4.8;                               %meters
distance_to_stop_bar = queue_distance(source_queue)-30; %total meters - distance to clear
distance_to_clear = queue_distance(source_queue);
reaction_time = time_step_size;


%% NEW PARAMS
% make sure if a queue is full we can't spawn a vehicle

number_of_veh_in_queue = nnz(queue_container(:,source_queue));
if number_of_veh_in_queue == 0
current_velocity = 16; % m/s make this a random value based on the preceding vehicle in the queue. 
else
   vehicle_in_front_ID = queue_container(number_of_veh_in_queue,source_queue);
   %% IMPLEMENT SOMETHING TO CHECK FOR CRASHES
   current_velocity = 16.*((distance_to_clear-(vehicle_list(vehicle_in_front_ID).current_position+4.8))/distance_to_clear);
end

%% Pathfinding

T = transition_matrix();
queue_path(1) = source_queue;
i = 1;
while queue_path(i) ~= 36
    movement = rand(); %get a random movement modifier
    end_state = 1;     %initialize the end state at 1
    while sum(T(queue_path(i),1:end_state)) < movement %if the sum of all the states probabiilities exceeds the random roll exit otherwise
        end_state = end_state + 1; %increment end state
    end
    i=i+1;
    queue_path(i) = end_state; %set the new current state as the end state
end

% This should yeild a list wherein the last number is always 36 (exit)



%%
if current_velocity < 0 
    full = 1;
    vehicle_struct = [];
else
vehicle_struct = struct('path',queue_path,...
                        'current_state', 1,...
                        'delay',1,...
                        'current_velocity',current_velocity,...
                        'current_position',queue_distance(source_queue),...
                        'desired_deceleration', desired_deceleration,...
                        'desired_velocity',desired_velocity,...
                        'max_acceleration',max_acceleration,...
                        'distance_to_clear',distance_to_clear,...
                        'clear_time',1,...
                        'stop_bar_distance', distance_to_stop_bar,...
                        'stop_distance',2,...
                        'reaction_time',time_step_size,...
                        'Ga',0,'Gd',0,...
                        'UID',UID,...
                        'stop_flag',0,...
                        'time_step_size',time_step_size,...
                        'vehicle_length',vehicle_length,...
                        'active_flag',1);
end

end

