%% PLOT TRF TOPO window in step of 40 ms

%% Clear memory and the command window
clear all
close all
clc

%% Set paths
MYPATH = fileparts(pwd);
WRKPATH =[MYPATH,'/TRF_workshop'];

%Software
addpath([WRKPATH,'/Toolboxes/eeglab2024.0']);    % EEGlab_path

%Define the path to save the figure results
PATHfigure=[WRKPATH,'/Figure/'];
% create output folder if it does not exist yet
if ~exist(PATHfigure)
    mkdir(PATHfigure);
end

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

%% Plot TRF weigths

twindStart = 0:40:440;
twind=4;

for cond = 1:NoConditions

    t0=find(t_lag==0);

    clear h8
    h8=figure('Position',[100 100 1400 800]);
    
    for lagi = 1:length(twindStart)
                       
            lagwind=t0:t0+(twind-1);
                  
                model_Fwd_acrlagwind = squeeze(mean(model_Fwd_s_cond{cond}(:,lagwind,:),2)); %averaged across lag within the window             
                model_Fwd_acrsubj = squeeze(mean(model_Fwd_acrlagwind,1)); %averaged across subjects
                                                                                
                   %Plot Topo Envelope TRF
                   subplot(3,4,lagi)
                   ylim = [-1.5 1.5];
                   topoplot(model_Fwd_acrsubj, ChanlocsFinal, 'maplimits', ylim , 'electrodes', 'off'); 
                   title({t_lag(lagwind(1)) t_lag(lagwind(end)+1)})                                          
                 
           clear model_Fwd_acrsubj   
           
           t0=t0+twind;
                
    end   

    sgtitle(sprintf('Envelope TRF'));
                  
    baseFigNameh8 = sprintf(['UniModel_GA_Envelope_TRF_Topo_Window', '_N' num2str(nsubj), '_', CondName{cond},'.fig']);
    fullFigNameh8 = fullfile(PATHfigure, baseFigNameh8);
    saveas(h8,fullFigNameh8); 

end
