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
% Function that effectively works as a script. It overlaps plots generated
% from simulation with highly discretised muscle models with digised area
% patches representing results from Blemker and Delp, Ann Biomed Eng, 2005.
% ----------------------------------------------------------------------- %
% last modified 16 Oct 2017

function c_generate_Fig4_Fig5()

clc; close all;

%-------------- SETTINGS -------------------------
% model
model = 'LHDL'; 
% folder where the figures from previous step can be read
temp_figure_folder  = './d_paper_figures/temp';
% Folder where the Blemker and Delp results are stored as fig files
literature_data_folder = '_literature_data';
% folder where the final figures are stored
paper_figure_folder = './d_paper_figures';
%-------------------------------------------------


if ~isdir(paper_figure_folder); mkdir(paper_figure_folder); end
% generating Figure 3
base_fig = openfig(fullfile(literature_data_folder,'Blemker2005_fig6.fig'));
overlay    = openfig(fullfile(temp_figure_folder,[model, '_Fig3_temp.fig']));
overlapPlots(base_fig, overlay, fullfile(paper_figure_folder, [model,'_Figure1_Blemker_overlap.fig']));
% generating Figure 4
base_fig = openfig(fullfile(literature_data_folder,'Blemker2005_fig7.fig'));
overlay    = openfig(fullfile(temp_figure_folder,[model, '_Fig4_temp.fig']));
overlapPlots( base_fig, overlay,fullfile(paper_figure_folder, [model,'_Figure2_Blemker_overlap.fig']));
end

% function that copies one axis on top of another one
function base_fig_h = overlapPlots(base_fig_h, overlap_fig_h, fig_name)
base_ax  = findobj(base_fig_h,'type','axes');
overlap_ax = findobj(overlap_fig_h,'type','axes');
for n = 1:length(base_ax)
    base_ax_h = base_ax(length(base_ax)-n+1);
    overlap_ax_h = overlap_ax(length(overlap_ax)-n+1);
    copyobj(allchild(overlap_ax_h),base_ax_h); hold on
end

% saving figures
set(base_fig_h,'PaperPositionMode','Auto');
% set(gca, 'color', 'none');
saveas(base_fig_h, fig_name);
saveas(base_fig_h, [fig_name(1:end-4),'.png']);

delete(base_ax); delete(overlap_ax)
delete(base_fig_h); delete(overlap_fig_h)
end
