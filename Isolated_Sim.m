%% Arterial Model


%Naming conventions:

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

clear all; close all; clc
%% new stuff
active_green_time = zeros(1,5);
phase_duration_counter = zeros(1,5);
%% Demand REF
% In vehicles per hour 
% 8 different levels of demand. 
% [w N E S]
% Using poisson
% crystal_springs_demand = [0 0 179 1112];    %demand for cyrstal springs WNES
% second_ave_demand = [174 0 0 0];            %demand for second ave
% third_ave_demand = [270 0 238 0];           %demand for third ave
% fourth_ave_demand = [528 0 101 0];          %demand to fourth ave
% fifth_ave_demand = [219 1443 184 0];        %demasnd for fifth ave ALL IN V/HR

[n_queues,full_queues,arrival_rate_parameter,queue_distance,queue_container,phase_list,phase_index_list,green_time,delay,stop_time,amber_time,hyperqueue_list] = Cheating; %pull in all the cheating matrices

%% Random Variables:
time_step = 0;                      %seconds
time_step_size = .5;                %seconds
max_time =(15*(60))/time_step_size; %seconds sky is the limit time>15min
decision_cycle = 0;                 %next decision for traffic signals

%% initial States
system_delay =0;                    %system delay starting variable
n_served = 0;                       %number of served vehicles
active_phase_list = [1,7,20,37,49];

%% *********************************** LOOP *******************************************************************************************
% Next arrival we can calc 1 of 2 ways. Have Parrival based on probability
% of arrival in each subsequent time step or we can do a random roll at
% each time. Sum of bernoulli trials is a poisson process. 
next_arrival_times = arrival_times(arrival_rate_parameter);

vehicles_exist_flag = 0;
UID = 1;                            %set the unique identifier as 1 to start
heartbeat = 1;
time = 0;

while time <= max_time
time = time+time_step_size;   %increment the time step size

%% &&&&&&&& VEHICLE ARRIVAL &&&&&&&&&&&&&&&
% This now outputs a set of vehicle structs which contain the vehicles'
% MAKE SURE WE CANT SPAWN A VEHICLE IN A FULL QUEUE
% path. 
if UID>1
UID = numel(vehicle_list)+1; %if the UID is above 1 (a vehicle has been added) then increment the UID by 1 
end

for j=1:1:numel(next_arrival_times)
    if next_arrival_times(j) <= time %if the time has passed the next arrival time then inject a vehicle
        source_queue = source_roller(j);
        if ~full_queues(source_queue) %if the queue is currently full, don't generate vehicle or new arrival. 'bank' the new arrival. 
        % Generate the vehicle
        if vehicles_exist_flag == 0
        vehicle_list = [];
        [veh_struct,full] = random_veh_gen(source_queue,queue_distance,UID,queue_container,vehicle_list,time_step_size); %generate a reandom vehicle and get the new queue lengths (don't nee dot do queue lengths in here
        clear vehicle_list;
        else
        [veh_struct,full] = random_veh_gen(source_queue,queue_distance,UID,queue_container,vehicle_list,time_step_size); %generate a reandom vehicle and get the new queue lengths (don't nee dot do queue lengths in here    
        end
        if full ~= 1
        vehicle_list(UID) = veh_struct; %assign the struct to the array of vehicles
        vehicles_exist_flag = 1;
        
        
        % Put the vehicle in queue container
        queue_container = queue_container_inject(queue_container,UID,source_queue,n_queues);
        
        % prepare for next arrival
        UID = UID + 1; %increment UID
        next_arrival_gap = arrival_times(arrival_rate_parameter); %time distance to next arrivals
        next_arrival_times(j) = time + next_arrival_gap(j);        %assign a next arrival time to that generation point
        else
        end
        else
        end
    else
    end
end


%% &&&&&&&&&& UPDATE CHEATS &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if vehicles_exist_flag
%     vehicle = vehicle_list(1);
%     disp(vehicle.current_position);
[green_time,delay,amber_time,cars_in_phase] = update_cheats(vehicle_list,queue_container,phase_list,green_time,delay,amber_time);

%% Display Cheats
% figure(4)
% bar(delay);
% title('delay as calculated by cheats')
% grid on

%% Active Phase (Spoof for testing)


% active_queue_list = zeros(4,numel(active_phases));
clear active_queue_list;

for intersection_ID = 1:1:5
    if phase_duration_counter(intersection_ID) <= 0 || phase_duration_counter(intersection_ID) > 25 %if the phase counter is zero or below, update
        [active_green_time(intersection_ID),active_phase_list(intersection_ID) ] = fifth_avenue(cars_in_phase,phase_index_list, delay,green_time,amber_time,intersection_ID,active_phase_list(intersection_ID),phase_list,queue_container,vehicle_list); %will eventually need (current_state,queue)
        phase_duration_counter(intersection_ID) = max([5,active_green_time(intersection_ID)]);
    else %if phase counter is above zero, just decriment
        phase_duration_counter(intersection_ID) = phase_duration_counter(intersection_ID)-1;
    end



end
fprintf('active queue times are:\n 1:%f 2:%f 3:%f 4:%f 5:%f\n',...
    active_green_time(1),active_green_time(2),active_green_time(3),active_green_time(4),active_green_time(5));
fprintf('active queue times are:\n 1:%f 2:%f 3:%f 4:%f 5:%f\n',...
    active_phase_list(1),active_phase_list(2),active_phase_list(3),active_phase_list(4),active_phase_list(5));
% Hard coded active phases to let main street go through
% active_phase_list = [5, 15, 32, 44, 62];
for ph = 1:1:numel(active_phase_list)
    active_queue_list(:,ph) = phase_list(active_phase_list(ph),:);
end


%% Display active Queues
queue_display = zeros(36,1);
for k = 1:1:36
    if any(any(active_queue_list == k))
        queue_display(k) = 1;
    else
        queue_display(k) = 0;
    end 
end



%% Mild vehicle update
% Figure out whether or not drivers can stop in time
vehicle_list = driver_status_update(vehicle_list,active_queue_list);


%% Advance Vehicle Positions
[ queue_container,vehicle_list,full ] = Gipps_Queue( queue_container,queue_distance,vehicle_list,active_queue_list );


%% Display Queue sizes and Delay Values at each time step
queue_delay = zeros(36,1);
queue_size = zeros(36,1);
for k = 1:1:numel(vehicle_list)
    
    if vehicle_list(k).path(vehicle_list(k).current_state) ~= 36 %if the driver is in queue 36 we should just leave him and not let him increment
        vehicle_list(k).delay = vehicle_list(k).delay + vehicle_list(k).time_step_size;
    end
    
    queue_delay(vehicle_list(k).path((vehicle_list(k).current_state))) = queue_delay(vehicle_list(k).path((vehicle_list(k).current_state))) + vehicle_list(k).delay;   
    queue_size(vehicle_list(k).path((vehicle_list(k).current_state))) = queue_size(vehicle_list(k).path((vehicle_list(k).current_state))) + 1;
end


figure(1)
bar(queue_display);
title('Active Queue List (binary)');
grid on
xlim([0,35])
xticks(0:1:35)
figure(2)
bar(queue_delay);
title('queue delay (seconds)')
grid on
xlim([0,36])
xticks(0:1:36)

figure(3)
bar(queue_size);
title('queue size (number of cars)')
grid on
xlim([0,36])
xticks(0:1:36)


drawnow


else
end
end
