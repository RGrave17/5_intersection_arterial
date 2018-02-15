function [ queue_container,vehicle_list,full ] = Gipps_Queue( queue_container,queue_length,vehicle_list,active_queues )
%GIPPS_QUEUE Summary of this function goes here
%   Detailed explanation goes here
% NOTE: Does not account for safety... Do this in the state change function
% because otherwise it'll be dumb.

% The problem I am reconciling now is that the decisions are made every 2.6
% seconds but we need a multi-step lookahead and we want to make sure
% everyone has crossed once we try and decide what's going on. So I think
% what we should do is modify our decision-engine to include the speed at
% which we're able to change state. If we assume we take a long enough time
% to gauruntee state change, then we have to allocate green or dynamic
% yellow time based on how long it will take "no stop" vehicles to move
% through the traffic light after the light itself has changed or we choose
% to change the light. If we look at this from a probibalistic perspective
% then it becomes a zero percent to change in the next second but a
% positive outcome later on down the road. Future transition probabilities
% are 1 based on when that vehilce passes. The other problem is the
% disconject between the additional time I've alloted for yellow light that
% I don't simulate the motion of the vehicle. I should make sure that I
% update the position of all of the vehicles based on the extra 2.5 seconds
% or I won't be able to account for vehicles crossing. If I arrive at this
% stage with vehicles still unable to sotop it's oignto be very confusing
% and potentially detrimental to the function of our agent.

%If we can assure that no queue is "inactive but moving still" then we can
%easily perform this update.
%% Notes:
% We'll create a subfunction to perform the actual Gipps update based on
% whichever queue we're processing. We'll output the new queues and update
% which vehicles are in whichever queue.
n_queues = 35;

processed_queues = zeros(1,n_queues); %variable to prevent "double processing" of queues

%% Check for Full queues
full = zeros(1,n_queues); %full queues are unable to accept more vehicles and therefore cause the preceding queue to become "inactive"
full = full_check(queue_container,full,queue_length,vehicle_list,n_queues);


%% Process full, inactive queues first
process_driver_list = [];
for i = 1:1:n_queues
    if ~ismember(i,active_queues) && full(i) == 1 % all queues who are not members of active queue list and are marked as "full"
        processed_queues(i) = 1;
        
        c_queue_size = nnz(queue_container(:,i));
        if c_queue_size > 0
            process_driver_list = [process_driver_list;queue_container(1:c_queue_size,i)];
        else
        end
        
    else
    end
end

if numel(process_driver_list) > 0
    for driver_ID = 1:1:numel(process_driver_list)
        %% Power pair
        driver = vehicle_list(process_driver_list(driver_ID));
        if driver.path(driver.current_state)  ~=36
            vehicle_list = vehicle_updater(driver,queue_container,vehicle_list,0); %This is the Gd Ga update. I think we should update velocities and positions here as well.
            [ queue_container,vehicle_list] = update_queues( driver, vehicle_list,queue_container,queue_length );
        else
        end
    end
else
end




%% Recheck for Fullness
full = zeros(1,n_queues); %full queues are unable to accept more vehicles and therefore cause the preceding queue to become "inactive"
full = full_check(queue_container,full,queue_length,vehicle_list,n_queues);

% we might add full queues to the list of inactivity...
%% Process the rest of the inactive queues
process_driver_list = [];
for i = 1:1:n_queues
    
    if ~ismember(i,active_queues) && processed_queues(i) == 0 %don't double-process
        processed_queues(i) = 1;
        
        c_queue_size = nnz(queue_container(:,i));
        if c_queue_size > 0
            
            c_queue_size = nnz(queue_container(:,i));
            if c_queue_size > 0
                process_driver_list = [process_driver_list;queue_container(1:c_queue_size,i)];
            else
            end
            
        else
        end
        
    end
    
end

if numel(process_driver_list) > 0
    for driver_ID = 1:1:numel(process_driver_list)
        %% Power pair
        driver = vehicle_list(process_driver_list(driver_ID));
        if driver.path(driver.current_state)  ~=36
            vehicle_list = vehicle_updater(driver,queue_container,vehicle_list,0); %This is the Gd Ga update. I think we should update velocities and positions here as well.
            [ queue_container,vehicle_list] = update_queues( driver, vehicle_list,queue_container,queue_length );
        else
        end
    end
else
end

%% Process Active QUeues
% Update queue by queue and if a vehicle can't enter the next queue, we
% stop processing that queue because it's "blocked"

% Ok, so we now have the number of queues who are full. We'll go through
% all queues that are full first and check for activity. We will then go
% through all non-full queues. If a queue is full and processed, we'll
% still perform a sanity check to make sure that the car can fit. Otherwise
% we will have to "close" taht queue. If, in the process of servicing an
% active queue, we attempt to put a car into a queue that is 'full' we will
% immidiatelly stop processing that queue.
process_driver_list = [];
for i = 1:1:n_queues
    
    if ismember(i,active_queues)
        
        c_queue_size = nnz(queue_container(:,i));
        processed_queues(i) = 1;
        
        if c_queue_size > 0
            
            c_queue_size = nnz(queue_container(:,i));
            if c_queue_size > 0
                process_driver_list = [process_driver_list;queue_container(1:c_queue_size,i)];
            else
            end
            
        else
        end
        
    else
    end
    
end

if numel(process_driver_list) > 0
    for driver_ID = 1:1:numel(process_driver_list)
        %% Power pair
        driver = vehicle_list(process_driver_list(driver_ID));
        if driver.path(driver.current_state)  ~=36
            vehicle_list = vehicle_updater(driver,queue_container,vehicle_list,0); %This is the Gd Ga update. I think we should update velocities and positions here as well.
            [ queue_container,vehicle_list] = update_queues( driver, vehicle_list,queue_container,queue_length );
        else
        end
    end
else
end

%disp(processed_queues);

end

