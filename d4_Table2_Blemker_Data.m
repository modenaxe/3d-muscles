%-------------------------------------------------------------------------%
% Copyright (c) 2020 Modenese L., Kohout J.                               %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
%                                                                         %
%    Author:   Luca Modenese                                              %
%    email:    l.modenese@imperial.ac.uk                                  % 
% ----------------------------------------------------------------------- %
% Scripts that computes mean and standard deviations of moment arms based
% on upper and lower values digitised from figures in Blemker and Delp's
% paper.
%----------------------------------------------------------------------- %%
clear; clc; close all
addpath('./_support_functions');
addpath('./_literature_data');

%-------------- SETTINGS -------------------------
% model
model = 'LHDL'; 
% kinematic method
method = 'L_Method'; 
% task to use in creating the models
task_set        = {'hip_flexion','hip_adduction', 'hip_rotation'};
%-------------------------------------------------

% name of muscles
muscles_list = {'r_psoas', 'r_iliacus', 'r_gluteus_maximus', 'r_gluteus_medius'};
N_mus = numel(muscles_list);

% Load data digitised from Blemker and Delp 2005
Blemker2005_data = load_Blemker2005_data();
ROM_set = {[-10 60 ], [-40 40], [-30 30]};

% coeff_os = 1.0;
for n_t = 1:numel(task_set)
    % get current task
    cur_task = task_set{n_t};
    disp('---------------------------------')
    disp(['Processing: ', cur_task])
    disp('---------------------------------')
    for n_m = 1:N_mus
        ROM = ROM_set{n_t};
        % get current muscle
        cur_mus_name = muscles_list{n_m};
            
        %========== BLEMKER DATA ===============
        % fit fourth order polynomials
        p1 = polyfit(Blemker2005_data.(cur_mus_name).(cur_task).lb(:,1), Blemker2005_data.(cur_mus_name).(cur_task).lb(:,2), 4);
        p2 = polyfit(Blemker2005_data.(cur_mus_name).(cur_task).ub(:,1), Blemker2005_data.(cur_mus_name).(cur_task).ub(:,2), 4);
        % compute
        x_vect = ROM(1):ROM(end);
        yy_l = polyval(p1, x_vect);
        yy_u = polyval(p2 ,x_vect);
        % ranges
        range.(cur_mus_name).(cur_task) = abs(yy_u-yy_l);
        boundaries = [yy_l', yy_u'];
        mean_mus_ma = mean(mean([yy_l; yy_u]));
        std_mus_ma = std(mean([yy_l; yy_u]));
        disp([cur_mus_name,': MEAN: ', num2str(mean_mus_ma, '%2.1f\t'),' (', num2str(std_mus_ma, '%2.1f\t'),')']);
        %========================================
    end
end

% remove paths 
rmpath('./_support_functions');
rmpath('./_literature_data');