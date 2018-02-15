function [ full ] = full_check( queue_container,full,queue_length,driver,n_queues )
%FULL_CHECK Summary of this function goes here
%   Detailed explanation goes here



%% Identify Full Queues
for i = 1:1:n_queues
    cur_queue = queue_container(:,i); %access the current queue
    n_veh_in_queue = nnz(cur_queue);
    
    if n_veh_in_queue > 0
    n_last_vehicle = cur_queue(n_veh_in_queue);  %get the index number of the last ehicle in the queue    
    last_v_pos = driver(n_last_vehicle).current_position; %save the last vehicle position... I guess? It's the last vehicle index

    % We're going to do a sanity check wherein if a vehicle is positioned
    % at the very end of the queue, we don't allow another vehicle to enter
    % the queue. 
    if abs(last_v_pos-queue_length(i)) <= 10  
        full(i) = 1;
    else
    end
    else
    end
end


end

