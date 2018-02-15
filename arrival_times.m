function [ arrival_time_array ] = arrival_times( demand_per_second )
%ARRIVAL_TIMES Summary of this function goes here
%   Detailed explanation goes here

arrival_time_array = zeros(1,10);
while ismember(0,arrival_time_array)
arrival_time_array = rand(1,10);    %zero out the next arrival time (Make this random)
end


arrival_time_array = ceil((-1.*log(arrival_time_array))./demand_per_second);


end

