function [green_time,active_phase ] = fifth_avenue(cars_in_phase,phase_index_list, delay,greentime, amber_time,intersection_ID,current_state,phase_list,queue_container,vehicle_list) %will eventually need (current_state,queue)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Input List
phase_subset = phase_index_list(intersection_ID,1):phase_index_list(intersection_ID,2); %phases controlled by this traffic signal

current_cars = cars_in_phase(phase_subset);                                             %get the subset of cars affected by this light
current_state = find(phase_subset == current_state);                                    %which of controlled phases is currently active
n_states = numel(phase_subset);                                                         %number of total states
greentime_list = greentime(phase_subset);                                               %green time it will take to completely clear the phase
total_time = delay(phase_subset);                                                       %total delay accrued per second by each phase 


green_weights = (1/n_states) .* ones(1,n_states);   %initialize the green time weights
negotiations = 1;                                   %initialize the number of negotiations
weight_negotiation_error = 1;                       %initialize the negotiation error

while weight_negotiation_error > .001 && negotiations < 1000    %max limit for negotiations at this signal
%% Update Green times
%based on the new weights calculated below
greentime_list = greentime_list.*green_weights; %intialize greentimes

%% DELAY PENALTY
%for each state (phase) calculate the time lost by other phases through
%servicing the current phase. 
current_delay_penalty = zeros(1,n_states);                                  %initialize current penalty
for i=1:1:n_states
    %delay prediction: (green time we're going to deploy multiplied by all cars not serviced 
    future_delay = sum(current_cars).*greentime_list(i) - current_cars(i).*greentime_list(i);
    current_delay_penalty(i) = (sum(total_time)-total_time(i)) + future_delay; %The sum of all other delays minus a selected phase delay
    % total time only includes currently approximated delay and not amber
    % time delay. It also doesn't consider cars in our current phase
    % because it doesn't perceive those cars to be delayed. No
    % consideration is given to whether or not these cars actually clear
    % the intersection. 
end

current_delay_penalty = current_delay_penalty.*-1; %make the delay penalty a negative value
%% AMBER PENALTY

%list of all amber penalties filtered by the phase subset 
amber_time_penalty = dynamic_amber_calc(phase_subset, phase_list,greentime_list,queue_container,vehicle_list);
amber_time_penalty = amber_time_penalty * -1;
%% Rewards for now:
%it doesn't matter what my current state is for now, I'll impose a small
%booboo for switching. However, I need to make the agent aware that by
%choosing another action it stands to lose the value of teh state given. 
rewards = zeros(n_states,n_states,n_states);
for action=1:1:n_states
    for start_state =1:1:n_states
        for landed_state =1:1:n_states
            if start_state==landed_state
                rewards(action,start_state,landed_state) = current_delay_penalty(action);
            else
                rewards(action,start_state,landed_state) = current_delay_penalty(action)+amber_time_penalty(start_state);
            end
        end
    end
end

%% Value it

Vtemp = zeros(1,n_states);
                max_error = 10;
                while max_error> .001
                    
                    V = Vtemp;
                    for start_state = 1:1:n_states
                        
                        sumthing = zeros(1,n_states);
                        for landed_state = 1:1:n_states
                            for action = 1:1:n_states
                                if action == landed_state
                                    sumthing(action) = sumthing(action)+(rewards(start_state,landed_state,action)+0.8*V(landed_state));
                                else
                                end
                            end
                        end
                        
                        Vtemp(start_state) = max(sumthing);
                    end
                    error = abs(V-Vtemp);
                    max_error = max(error);
                end
                
                
                
                Q = zeros(n_states,action);
                for start_state = 1:1:n_states
                    for action = 1:1:n_states
                        sumthing = 0;
                        for end_state = 1:1:n_states
                            if action == end_state
                            sumthing = sumthing+V(end_state);
                            else
                            end
                        end
                        Q(start_state,action) = V(start_state) + 0.8*sumthing;
                    end
                end
                
                %% Update P values based on Q values
                green_weights_n = zeros(1,n_states);
                for action = 1:1:n_states
                    green_weights_n(action) = Q(current_state,action)/(sum(Q(current_state,:)));
                end
                sumsq=0;
                for weight = 1:1:n_states
                    sumsq = sumsq+((green_weights(weight)-green_weights_n(weight))^2);
                end
                weight_negotiation_error = sqrt(sumsq);
                
                green_weights = green_weights_n;
                
                negotiations = negotiations+1;

end

current_Q = Q(current_state,:);
[Q_Val,state] = max(current_Q);



active_phase = phase_subset(state);
green_time = greentime_list(state);

end

