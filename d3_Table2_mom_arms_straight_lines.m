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
% This script reads the moment arms of the musculoskeletal model created
% from the LHDL dataset with "standard" muscle representations and prints
% out the ranges for each of the hip functional tasks considered in the
% manuscript.
% The values are include in Table 1 of the manuscript.
% ----------------------------------------------------------------------- %
clear; clc;

addpath('./_support_functions');

%-------------- SETTINGS -------------------------
% model
model = 'LHDL';
% task to use in creating the models
task_set        = {'hip_flexion','hip_adduction', 'hip_rotation'};
indip_coord_set = {'hip_flexion_r','hip_adduction_r', 'hip_rotation_r'};
% folder where the MSK model results are stored
MSK_results_folder = './a_MSK_model/c_MSK_results';
%-------------------------------------------------

% name of muscles (depend on model)
muscles_list = {'r_psoas', 'r_iliacus', 'r_gluteus_maximus', 'r_gluteus_medius'};
ma_range_matrix.colheaders = {};
accum = [];
disp('------------------------------------------------------------------')
disp('MOMENT ARMS FOR MSK MODEL WITH STANDARD STRAIGHT-LINE MUSCLE MODELS.');
disp('------------------------------------------------------------------')
for n = 1:numel(task_set)
    % get current task
    cur_task = task_set{n};
    
    disp(['Processing task: ',upper(cur_task)]);
    
    % get all data for that model and task
    sim_name = [model,'_',cur_task];
    coord_name = [cur_task, '_r'];
    MSK_results_file = [MSK_results_folder, filesep ,model,'_',cur_task,'.mot'];
    in_deg = 'yes';
    
    % load mom arms from OpenSim model (saved from OpenSim GUI)
    osim_MA = Storage2MatStruct(MSK_results_file);
    if strcmp(cur_task, 'hip_flexion')
        osim_MA.data = osim_MA.data(1:71, :);
    end
    
    % extract results
    % glut max
    os_glutmax(:,1) = getValueColumnForHeader(osim_MA, 'glut_max1_r');
    os_glutmax(:,2) = getValueColumnForHeader(osim_MA, 'glut_max2_r');
    os_glutmax(:,3) = getValueColumnForHeader(osim_MA, 'glut_max3_r');
    range_glumax = [ min(min(os_glutmax))  max(max(os_glutmax))];
    mean_glumax(n) = mean(mean(os_glutmax)*100);
    std_glumax(n) = std(mean(os_glutmax)*100);
	
    % glut med
    os_glutmed(:,1) = getValueColumnForHeader(osim_MA, 'glut_med1_r');
    os_glutmed(:,2) = getValueColumnForHeader(osim_MA, 'glut_med2_r');
    os_glutmed(:,3) = getValueColumnForHeader(osim_MA, 'glut_med3_r');
    range_glumed = [ min(min(os_glutmed))  max(max(os_glutmed))];
    mean_glumed(n) = mean(mean(os_glutmed)*100);
    std_glumed(n) = std(mean(os_glutmed)*100);
	
    %iliacus
    os_iliacus = getValueColumnForHeader(osim_MA, 'iliacus_r');
    range_iliacus = [ min(min(os_iliacus))  max(max(os_iliacus))];
	mean_iliacus(n) = mean(os_iliacus)*100;
    std_iliacus(n) = std(os_iliacus)*100;
    
    % psoas
    os_psoas = getValueColumnForHeader(osim_MA, 'psoas_r');
    range_psoas = [ min(min(os_psoas))  max(max(os_psoas))];
    mean_psoas(n) = mean(os_psoas)*100;
    std_psoas(n) = std(os_psoas)*100;
	
    % display
    disp(['psoas range of moment arms   : ', num2str(range_psoas*100, '%2.1f\t'), ' cm'])
    disp(['iliacus range of moment arms : ', num2str(range_iliacus*100, '%2.1f\t'), ' cm'])
    disp(['glut_max range of moment arms: ', num2str(range_glumax*100, '%2.1f\t'), ' cm'])
    disp(['glut_med range of moment arms: ', num2str(range_glumed*100, '%2.1f\t'), ' cm'])
    clear os_*
    disp('-----------------------------------------------')
end
rmpath('./_support_functions');