%% PLOT TOPO single time lag

%% Clear memory and the command window
clear;
close all;
clc;

%% set the path so that it specifies the correct folder on your computer
MYPATH = fileparts(pwd)
WRKPATH =[MYPATH,'/TRF_workshop'];

%Define the path to save the figure results
PATHfigure=[WRKPATH,'/Figure/'];
% create output folder if it does not exist yet
if ~exist(PATHfigure)
    mkdir(PATHfigure);
end

%%Software
addpath([WRKPATH,'/Toolboxes/eeglab2024.0']); %EEGlab_path

%% Experimental details
CondName = {'Auditory'};
NoConditions=length(CondName);

%%load info subj
InfoSubj=table2struct( readtable('InfoSubject.xlsx') ) ; 

Subjects={};  
for n=1:length(InfoSubj)
Subjects(n)=num2cell(InfoSubj(n).Subj)';
end

nsubj=length(Subjects);

eeglab nogui 

ElectrodeLocs=[WRKPATH,'/ChanlocsEEGlab.mat'];  %scalp channels to plot
load(ElectrodeLocs);

%load model results
load([WRKPATH, '/EncodResults/EnvModel_Uni_Subj_all_N5_lambda_100_-100_600_TRF.mat'])
%load([WRKPATH, '/EncodResults/EnvPhonMulti_Subj_all_N5_lambda_100_-100_600_TRF.mat'])


%% Plot TRF weigths at each tlag window

for cond = 1: NoConditions
    
    for lagi = 1:length(t_lag)
                 
                 lag2plot = t_lag(lagi);
                 
                 model_Fwd_acrsubj = squeeze(mean(model_Fwd_s_cond{cond}(:,lagi,:),1)); %averaged across subjects
                                   
                   %Plot
                   clear h8
                   h8=figure('Position',[100 100 900 700]);
                   
                   ylim = [-1.5 1.5];
                   topoplot(model_Fwd_acrsubj, ChanlocsFinal, 'maplimits', ylim , 'electrodes', 'off'); 
                   str=sprintf('Time Lag: %d ms', round(lag2plot)); 
                   title({['AVG TRF ', CondName{cond}],str})
                   colorbar
                   
                   baseFigNameh8 = sprintf(['GA_TRF_Topo', '_N' num2str(nsubj), '_' num2str(round(lag2plot)) 'ms' '_' CondName{cond},'.fig']);
                   fullFigNameh8 = fullfile(PATHfigure, baseFigNameh8);
                   %saveas(h8,fullFigNameh8);
                   pause
                   
                     
           close all

           clear model_Fwd_acrsubj  
                
    end   
             
end
        
