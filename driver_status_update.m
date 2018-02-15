function [ vehicle_list ] = driver_status_update( vehicle_list,active_queue_list )
%vehicle_list(i)_STATUS_UPDATE Summary of this function goes here
%   Detailed explanation goes here
for i=1:1:numel(vehicle_list)
   %% Check if queue is active

if ismember(vehicle_list(i).path(vehicle_list(i).current_state),active_queue_list)
    vehicle_list(i).active_flag = 1;
else
    vehicle_list(i).active_flag = 0;
end

%% Check if vehicle is able to stop
% honestly need to do these 2 things beforehand I guess. 
distance_to_stop = (vehicle_list(i).current_velocity.^2)/abs((2.*vehicle_list(i).desired_deceleration)); %length of time it'll take to stop the vehicle I am pretty sure
dist_remaining = vehicle_list(i).stop_bar_distance;

if distance_to_stop > dist_remaining
    vehicle_list(i).stop_flag = 0;
else
    vehicle_list(i).stop_flag = 1;
end
        
    
end

end

