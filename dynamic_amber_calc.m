function [amber_time] = dynamic_amber_calc(phase_subset, phase_list,greentime,queue_container,vehicle_list)


%vehicle_list(i).stop_bar_distance 
%vehicle_list(i).current_velocity?

amber_time = zeros(size(phase_subset)); %amber time is equal to zeros the size of the phase subset (so the number of different phases that this signal controls)
n_phases = numel(phase_subset);         %get the number of phases for easier loop iteration later

% The queue container is queue(veh_no,queue_no);
for q =1:1:n_phases
    i = phase_subset(q);                %just a quick transform for my convenience later. I'd rather just deal with like 6 variables here than 64 or whatever
    n_queues = nnz(phase_list(i,:));    %number of queues in the phase 
    for p= 1:1:n_queues
        pth_queue = phase_list(i,p);                    %get one of the queues from the phase list
        n_cars = nnz(queue_container(:,pth_queue));     %the number of cars in the queue based on the queue ID (q)
        if n_cars > 0
            for j =1:1:n_cars
                jth_car = queue_container(j,pth_queue);
                %stop bar distance and stop distance calculated from the gipps
                %reference paper
                
                % So, we have greentime (amount of time that this will
                % be active. Amount of time that it takes to clear is
                % the difference between stop-bar-time and clear time
                % if the vehicle WONT stop. So we need that.
                %way we can get around this is to estimate where the car will be in
                %greentime seconds
                
                estimate_position_after_green = vehicle_list(jth_car).current_position - vehicle_list(jth_car).current_velocity * greentime(q); %estimated vehicle position post-greentime                
                clear_time_after_green = estimate_position_after_green/vehicle_list(jth_car).current_velocity;     %this is the time it will take for the vehicle to clear
                RHS = (vehicle_list(jth_car).current_velocity.^2)/abs((2.*vehicle_list(jth_car).desired_deceleration)); %length of time it'll take to stop the vehicle I am pretty sure
          
                if RHS>estimate_position_after_green
                    stops = 0;
                else
                    stops = 1;
                end
                
                if stops == 0 && amber_time(q) <= clear_time_after_green
                    amber_time(q) = (clear_time_after_green-greentime(q))+1.5;  %1.5 seconds all red. But the amber time should be the estimate for the clear time *FROM* the estimated position aftter green. 
                else
                    amber_time(q) = 1.5; %all red time;
                end
                
            end
        else
        end
    end
    
end

end