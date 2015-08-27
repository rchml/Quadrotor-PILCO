%% quadrotor_learn.m
% *Summary:* Script to learn a controller for quadrotor
%
% Copyright (C) 2008-2013 by
% Marc Deisenroth, Andrew McHutchon, Joe Hall, and Carl Edward Rasmussen.
%
% Modified by Mark Paluta
%
%% High-Level Steps
% # Load parameters
% # Create J initial trajectories by applying random controls
% # Controlled learning (train dynamics model, policy learning, policy
% application)

%% Code

% 1. Initialization
clear all; close all;
settings_q;                      % load scenario-specific settings
basename = 'quadrotor_';           % filename used for saving data

% 2. Initial J random rollouts
for jj = 1:J
    disp(mu0)
    fprintf('\n\n')
    [xx, yy, realCost{jj}, latent{jj}] = ...
        rollout(gaussian(mu0, S0), struct('maxU',policy.maxU), H, plant, cost);
    x = [x; xx]; y = [y; yy];       % augment training sets for dynamics model
    if plotting.verbosity > 0;      % visualization of trajectory
        if ~ishandle(1); figure(1); else set(0,'CurrentFigure',1); end; clf(1);
        draw_rollout_q;
    end
    mu0 = randomize_mu(mu_max);
end

mu0Sim(odei,:) = mu0; S0Sim(odei,odei) = S0;
mu0Sim = mu0Sim(dyno); S0Sim = S0Sim(dyno,dyno);

% 3. Controlled learning (N iterations)
for j = 1:N
    disp(mu0)
    fprintf('\n\n')
    trainDynModel;   % train (GP) dynamics model
    learnPolicy;     % learn policy
    applyController; % apply controller to system, save workspace
    disp(['controlled trial # ' num2str(j)]);
    if plotting.verbosity > 0;      % visualization of trajectory
        if ~ishandle(1); figure(1); else set(0,'CurrentFigure',1); end; clf(1);
        draw_rollout_q;
    end
    if j~=N
        mu0 = randomize_mu(mu_max);
    end
end