function [ queue_container,vehicle_list] = update_queues( driver, vehicle_list,queue_container,queue_length )
%UPDATE_QUEUES This function updates queues where people have passed the
%stop bars and cleared intersection
%   Once a queue has a vehicle which possesses a position of less than
%   zero, meaning he has passed the stop-bar, we will feed that queue into
%   this subfunction wherein the vehicle will be removed from teh queue, a
%   die will be rolled and we will figure out where the vehicles are going
%   (eventually)

%% Get Vehicle Positions:
% I think if a vehicle has dropped below zero. If this is the case, we will
% move the vehicle to the next queue. 


if driver.current_position <= 0 %this indicates that the vehicle is in the next queue or ready to make that transition

    
max_queue_length = size(queue_container,1);   
old_queue_no = driver.path(driver.current_state);
length_old_queue = nnz(queue_container(:,driver.path(driver.current_state)));
    
driver.current_state = driver.current_state + 1;
next_queue = driver.path(driver.current_state);
if driver.path(driver.current_state) ~= 36
driver.current_position = queue_length(driver.path(driver.current_state)); 
else
end
%% Break old queues
% If our max queue length is equal to the number of nonzero entries in the
% old queue. We need to see if that's the 'only' queue that has that many
% vehicles or if it's tied with another queue
if length_old_queue == max_queue_length %this is max queue length
    
queue_length_list = zeros(1,36); %queues 1 through 36 where 36 is the number of the dump queue
for i=1:1:36
    queue_length_list(i) = nnz(queue_container(:,i)); %list of queue lengths. 
end

longest_queues = find(queue_length_list == max_queue_length); %find all queues of longest length

if numel(longest_queues) == 1  %if this is the (only) longest queue, we will 
    temp_queue = zeros(size(queue_container,1)-1,size(queue_container,2)); %establish a zeros temp queue
    queue_container(:,old_queue_no) = [queue_container(2:end,old_queue_no);0]; %get the ueue container and shift all current queue members forward
    temp_queue(:,:) = queue_container(1:end-1,:); %set the temp queue equal to the subset of the old queue excluding the row of zeros
    queue_container = temp_queue; %set the container equal to the temp queue
    clear temp_queue %clear the queue
else %if it's not the only queue that's large
    queue_container(:,old_queue_no) = [queue_container(2:end,old_queue_no);0]; %get the ueue container and shift all current queue members forward
    % just shifting the members is enough
end

else %if it's not the largest queue then we just do the shift
    queue_container(:,old_queue_no) = [queue_container(2:end,old_queue_no);0]; %get the ueue container and shift all current queue members forward
    % just shifting the members is enough    
end


%% Add new queues
% so now we just need to append the vehicle to the new queue container
%if next_queue ~= 36
[ queue_container ] = queue_container_inject( queue_container, driver.UID, next_queue,36); %if the vehicle is still 'in service'
%else %otherwise we just let it evaporate. 
%end    


vehicle_list(driver.UID) = driver;

end

