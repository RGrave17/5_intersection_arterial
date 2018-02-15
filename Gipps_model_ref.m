function [ vehicle_list_out, queue_length_out,system_delay,n_served,split_list] = Gipps_model_ref( active_list, vlist,system_delay,time_step_size,queue_length,queue_dist)
%% we honestly need to loop through every queue... and update the active queues first? 
    %active_list, vlist,system_delay,time_step,queue_length,queue_dist
    %% unpack the vehicle struct because it's annoying.
    
%     vehicle_struct = struct('desired_vel', desired_vel_main,...
% 'safe_time_headway', safe_time_headway,...
% 'max_acceleration', max_acceleration,...
% 'desired_deceleration', desired_deceleration,...
% 'acceleration_exponent', acceleration_exponent,...
% 'minimum_distance', minimum_distance,...
% 'vehicle_length', vehicle_length,...
% 'app_react_time', time_step_size,... 
% 'veh_route', route,...
% 'route_progress',1,...
% 'veh_velocity',desired_vel_main,...
% 'queue_position',0,...
% 'timer',0,...
% 'vehicle_size',vehicle_length,...
% 'veh_position',100,...
% 'predicted_time',predicted_time,...
% 'predicted_split',predicted_split_time,...
% 'nth_queue',queue_no,...
% 'split_timer',0); %position is a placeholder I think
%     

    % for each vehicle we're going to calculate the forward vehicles. We're
    % not going to update positions or anything immidiately like we were
    % doing in the last iteration, merely populate a list of forward
    % vehicles...
    

    R_forward = zeros(1,numel(vlist));
    X_forward = zeros(1,numel(vlist));
    V_forward = zeros(1,numel(vlist));
    B_forward = zeros(1,numel(vlist));

    
    
    for i=1:1:numel(vlist)
        
        queue_index = vlist(i).route_progress;
        
        if numel(vlist(i).nth_queue) > vlist(i).route_progress
            next_queue = 1;
            if queue_length(vlist(i).nth_queue(queue_index+1))== 0
                empty_queue = 1;
            else
                empty_queue = 0;
            end 
        else
            empty_queue = 0;
            next_queue = 0;
        end
        
        
        if vlist(i).queue_position == 1
        if next_queue == 0 || empty_queue == 0
            %the next queue is empty or we don't have a next queue
            X_forward(i) = 100;
            V_forward(i) = vlist(i).veh_velocity;
            B_forward(i) = vlist(i).desired_deceleration;
            R_forward(i) = time_step_size;                      
        else
            %the next queue has someone in it!
            
            for k=1:1:numel(vlist)
                if i~=k
                    if vlist(i).nth_queue(queue_index+1) == vlist(k).nth_queue(vlist(k).route_progress) && vlist(k).queue_position == queue_length(vlist(k).nth_queue(vlist(k).route_progress))
                                X_forward(i) = vlist(i).veh_position+(queue_dist(vlist(k).nth_queue(vlist(k).route_progress))- vlist(k).veh_position);
                                V_forward(i) = vlist(k).veh_velocity;
                                B_forward(i) = vlist(k).desired_deceleration;
                                R_forward(i) = time_step_size;  
                    else
                    end
                else
                end
            end
            
            
        end
        else %someone else is in the queue with us!
            
            for k=1:1:numel(vlist)
                if i~=k
                    if vlist(i).nth_queue(queue_index) == vlist(k).nth_queue(vlist(k).route_progress) && vlist(k).queue_position == vlist(i).queue_position-1
                                X_forward(i) = vlist(i).veh_position-vlist(k).veh_position;
                                V_forward(i) = vlist(k).veh_velocity;
                                B_forward(i) = vlist(k).desired_deceleration;
                                R_forward(i) = time_step_size;  
                    else
                    end
                else
                end
            end
            
        end
        
        
    %so we've set it up, but if the queue is inactive we need to see if the vehicle can stop in time.
    %if it can, we set up the phantom. If it can't, we don't. 
    if ~ismember(vlist(i).nth_queue(vlist(i).route_progress),active_list) %if the queue is not active        
        stop_bar = 5;
        RHS = (vlist(i).veh_velocity.^2)/abs((2.*vlist(i).desired_deceleration)); %length of time it'll take to stop the vehicle I am pretty sure
        dist_remaining = vlist(i).veh_position - stop_bar;
        if dist_remaining>= RHS
            X_forward(i) = dist_remaining;
            V_forward(i) = 0;
            B_forward(i) = -3;
            R_forward(i) = time_step_size;  
        else %we cant' stop in time
        end

    else %if the queue is active
        
    end
        

    
    end

    %%
    
    
    i=1;
    current_n_vehicles = numel(vlist);
    while i<=current_n_vehicles
        
        V_current = vlist(i).veh_velocity;
        R_apparent= time_step_size;
        V_desired = vlist(i).desired_vel;
        A_current = vlist(i).max_acceleration;
        B_current = vlist(i).desired_deceleration;
        S_current = vlist(i).vehicle_size;
        
        Ga = V_current+(2.5*A_current*R_apparent*(1-(V_current/V_desired))*sqrt(.025+(V_current/V_desired)));
        Gd = B_current*R_apparent + sqrt(B_current^2*R_apparent^2 - B_current*((2*(X_forward(i)-S_current))-V_current*R_apparent-(V_forward(i)^2/B_forward(i))));
        
        
        
        
        new_vel = min(Ga,Gd);
        new_position = vlist(i).veh_position-vlist(i).veh_velocity*time_step_size;
        
        
        if new_position <= 0 && numel(vlist(i).nth_queue)>vlist(i).route_progress
            %come to the end of the queue but there's another one to go   
            
            
            queue_length(vlist(i).nth_queue(vlist(i).route_progress)) = queue_length(vlist(i).nth_queue(vlist(i).route_progress))-1;
            vlist(i).route_progress = vlist(i).route_progress+1;
            vlist(i).veh_position = queue_dist(vlist(i).nth_queue(vlist(i).route_progress)) + vlist(i).veh_position;
            vlist(i).timer = vlist(i).timer+time_step_size;
            
            queue_length(vlist(i).nth_queue(vlist(i).route_progress)) = queue_length(vlist(i).nth_queue(vlist(i).route_progress))+1; 
            vlist(i).veh_position = new_position;
            vlist(i).veh_velocity = new_vel;
            i=i+1;
         
        elseif  new_position <= 0 && numel(vlist(i).nth_queue)==vlist(i).route_progress
            %come to the end of the queue and we're done
            queue_length(vlist(i).nth_queue(vlist(i).route_progress)) = queue_length(vlist(i).nth_queue(vlist(i).route_progress))-1;
            %we just deleted this entry in vlist, so obviously it's going
            %to be decreased by 1. 
            if vlist(i).timer-vlist(i).predicted_time>0
            system_delay = system_delay+(vlist(i).timer-vlist(i).predicted_time);
            else
            end
            vlist(i) = [];
            %don't increment i because it's not something we need to do. We
            %just deleted an entry out of vlist so obviously it's fine. 
           current_n_vehicles = current_n_vehicles -1;
            
        else
            %not out of the queue yet
            vlist(i).timer = vlist(i).timer+time_step_size;
            vlist(i).veh_position = new_position;
            vlist(i).veh_velocity = new_vel;
                       i=i+1;
        end
   
    end
    
    
    %% now that we've done this shit
    % let's update the queue positions;
    qlist = 0;
    for n=1:1:numel(queue_dist) %for each queue
        clear qlist;
        qlist_i = 1;
        if queue_length(n)>0
            for k=1:1:numel(vlist) %run through the list of vehicles
                if vlist(k).nth_queue(vlist(k).route_progress) == n    %if the vehicle is in the queue in qu estion
                    qlist(qlist_i) = vlist(k).veh_position; %we'll go ahead and add it to a list of queues
                    qlist_i=qlist_i+1;
                else
                end
            end
            
            [sorted,index] = sort(qlist); %sort the qlist based on distance.
            for j=1:1:numel(qlist) %loop through the sorted queue list
                vlist(index(j)).queue_position = j;%assign the index of the lowest distance to veh queue 1.
            end
        else
        end
        
    end
    
    
    
    
    vehicle_list_out = vlist;
    queue_length_out=queue_length;
    n_served=0;
    split_list=0;    
    
    
    
    
    
    
    
    
    
    
end

