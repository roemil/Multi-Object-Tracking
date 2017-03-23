clear all; clc;clf; close all;
xlim = 10;
ylim = 10; % box where we can see targets

Nu = 3;
targets = cell(1);
k = 0;
lambda_b = 2; % Probability of birth
%birth_threshold = poisspdf(1,lambda_b);
birth_threshold = random('Poisson', lambda_b);
flag = 1;
t = 0;
targets = cell(1);
nbrOftargets = 1;
maxNbrofTargets = 5;
colors = {'bo','go','ro','co','mo','yo','ko'};

