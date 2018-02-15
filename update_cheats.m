function [greentime,delay,amber_time,cars_in_phase] = update_cheats(vehicle_list,queue_container,phase_list,greentime,delay,amber_time)
% UPDATE_CHEATS: Function to update our global matrices for delay and
% greentime and amber time. 

%% GreenTime: 
% measure for the amount of time it would take to completely clear that
% queue. Do we include the hyperqueue values? We havent done the hyperqueue
% values yet... That's a problem. 

%we've got hyperqueue values = hard coded values for all the hyperqueues.
%Treat them the same way as the queues below for greentime and delay.

%include hyperqueue values in greentime. We'll go ahead and just add those
%in and not. Have a "hyperqueue" and a "non-linked" queue variety. When in
%doubt, just do both and forget about it. 

%I'm going to put the burdon on the car: calculate the time to the:
% 1. stop bar
% 2. other queue
% (1) is the time to clear the queue so it's the service time and the
% "green time" estimate
% (1+2) is the total time we lose to amber if we decide to stop on that
% vehicle and it cannot stop in time. 

% The queue container is queue(veh_no,queue_no);
n_phases = 64;
cars_in_phase = zeros(64,1);
for i =1:1:n_phases
    n_queues = nnz(phase_list(i,:)); %number of queues in the phase
    amber_time(i) = 0;
    greentime(i) = 0;
    delay(i) = 0;
    n_cars_in_phase = 0;
    for p= 1:1:n_queues
        %% Green time initial
        pth_queue = phase_list(i,p);
        n_cars = nnz(queue_container(:,pth_queue)); %the number of cars in the queue based on the queue ID (q)
        if n_cars > 0
            nth_car = queue_container(n_cars,pth_queue); %the ID of the last car in the row
            stop_bar_time = vehicle_list(nth_car).stop_bar_distance/vehicle_list(nth_car).current_velocity;
            if stop_bar_time > greentime(i)
                greentime(i) = stop_bar_time;
            end
        else
            greentime(i) = inf; %don't know how this will affect things. Make reward infinitely negative
        end
        
        %% Total queue delay and Amber Times
        
%         if n_cars > 0
%             for j =1:1:n_cars
%                 jth_car = queue_container(j,pth_queue);
%                 delay(i) = delay(i)+vehicle_list(jth_car).delay;
%                 stop bar distance and stop distance calculated from the gipps
%                 reference paper
%                 clear_time = vehicle_list(jth_car).current_position/vehicle_list(jth_car).current_velocity;
%                 if amber_time(i)<clear_time && vehicle_list(jth_car).stop_bar_distance < vehicle_list(jth_car).stop_distance
%                     amber_time(i) = clear_time; %if the amber time is the longest which is needed to clear all vehicles which can't stop.
%                 else
%                 end
%                 
%             end
%         else
%         end
        n_cars_in_phase = n_cars_in_phase + n_cars;
    end
    cars_in_phase(i) = n_cars_in_phase;
end





end



