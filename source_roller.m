function [ source_queue ] = source_roller( source_queue_location )
%SOURCE_ROLLER Summary of this function goes here
%   Detailed explanation goes here

switchvar = rand;
switch(source_queue_location)
    case 1
        source_queue = 1;
    case 2
        source_queue = 2;
    case 3 %second ave westbound
        if switchvar < .6647
            source_queue = 5;
        else
            source_queue = 6;
        end
    case 4 %third ave westbound
        if switchvar < .4545
            source_queue = 11;
        elseif switchvar >= .4545 && switchvar < .2557+.4545
            source_queue = 12;
        else
            source_queue = 13;
        end
    case 5 %third ave eastbound
        if switchvar < .1191
            source_queue = 16;
        elseif switchvar >= .1191 && switchvar < .1191+.4873
            source_queue = 17;
        else
            source_queue = 18;
        end
    case 6 %fourth ave westbound
        if switchvar < .3351
            source_queue = 21;
        else
            source_queue = 22;
        end
    case 7 %fourth ave eastbound
        source_queue = 25;
    case 8 %fifth ave westbound
        if switchvar < .3853
            source_queue = 28;
        else
            source_queue = 29;
        end        
    case 9 %fifth ave eastbound
        if switchvar < .2889
            source_queue = 32;
        else
            source_queue = 33;
        end        
    case 10 %fift ave northbound
        if switchvar < .0447
            source_queue = 34;
        else
            source_queue = 35;
        end
end

end

