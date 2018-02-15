function [ output_args ] = stops_in_time( input_args )
%STOPS_IN_TIME Summary of this function goes here
%   Detailed explanation goes here
            

            % This is the check for whether or not the queue is still
            % active. If we have an active queue we just switch even if the
            % action is taken. The signal should be able to guess this or
            % have it communicated. 
            RHS = (vlist(i).veh_velocity.^2)/abs((2.*vlist(i).desired_deceleration)); %length of time it'll take to stop the vehicle I am pretty sure
            dist_remaining = vlist(i).stop_bar_dist;


end

