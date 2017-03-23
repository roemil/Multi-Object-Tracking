function z = generateMeasurements(targets, sigma)
    z = []; %zeros(size(targets,1),size(targets,2));
    for t = 1 : size(targets,2) % for all time steps
        for j = 1 : size(targets{t},2) % for all targets at time t
            % Gaussian noise in measurement model
            % model is only distance right now
            %z{t}(1,j) = norm(mvnrnd([targets{t}(1,j) targets{t}(2,j)], sigma));
            if(rand(1) < targets{t}(5,j))
                z = [z; norm([targets{t}(1,j) targets{t}(2,j)]) + sigma*randn(1), atan2(targets{t}(2,j),targets{t}(1,j))];
            end
        end
    end
end