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
% This script plots the moment arms of Ilicus and Psoas from the highly
% discretised musculoskeletal models in a fashion similar to Blemker and
% Delp, Ann of Biom Eng (2005).
% Data from previous studies is also plotted.
% The input data are generated by the MATLAB script
% a_compute_biomech_moving_viapoints.m
% NB: all coordinates are assumed in degrees
% ----------------------------------------------------------------------- %
clear; clc; close all
% OpenSim libraries
import org.opensim.modeling.*
addpath('./_support_functions');

%-------------- SETTINGS -------------------------
% model
model = 'LHDL'; % 'TLEM'
method = 'L_Method'; % 'MSS';%
% task to use in creating the models
task_set        = {'hip_flexion','hip_adduction', 'hip_rotation'};
indip_coord_set = {'hip_flexion_r','hip_adduction_r', 'hip_rotation_r'};
% folder where the biomechanical results are stored
biomech_res_folder = ['c_fibre_biomechanics/', method];
% folder where the MSK model results are stored
MSK_folder = './a_MSK_model';
% folder where the figures will be saved
temp_figure_folder = 'd_paper_figures/temp'; 
% external data folder (from previous publications)
literature_data_folder = '_literature_data';
%-------------------------------------------------

% name of muscles (depend on model)
muscles_list = {'r_psoas', 'r_iliacus'};
title_list = { 'Psoas', 'Iliacus'};
% in_deg = 'yes';

% check folder existance
checkFolder(temp_figure_folder)

n_plot = 1;
h = figure; set(h, 'Position', [410    89   536   768]);

for n_task = 1:3
    % setting variables for computations
    cur_task = task_set{n_task};
    sim_name = [model,'_',cur_task];
    coord_name = indip_coord_set{n_task};
    kinematicsMotFile = [MSK_folder, filesep, 'b_kinematics/',cur_task,'.mot'];
    MSK_results_file = [MSK_folder, filesep, 'c_MSK_results/',model, '_', cur_task,'.mot'];
    
    switch cur_task
        case 'hip_flexion'
            xlabel_str = 'hip flexion angle [deg]';
            ylabel_str = {'hip flexion'; 'moment arm [cm]'};
            x_lim = [-10.0, 60.0];
            y_lim = [0.0 5.5];
            coeff = -1.0;
            coeff_os = 1.0;
        case 'hip_adduction'
            xlabel_str = 'hip adduction angle [deg]';
            ylabel_str = {'hip adduction'; 'moment arm [cm]'};
            x_lim = [-40 40];
            y_lim = [-2.0 2.5];
            coeff = -1.0;
            coeff_os = 1.0;
        case 'hip_rotation'
            xlabel_str = 'hip internal rotation angle [deg]';
            ylabel_str = {'hip internal rotation'; 'moment arm [cm]'};
            x_lim = [-30 30];
            y_lim = [-2.0 1.25];
            coeff = -1.0;
            coeff_os = 1.0; % positive internal rot
    end
    
    
    % load results for simulated task
    load(fullfile(biomech_res_folder, ['Results_',sim_name]));
    
    % load mom arms from OpenSim model
    osim_MA = sto2MatStruct(MSK_results_file);
    % angles
    q  = getValueColumnForHeader(osim_MA, coord_name);

    % glut max
    os_iliacus = getValueColumnForHeader(osim_MA, 'iliacus_r');
    % glut med
    os_psoas = getValueColumnForHeader(osim_MA, 'psoas_r');
    
    % load results for simulated task
    load(fullfile(biomech_res_folder, ['Results_',sim_name]));
    
    % load mom arms from OpenSim model
    osim_MA = sto2MatStruct(MSK_results_file);
    % creating structure with kinematics
    kinMat = sto2MatStruct(kinematicsMotFile);
    
    % kinematics
    angles = getValueColumnForHeader(kinMat, coord_name);
    
    N_mus = numel(muscles_list);
    
    for n_m = 1:N_mus
        title_str = title_list{n_m};
        cur_mus = muscles_list{n_m};
        
        % create title
        tit1 = strrep(cur_mus(3:end),'_',' ');
        cur_tit = [upper(tit1(1)),tit1(2:end)];
        
        disp(['Processing ', cur_mus]);
        cur_mus_res = ResultsSummary.(cur_mus);
        
        % get Blemker color for same muscle
        switch cur_mus
            case 'r_iliacus'
                col = [0.65 0 0.65];
                os_ = os_iliacus;
            case 'r_psoas'
                col = [0  0.6  0.4];
                os_ = os_psoas;
        end
        
        % plot
        subplot(3,N_mus,n_plot);
        plot( cur_mus_res.ind_coord(1:end-1)*180/pi, coeff*(cur_mus_res.mom_arm_mat*100),'Color',col); hold on
        plot(q, coeff_os*os_*100,'k', 'Linewidth', 1.0)
        
        if n_task == 1
            title(title_str);
        end
        if mod(n_plot,2)~=0
            ylabel(ylabel_str);
        end
        xlabel(xlabel_str);
%         xlim([min(angles) max(angles)]);
        xlim(x_lim);
        
        ylim(y_lim)
        box off
        %         copyobj(ax2,base_ax_h); hold on
        n_plot = n_plot+1;
    end
end

% additional data
load([literature_data_folder, filesep,'Nemeth1985.mat']);
load([literature_data_folder, filesep,'Dostal1986.mat']);
load([literature_data_folder, filesep,'Arnold2000.mat'])
%----------- ILIO-PSOAS ------------
% DOSTAL's DATA
% flex(-)/ext(+) in Dostal -> changed sign to conform to my convention
subplot(3,2,1); 
plot(0.0, 1.8, 'ok', 'Linewidth', 1.0,'MarkerFaceColor',[0 0 0],'MarkerSize',3)
subplot(3,2,2); 
plot(0.0, 1.8, 'ok', 'Linewidth', 1.0,'MarkerFaceColor',[0 0 0],'MarkerSize',3)
%add(+)/abd(-) in Dostal -> same as my convention
subplot(3,2,3); 
plot(0.0, -0.7, 'ok', 'Linewidth', 1.0,'MarkerFaceColor',[0 0 0],'MarkerSize',3)
subplot(3,2,4); 
plot(0.0, -0.7, 'ok', 'Linewidth', 1.0,'MarkerFaceColor',[0 0 0],'MarkerSize',3)
% int(+)/ext(-) rotation -> same as my convention
subplot(3,2,5); 
plot(0.0, 0.5, 'ok', 'Linewidth', 1.0,'MarkerFaceColor',[0 0 0],'MarkerSize',3)
subplot(3,2,6); 
plot(0.0, 0.5, 'ok', 'Linewidth', 1.0,'MarkerFaceColor',[0 0 0],'MarkerSize',3)

% ARNOLD's DATA
subplot(3,2,1); 
plot(Arnold2000.data(:,1), Arnold2000.data(:,2), 'k--')
%------------------------------------

%setting appropriately the figure for saving the file
set(h,'PaperPositionMode','Auto');
saveas(h, fullfile(temp_figure_folder,[model,'_Fig3_temp.fig']))
close all
delete(h);
% remove dir from path 
rmpath('./_support_functions');