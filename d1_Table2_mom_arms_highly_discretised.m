%-------------------------------------------------------------------------%
% Copyright (c) 2019 Modenese L., Kohout J.                               %
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
% Scripts that computes the ranges of moment arms for the highly
% discretised muscles. The computed values are included in Table 1 of the
% manuscript (with opposite sign).
% ----------------------------------------------------------------------- %
clear; clc;

addpath('./_support_functions');

%-------------- SETTINGS -------------------------
% model
model = 'LHDL'; 
method = 'L_method';
% task to use in creating the models
task_set        = {'hip_flexion','hip_adduction', 'hip_rotation'};
indip_coord_set = {'hip_flexion_r','hip_adduction_r', 'hip_rotation_r'};
% folder where the biomechanical results are stored
biomech_res_folder = ['c_fibre_biomechanics', filesep, method];
% folder where the MSK model results are stored
MSK_results_folder = './a_MSK_model/c_MSK_results';
%-------------------------------------------------

% name of muscles (depend on model)
muscles_list = {'r_psoas', 'r_iliacus', 'r_gluteus_maximus', 'r_gluteus_medius'};
ma_range_matrix.colheaders = {};
accum = [];
disp('----------------------------------------------------------------------------')
disp('MOMENT ARMS FOR MSK MODEL WITH HIGHLY DISCRETISED GEOMETRICAL MUSCLE MODELS.');
disp('==> NB: values in Table 1 are opposite in sign due to conventions <==')
disp('----------------------------------------------------------------------------')
for n = 1:numel(task_set)
    % get current task
    cur_task = task_set{n};
    disp(['Processing task: ',upper(cur_task)]);
    
    % get all data for that model and task
    sim_name = [model,'_',cur_task];
    
    % load results from MAF muscle generator
    load(fullfile(biomech_res_folder, ['Results_',sim_name]));
    
     N_mus = numel(muscles_list);
    
    for n_m = 1:N_mus
%         figure

        cur_mus_name = muscles_list{n_m};
        cur_mus_res = ResultsSummary.(cur_mus_name);
        
        % extremes and row index (# frame)
        [max_val_Fibers, max_ind_Frames] = max(cur_mus_res.mom_arm_mat);
        [min_val_Fibers, min_ind_Frames] = min(cur_mus_res.mom_arm_mat);
        
%         plot(cur_mus_res.mom_arm_mat);hold on
%         plot(max_ind_Frames,max_val_Fibers,'o' )
%         plot(min_ind_Frames,min_val_Fibers,'x' )
        
        % absolute extremes and column index (# fiber)
        [max_MA, max_ind_Fiber] = max(max_val_Fibers);
        [min_MA, min_ind_Fiber] = min(min_val_Fibers);
        
        % peaks (max and min of each fiber)
        peak_frame_MAs_max = cur_mus_res.mom_arm_mat(max_ind_Frames(max_ind_Fiber),:);
        peak_frame_MAs_min = cur_mus_res.mom_arm_mat(min_ind_Frames(min_ind_Fiber),:);
        
        % compute range
        range_MA = [min(peak_frame_MAs_min), max(peak_frame_MAs_max)];
        range_MA_frames = [ min_ind_Frames(min_ind_Fiber), max_ind_Frames(max_ind_Fiber)];
        
%         % plot extremes
%         plot(range_MA_frames, range_MA, 'kd')
        
        % store results
        ma_range_matrix.colheaders(n_m) = {['MAF_',cur_mus_name]};
        accum = [accum, range_MA*100]; % cm

        %     range_MA = [min_MA max_MA]*100;
        % disp([cur_mus_name,' range of moment arms: ', num2str(range_MA*100), ' cm'])
%         close all

        % FOR REVISION: mean and std of moment arms
        med = mean(cur_mus_res.mom_arm_mat, 2);
        dev = std(cur_mus_res.mom_arm_mat, 0, 2);
        plot(med, 'k', 'LineWidth', 3)
        %     range_MA = [min_MA max_MA]*100;
        disp([cur_mus_name,' range of moment arms: ', num2str(range_MA*100, '%2.1f\t'), ' cm', '    mean val:',num2str(mean(med)*100, '%2.1f\t'),'  std:',num2str(std(med)*100, '%2.1f\t')])
        close all
    end
    ma_range_matrix.data(n, :) = accum;
    accum = [];
    disp('-----------------------------------------------')
    clear os_*
    
end
disp('Check variable ''ma_range_matrix'' for a summary of results')
rmpath('./_support_functions');