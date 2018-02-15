function [vehicle_list] = vehicle_updater(driver,queue_container,vehicle_list,active_flag)
% Vehicle Update.... 
% So we're going to keep track of every driver related parameter here.
% We've got
% stops_in_time
% active_flag
% Ga
% Gd
% now all we have to do is select min of Ga or Gd and then we can update
% each driver's velocities and which queue they lie in. 

% if driver.UID == 3
%     disp(driver.current_position);
% end
%% check position in queue
% We're going to check the position of the drivers and find the next
% vehicle in queue. We're going to then assign the gipps paramters to this.
%
queue_no = driver.path(driver.current_state);
queue_position = find(queue_container(:,queue_no) == driver.UID);

lead_flag = 1; %set the lead flag to be 1 intiially
if queue_position == 1 %if the vehicle is actually the lead then we were correct
else  %otherwise we'll check every vehicle in front
    for q = queue_position-1:-1:1
        if vehicle_list(queue_container(q,queue_no)).stop_flag == 1 %if any vehicle in front is able to stop in time
            lead_flag = 0; %that vehicle is the lead, not this vehicle.
        else
        end
    end
end

if lead_flag == 0               %if the vehicle is not in the lead position
    vehicle_in_front = vehicle_list(queue_container(queue_position-1,queue_no));    %assign vehicle in front to next queue
    % ASSIGN FORWARD VEHICLE AS FORWARD ID
    d_forward = driver.current_position-vehicle_in_front.current_position; %assign values for forward vehicle
    v_forward = vehicle_in_front.current_velocity;
    b_forward = vehicle_in_front.desired_deceleration;
    r_forward = vehicle_in_front.reaction_time;
else
    if driver.active_flag == 1
        % If the light is active we can engage in following vehicle in the
        % next queue
        if driver.path(driver.current_state+1) == 36 % this is the end state
            % ASSIGN FORWARD VEHICLE AS ARBITRARY
            d_forward = driver.current_position-(driver.current_position - 100);
            v_forward = driver.current_velocity;
            b_forward = driver.desired_deceleration;
            r_forward = driver.reaction_time;
        else
            nnz_next_queue = nnz(queue_container(:,driver.path(driver.current_state+1)));
            if nnz_next_queue > 0
            vehicle_in_front = vehicle_list(queue_container(nnz_next_queue,driver.path(driver.current_state+1)));
            %ASSING LAST VEHICLE IN NEXT QUEUE AS FORWARD
            d_forward = driver.current_position + (vehicle_in_front.distance_to_clear - vehicle_in_front.current_position);
            v_forward = vehicle_in_front.current_velocity;
            b_forward = vehicle_in_front.desired_deceleration;
            r_forward = vehicle_in_front.reaction_time;
            else
            d_forward = driver.current_position-(driver.current_position - 1000);
            v_forward = driver.current_velocity;
            b_forward = driver.desired_deceleration;
            r_forward = driver.reaction_time;                
            end
        end
    else
        % If the light is inactive, we need to do one of the following
        % things. I'm going to check and add a new flag.
        if driver.stop_flag == 1
            d_forward = driver.stop_bar_distance;
            v_forward = 0;
            b_forward = 1;
            r_forward = driver.reaction_time;
        else
        % next queue
        if driver.path(driver.current_state+1) == 36 % this is the end state
            % ASSIGN FORWARD VEHICLE AS ARBITRARY
            d_forward = driver.current_position-(driver.current_position - 100);
            v_forward = driver.current_velocity;
            b_forward = driver.desired_deceleration;
            r_forward = driver.reaction_time;
        else
            nnz_next_queue = nnz(queue_container(:,driver.path(driver.current_state+1)));
            if nnz_next_queue > 0
            vehicle_in_front = vehicle_list(queue_container(nnz_next_queue,driver.path(driver.current_state+1)));
            %ASSING LAST VEHICLE IN NEXT QUEUE AS FORWARD
            d_forward = driver.current_position + (vehicle_in_front.distance_to_clear - vehicle_in_front.current_position);
            v_forward = vehicle_in_front.current_velocity;
            b_forward = vehicle_in_front.desired_deceleration;
            r_forward = vehicle_in_front.reaction_time;
            else
            d_forward = driver.current_position-(driver.current_position - 100);
            v_forward = driver.current_velocity;
            b_forward = driver.desired_deceleration;
            r_forward = driver.reaction_time;                
            end
        end
        end
    end
end
    
    
      

%% Updating Gipps params on the fly
% We are going to need to inject artificial things to cause stoppage at
% traffic signals which are currently active. 
% Ga Gd output
 driver.Ga = driver.current_velocity + 2.5*driver.max_acceleration*driver.time_step_size...
     *(1-(driver.current_velocity/driver.desired_velocity))*(.025+(driver.current_velocity/driver.desired_velocity))^(1/2);
 
 driver.Gd = driver.desired_deceleration*driver.time_step_size...
     +sqrt(     (driver.desired_deceleration^2)*(driver.time_step_size^2)...
                -driver.desired_deceleration*  (2*((abs(d_forward-driver.vehicle_length)))-driver.current_velocity*r_forward-((v_forward)^2/b_forward))       );
  
%% Moving Vehicle Forward


driver.current_velocity = max([min([driver.Ga,driver.Gd]),0]);
driver.current_position = driver.current_position-driver.time_step_size*driver.current_velocity;

driver.distance_to_clear = driver.current_position;
driver.stop_bar_distance = driver.current_position-35;

vehicle_list(driver.UID) = driver;

end

