function [driver] = Gipps_model(queue_no,queue_container,isactive,driver,queue_length)
%I don't know if I want this to output the updated queues. I suppose what
%i'd rather do is suffer that in the main code based on whether the lowest
%values for active queues return values less than zero. 


% NOTE: vlist is some horrendously outdated list of vehicles in the queue.
% It comes down to just being the values of index associated w/ the queue
% in question. We are getting rid of it in favour of "driver" which
% contains all vehicles with associated index. They will never be cleared
% out so we can continually access them. 
queue_length = nnz(queue_container(queue_no,:)); %queue length starts from 1 = first vehicle to the last nonzero entry which is the last vehicle. 

% queue length is the number of vehicles in that queue == number of nonzero
% entries in that row. 

x_forward = zeros(queue_length,1); %forward vehicle positions
v_forward = zeros(queue_length,1); %forward vehicle velocities
b_forward = zeros(queue_length,1); %forward vehicle max brake params
r_forward = zeros(queue_length,1); %forward vehicle r params (question here)

   for i = 1:1:queue_length
        %if the index is zero, there are no more vehicles
        %queues are sorted in descending order. I'm changing it to where
        %the first vehicle in the queue is the first vehicle in the list.
        %So we want to go to the last nonzero entry and work our way in. 
        
        
        if i ~= 1 %this isn't the lead vehicle in the queue 
        f_index = queue_container(queue_no,i-1); %get hte index for the preceding vehicle (lower index value in the queue container) 
        x_forward(i) = driver(f_index).veh_position;  %use the position of tha tforward vehicle 
                v_forward(i) = driver(f_index).veh_velocity; %forward vehicle stats etc
                b_forward(i) = driver(f_index).desired_deceleration;
                r_forward(i) = time_step_size;
        else    
        end
        
        
        if i == 1 && isactive == 0
                f_index = queue_container(queue_no,i); %if the vehicle queue ID == 1 then we're the first in the queue. If the queue isn't active spoof a stopped car
                x_forward(i) = 0;
                v_forward(i) = 0;
                b_forward(i) = driver(f_index).desired_deceleration;
                r_forward(i) = time_step_size;
            
        elseif i == 1 && isactive == 1
             c_index = queue_container(queue_no,i); %index of the current vehicle 
             next_q = driver(c_index).next_queue;    %the next queue into which the vehicle will go. 
             nth_veh_next_q = nnz(queue_container(next_q,:));
             f_index = queue_container(next_q,nth_veh_next_q);
             x_forward(i) = -1*(queue_length(next_q)-driver(f_index).veh_position);
             v_forward(i) = driver(f_index).veh_velocity;
             b_forward(i) = driver(f_index).desired_deceleration;
             r_forward(i) = time_step_size;   
        else
        end
        
        
   end
   
   %the speed update wherein everything else was just assigning forward
   %vheicles to all the vehicle in the queue
   veh_in_queue=1;
    while veh_in_queue <= queue_length %ofr every vehicle in queue
        c_vehicle = queue_index(queue_no,veh_in_queue); %get the current vheicle
        xold = driver(c_vehicle).veh_position; %get the old position
        vcur = driver(c_vehicle).veh_velocity; %get the old veolicity
        acc = driver(c_vehicle).max_acceleration; %get max acceleration
        tau = time_step_size; %get the time step size
        bn = driver(c_vehicle).desired_deceleration; %get the desried deceleration
        
        % GIPPS paramters
        Ga = vcur + 2.5*acc*tau*(1-(vcur/driver(c_vehicle).desired_vel))*(.025+(vcur/driver(c_vehicle).desired_vel))^(1/2);
        Gd = bn*tau+sqrt((bn^2)*(tau^2)-bn*(2*((abs(xold-x_forward(veh_in_queue)-driver(c_vehicle).vehicle_size)))-vcur*tau-((v_forward(veh_in_queue))^2/bn)));
        
        xnew = xold-vcur*time_step_size; %new position 
        vnew = min(Ga,Gd); %new velocity
        driver(c_vehicle).veh_position = xnew; %store them in the vehicle struct
        driver(c_vehicle).veh_velocity = vnew;
        
        %next vehicle in the queue
        veh_in_queue=veh_in_queue+1;
    end
    
    %if update produces a position of less than zero, we'll add that to a
    %new queue and put it at the position overshot 
end