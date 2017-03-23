function object = generateNewObject(mode)

    if(strcmp(mode,'random'))
            new_target_vx = randi(7)-4;
            new_target_vy = randi(7)-4;
            new_target_x = 10*rand(1); % spawn new target gaussian
            if(new_target_x > 10)
                new_target_x = 10;
                new_target_vx = -1*abs(new_target_vx);
            elseif(new_target_x < 0)
                new_target_x = 0;
                new_target_vx = abs(new_target_vx);
            end
            new_target_y = 10*rand(1); % spawn new target gaussian
            if(new_target_y > 10)
                new_target_y = 10;
                new_target_vy = -1*abs(new_target_vy);
            elseif(new_target_y < 0)
                new_target_y = 0;
                new_target_vy = abs(new_target_vy);
            end
            Pd = 0.7;
            object = [new_target_x; new_target_y;new_target_vx;new_target_vy; Pd];
            return;
    end
    if(mode == 1)
        new_target_x = 0;
        new_target_y = 0;
        new_target_vx = 0;
        new_target_vy = randi(2);
    elseif(mode == 2)       
        new_target_x = -2.5;
        new_target_y = 2;
        new_target_vx = randi(2);
        new_target_vy = 0;
        
    elseif(mode == 3)
        new_target_x = -1;
        new_target_y = 10;
        new_target_vx = 0;
        new_target_vy = -1*randi(2);
    end
    Pd = 0.7;
    object = [new_target_x; new_target_y;new_target_vx;new_target_vy; Pd];

end