function [z, zclutter] = generateMeasurements(targets, sigma,mode)
    z = cell(size(targets)); %zeros(size(targets,1),size(targets,2));
    zclutter = cell(1,size(targets,2));
    if(strcmp(mode,'std'))
        for t = 1 : size(targets,2) % for all time steps
            for j = 1 : size(targets{t},2) % for all targets at time t
                % Gaussian noise in measurement model
                % model is only distance+angle right now
                %z{t}(1,j) = norm(mvnrnd([targets{t}(1,j) targets{t}(2,j)], sigma));
                r1 = rand(1);
                if(r1 <= targets{t}(5,j))
                    x = [targets{t}(1,j) targets{t}(2,j)];
                    z{t} = [z{t}; norm(x+ sigma(1)*randn(1)), atan2(x(2),x(1))+sigma(2)];
                end
            end

            % Generate Clutter
            r2 = rand(1);
            if(r2 <= 96)
                % 1 clutter point
                zclutter{t} = [zclutter{t}; unifrnd(-5, 10), unifrnd(-pi/2, pi/2)];
            elseif(r2 <= 97)
                zclutter{t} = [zclutter{t}; unifrnd(-5, 10), unifrnd(-pi/2, pi/2)];
                zclutter{t} = [zclutter{t}; unifrnd(-5, 10), unifrnd(-pi/2, pi/2)];
            else
                zclutter{t} = [zclutter{t}; unifrnd(-5, 10), unifrnd(-pi/2, pi/2)];
                zclutter{t} = [zclutter{t}; unifrnd(-5, 10), unifrnd(-pi/2, pi/2)];
                zclutter{t} = [zclutter{t}; unifrnd(-5, 10), unifrnd(-pi/2, pi/2)];
            end

        end
    elseif(strcmp(mode,'KF'))
        for t = 1 : size(targets,2) % for all time steps
            %z{t} = mvnrnd([targets{t}(1) targets{t}(2)], sigma);
            z{t} = [targets{t}(1) + randn(1)*sigma(1,1)^2; targets{t}(2) + randn(1)*sigma(2,2)^2];
        end
    end
end