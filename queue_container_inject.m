function [ queue_container ] = queue_container_inject( queue_container, UID, queue_no,n_queues)
%QUEUE_CONTAINER_INJECT Summary of this function goes here
%   Detailed explanation goes here
    if ~any(queue_container(:,queue_no)==0)
        queue_container = [queue_container;zeros(1,n_queues)];
        queue_container(end,queue_no) = UID;
    else
        n_contained = nnz(queue_container(:,queue_no));
        queue_container(n_contained+1,queue_no) = UID;        
    end
end

