function [sorted_queues] = sort_queues(vlist,queue_length)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
longest_q = max(queue_length); %get max queue length
sorted_queues = zeros(numel(queue_length),longest_q);
% vlist is a list of all the vehicles. Queue length is a list of all
% queues. We need to do a few things.

for i=1:1:numel(queue_length) %for each queue

queue_subset = zeros(1,queue_length(i)); %init the queue as a set of zeros equal to the length of the quee
queue_position = queue_subset; %init the position ariables for each vehicle in the queue as zeroes
queue_subset_temp = queue_subset; %initialize a temp subset for sorting later
veh_no = 1; %identify the number of vehicles currently recorded in teh queue
for j = 1:1:numel(vlist) %for each vehicle
    if vlist(j).c_queue(vlist(j).p) == i %if the vehicle is currently in that quuee
        queue_subset(veh_no) = j; %assign the index of the vehicle to that queue
        queue_position(veh_no) = vlist(j).veh_position; %get the position of the vehicle and add it to the queue
        veh_no= veh_no+1; %increment the vehicle number index
    else
    end       
end

[sorted,pos_index] = sort(queue_position,'descend'); %after all vehicle are added to the subset, sort the distances to get the sorted indices
for k = 1:1:numel(queue_position) %for each entry of the sorted index list
    queue_subset_temp(k) = queue_subset(pos_index(k));    %create a temp subset that's sorted
end

sorted_queues(i,1:numel(queue_subset)) = queue_subset_temp; %inject the sorted array of indices into the sorted queue with buffered zeros. 


end


%empty queues will return all zeros. a zero indicates that the queue is of
%length equal to the number of nonzero items in that row. 

end

