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
% This script computes the moment arms for the highly discretised muscle
% models included in the OpenSim models available at the directory
% b_fibre_models.
% The results are stored in the folder "c_fibre_biomechanics/L_method".
% ----------------------------------------------------------------------- %
clear; clc
close all
% OpenSim libraries
import org.opensim.modeling.*
% required functions
addpath('./_support_functions');

%-------------- SETTINGS -------------------------
% model
model = 'LHDL'; 
method = 'L_Method'; 
% task to use in creating the models
task_set        = {'hip_flexion','hip_adduction', 'hip_rotation'};
indip_coord_set = {'hip_flexion_r','hip_adduction_r', 'hip_rotation_r'};
% folder where the models with fibers are
models_folder = ['./b_fibre_models', filesep, method];
% folder where to store OpenSim models for the analyzed frames
biomech_results_folder = ['c_fibre_biomechanics', filesep, method];
% number of fitting point = original time stamps * multiplicator
multiplicator = 5;
%-------------------------------------------------

% name of highly discretised muscles
muscles_set = lower({'R_Gluteus_Medius', 'R_Gluteus_Maximus', 'R_Psoas', 'R_Iliacus'});

% check folder existance
checkFolder(biomech_results_folder)

for n_task = 1:numel(task_set)
    
    % setting variables for computations
    cur_task = task_set{n_task};
    sim_name = [model,'_',cur_task];
    coord_name = indip_coord_set{n_task};
    kinematicsMotFile = ['./a_MSK_model/b_kinematics/',cur_task,'.mot'];
    in_deg = 'yes';
    
    disp(['Computing muscle kinematics for task: ', cur_task]);
    
    % open OpenSim model with fiber muscle
    osimModel = Model([models_folder, filesep,model,'_',cur_task,'_OS3.3.osim']);

    % creating structure with differential kinematics
    kinMat = sto2MatStruct(kinematicsMotFile);
    
%    % TODO: exclude time from conversion (not an issue here)
%     if strcmp(in_deg, 'yes')
%         kinMat.data = kinMat.data/180*pi;
%     end
    
    % acquiring the kinematic angles
    kinStorage=Storage(kinematicsMotFile);
    
    N_frames = kinStorage.getSize();
    N_mus = numel(muscles_set);
    
    % fit polynomial to coords (useful for walking)
    PolyCoord = getValueColumnForHeader(kinMat, coord_name)/180*pi;
    time = getValueColumnForHeader(kinMat, 'time');
    [coef_q, S] = polyfit(time, PolyCoord, 4);
    n_fit_point = multiplicator*numel(time);
    q_fit = polyval(coef_q, linspace(time(1), time(end), n_fit_point));
    diff_q_fit = diff(q_fit);
    
    % get muscles
    mtu_set = osimModel.getForceSet();
    N_fibers = mtu_set.getSize();
    
    disp('----------------------------------------------------')
    
    for n_mus = 1:N_mus
        
        % muscle being processed
        cur_mus = muscles_set{n_mus};
        
        % log info
        disp(['Processing muscle: ',cur_mus,' (',num2str(n_mus),'/',num2str(N_mus),')'])
        
        % update model status (realize kinematics)
        state = osimModel.initSystem();
        
        for n_frames = 0:N_frames-1
            
            % realize kinematic state
            state = realizeKinematics(osimModel, state, kinStorage, n_frames);
            
            % compute moment arms for each fiber
            n_keep_mtu = 1;
            n_fib = 1;
            flag = 0;
            while flag == 0
                
                cur_mtu_name = [cur_mus,'_',num2str(n_fib)];
                
                if mtu_set.getIndex(cur_mtu_name)<0
                    flag = 1;
                    n_fib = n_fib+1;
                    continue
                else
                    
                    % downcast to compute moment arm
                    curr_fiber = mtu_set.get(cur_mtu_name);
                    curr_mus_path = PathActuator.safeDownCast(curr_fiber);
                    
                    % compute length
                    mus_length_mat(n_frames+1, n_keep_mtu) = curr_mus_path.getLength(state);
                    n_keep_mtu = n_keep_mtu+1;
                    n_fib = n_fib+1;
                end
            end
        end
        
        % fitting 4th order polynomial to muscle lengths
        for p = 1:size(mus_length_mat,2)
            coef_l = polyfit(time, mus_length_mat(:,p), 4);
            mus_length_fit(:,p) = polyval(coef_l, linspace(time(1), time(end), n_fit_point));
        end
        
        % saving results from approach above
        ResultsSummary.(cur_mus).ind_coord         = q_fit;
        ResultsSummary.(cur_mus).ind_coord_name    = coord_name;
        ResultsSummary.(cur_mus).mus_length_mat    = mus_length_mat;
        ResultsSummary.(cur_mus).D_mus_length_mat  = diff(mus_length_mat);
        ResultsSummary.(cur_mus).mom_arm_mat       = diff(mus_length_fit)./(diff_q_fit' * ones(1, 100));
        % essential!!
        clear mus_length_mat mus_length_fit coef_l
    end
    disp('----------------------------------------------------')
    % save results
    file_res = fullfile(biomech_results_folder, ['Results_',sim_name]);
    save(file_res, 'ResultsSummary');
end
% remove path
rmpath('./_support_functions');