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
% Scripts that computes the ranges of moment arms for the highly
% discretised muscles. The computed values are included in Table 1 of the
% manuscript (with opposite sign).
%----------------------------------------------------------------------- %
clear; clc; close all

addpath('./_support_functions');
addpath('./_literature_data');
%-------------- SETTINGS -------------------------
% model
model = 'LHDL'; 
method = 'L_Method'; 
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
os_muscles_list = {'psoas_r', 'iliacus_r', {'glut_max1_r',  'glut_max2_r',  'glut_max3_r'},  {'glut_med1_r',  'glut_med2_r',  'glut_med3_r'    }};
N_mus = numel(muscles_list);
ma_range_matrix.colheaders = {};
accum = [];

% load Blemker data
Blemker2005_data = load_Blemker2005_data();

% ranges of motion of interest
ROMs_set = {[-10 60 ], [-40 40], [-30 30]};
n_plot=1;
coeff = -1.0;

% figure for double check plotting
h = figure; set(h, 'Position', [210    89   1536   768]);

% loop throughout tasks
for n_t = 1:numel(task_set)
    % get current task
    cur_task = task_set{n_t};
    % load mom arms from OpenSim model (saved from OpenSim GUI)
    MSK_results_file = [MSK_results_folder, filesep ,model,'_',cur_task,'.mot'];
    osim_MA_task = Storage2MatStruct(MSK_results_file);
    % load results from highly discretized muscles
    load(fullfile(biomech_res_folder, ['Results_',model,'_',cur_task]));
    
    for n_m = 1:N_mus
        % current range of motion
        cur_ROM = ROMs_set{n_t};
        % get current muscle (blemker and highly-discretized)
        cur_mus_name = muscles_list{n_m};
        % get current muscle (straight-lines)
        cur_mus_name_os = os_muscles_list{n_m};
        coeff = -1.0;
        % conventions as in Blemker, so need correction for gluts in
        % flexion
        if strcmp(cur_task,'hip_flexion') && strncmp(cur_mus_name,'r_gluteus',length('r_gluteus'))
            coeff = 1.0;
        end
        
        %========== HIGHLY DISCRETIZED MUSCLES ==
        % load moment arms for current muscle
        cur_mus_res = ResultsSummary.(cur_mus_name);
        % indep coordinate for the current task as stored in results (fit)
        ind_coord_v = ResultsSummary.(cur_mus_name).ind_coord*180/pi;
        % adjusting to Blemker and Delp convention of signs
        LHP_mom_arm_mat = cur_mus_res.mom_arm_mat*coeff;
        % building a polygonal shape in MATLAB for areas calculations:
        % 1) proper x coordinates
        x_sim = ind_coord_v(1:end-1)+mean(diff(ind_coord_v));
        % 2) upper and lower boundary curves
        sim_ub = max(LHP_mom_arm_mat,[],2)*100;
        sim_lb = min(LHP_mom_arm_mat,[],2)*100;
        % 3) create polygon
        sim_poly = polyshape([x_sim, flip(x_sim)],[sim_ub', flip(sim_lb')]);
        %========================================
        
        %========== BLEMKER DATA===============
        % fit fourth order polynomials
        p1 = polyfit(Blemker2005_data.(cur_mus_name).(cur_task).lb(:,1), Blemker2005_data.(cur_mus_name).(cur_task).lb(:,2), 4);
        p2 = polyfit(Blemker2005_data.(cur_mus_name).(cur_task).ub(:,1), Blemker2005_data.(cur_mus_name).(cur_task).ub(:,2), 4);
        % calculate values for range of interest
        x_vect = cur_ROM(1):cur_ROM(end);
        yy_l = polyval(p1, x_vect);
        yy_u = polyval(p2 ,x_vect);
        % creating MATLAB polygon for areas calculations
        b_poly = polyshape([x_vect, flip(x_vect)],[yy_u, flip(yy_l)]);
        % ranges (never really used - checked manually for table 2)
        % range.(cur_mus_name).(cur_task) = abs(yy_u-yy_l);
        
        % Intersection of areas of Blemker and highly discretized muscles
        % (as % of Blemker's area)
        polyout = intersect(sim_poly,b_poly);
        Blemker_on_sims_table(n_t, n_m)= area(polyout)/area(b_poly)*100; %#ok<SAGROW>
        %========================================
        
       
        % plotting for double checking areas
%         disp(['Plotting: ', cur_mus_name, ' for task: ', cur_task])
        subplot(3, 4, n_plot)
        plot(sim_poly); hold on
        plot(b_poly); hold on
        xlim(cur_ROM)
        xlabel('Degrees')
        ylabel('Moment arms [cm]')
        title(strrep([cur_mus_name, ' - ', cur_task],'_',' '))
        

        
        %========== STRAIGTH-LINES MUSCLES =========
        % get coordinate for straight-lines (unfortunately all source of
        % results are sampled differently)
        os_coord = getValueColumnForHeader(osim_MA_task, indip_coord_set{n_t});
        % get moment arms and adjust to Blemker and Delp signs once more
        if ischar(cur_mus_name_os)
            os_MA = getValueColumnForHeader(osim_MA_task, cur_mus_name_os);
            coeff_os = 1.0;
        % deal with muscles with multiple bundles
        elseif iscell(cur_mus_name_os)
            for ni = 1:length(cur_mus_name_os)
                os_MA(:,ni) = getValueColumnForHeader(osim_MA_task, cur_mus_name_os{ni});
                coeff_os = 1.0;
                if strcmp(cur_task, 'hip_flexion')
                    coeff_os = -1.0;
                end
            end
        end
        % loop through the bundles
        for nn = 1:size(os_MA,2)
            % plot to achieve consistency with the other data
            p_os  = polyfit(os_coord, os_MA(:,nn)*100*coeff_os, 4);
            os_MA_fit = polyval(p_os, x_sim);
            
            % plotting for double checking
            plot(x_sim, os_MA_fit,'g');hold on

            % compute the index of the poses outside the boundaries of the
            % highly discretized muscle moment arms
            out_index = (os_MA_fit>sim_ub')+(os_MA_fit<sim_lb');
            out_perc(nn)  = 100-sum(out_index)/numel(os_MA_fit)*100;
            % diplay results
            if nn==size(os_MA,2)
                %disp(['agreement: ', num2str(mean(out_perc))])
                line_mus_perc_table(n_t, n_m) = mean(out_perc);
                clear out_perc
            end
        end
        %========================================
        
        %========== LITERATURE DATA =========
        x_extra = [];
        y_extra = [];
        code = '';
        if strcmp('r_psoas', cur_mus_name) && strcmp(cur_task,'hip_flexion')
            load('Arnold2000.mat')
            x_extra = Arnold2000.data(:,1); 
            y_extra = Arnold2000.data(:,2);%2:4
            code = 'Arnold';
        end
        
        if strcmp('r_gluteus_medius',cur_mus_name) && strcmp(cur_task,'hip_flexion')
            load('Dostal1986.mat');
            % special data
            x_extra = Dostal1986.data(:,1);
            y_extra =-Dostal1986.data(:,2);
            code = 'Dostal';
            
        end
        if strcmp('r_gluteus_maximus',cur_mus_name) && strcmp(cur_task,'hip_flexion')
            load('Nemeth1985.mat');
            % points were from paper: added first point
            x_extra = [Nemeth1985.data(1,1), 5:5:90];
            y_extra = [Nemeth1985.data(1,2), 75, 74, 72, 70, 69, 66, 64, 62, 59, 56, 54, 51, 48, 44, 41, 38, 34, 31]/10;
            code = 'Nemeth';
        end
        
        if ~isempty(x_extra)
            % fit the data to adjust to sampling of other sources
            lit_os  = polyfit(x_extra, y_extra, 4);
            lit_MA_fit = polyval(lit_os, x_sim);
            % compute percentage of agreement
            lit_out_index = (lit_MA_fit>sim_ub')+(lit_MA_fit<sim_lb');
            lit_out_perc  = 100-sum(lit_out_index)/numel(lit_MA_fit)*100;
            %         disp(['agreement ',code, ' : ', num2str(mean(lit_out_perc))])
            lit_mus_perc_table(n_t, n_m) = mean(lit_out_perc);
            % plotting for double checking literature data
            plot(x_sim, lit_MA_fit, '-k', 'Linewidth', 2.0)
        end
        %========================================
        
        
        % update counters
        n_plot = n_plot+1;
        clear os_MA
    end
    clear osim_MA_task
end

% subtables of Table 1, in order
Table2_straight_mus = table([line_mus_perc_table(:,1)], [line_mus_perc_table(:,2)], [line_mus_perc_table(:,3)], [line_mus_perc_table(:,4)]);
Table2_straight_mus.Properties.VariableNames = {'r_psoas' 'r_iliacus' 'r_gluteus_maximus' 'r_gluteus_medius'};
Table2_straight_mus.Properties.RowNames = {'hip_flexion_lines' 'hip_adduction_lines' 'hip_rotation_lines'};
disp(Table2_straight_mus)


Table2_Areas = table([Blemker_on_sims_table(:,1)], [Blemker_on_sims_table(:,2)], [Blemker_on_sims_table(:,3)], [Blemker_on_sims_table(:,4)]);
Table2_Areas.Properties.VariableNames = {'r_psoas' 'r_iliacus' 'r_gluteus_maximus' 'r_gluteus_medius'};
Table2_Areas.Properties.RowNames = {'hip_flexion_areas' 'hip_adduction_areas' 'hip_rotation_areas'};
disp(Table2_Areas)


Table2_lit_data = table([lit_mus_perc_table(:,1)], [lit_mus_perc_table(:,2)], [lit_mus_perc_table(:,3)], [lit_mus_perc_table(:,4)]);
Table2_lit_data.Properties.VariableNames = {'r_psoas_Arnold' 'r_iliacus_no_data' 'r_gluteus_maximus_Nemeth' 'r_gluteus_medius_Dostal'};
Table2_lit_data.Properties.RowNames = {'hip_flexion_lit' };
disp(Table2_lit_data)

% remove paths 
rmpath('./_support_functions');
rmpath('./_literature_data');