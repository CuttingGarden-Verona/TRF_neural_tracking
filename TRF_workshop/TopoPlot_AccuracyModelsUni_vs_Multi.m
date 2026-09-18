%% PLOT TOPO MODEL ACCURACY

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
cond=length(CondName);                   

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

%% plot topo 

%%Prediction Accuracy (r) of the Model Uni
%load model
UniModel=load([WRKPATH, '/EncodResults/EnvModel_Uni_Subj_all_N5_lambda_100_-100_600_TRF.mat']);
                            
               avgAcc_Fwd_acrsubj = mean(UniModel.r_Fwd_s_cond{cond}(:,:),1); %averaged across subjects
                    
                   %Plot                   
                   clear h10
                   h10=figure('Position',[100 100 900 700]);
  
                   ylim = [-.05 .05]; 
                   topoplot(avgAcc_Fwd_acrsubj, ChanlocsFinal, 'maplimits', ylim , 'electrodes', 'off'); 
                   str=sprintf('Model between -100 600'); 
                   title({['AVG ACC Uni Model Env ', CondName{cond}],str})
                   colorbar
                   
                   baseFigNameh10 = sprintf(['GA_ACC_UniModel_Topo', '_N' num2str(nsubj), '_' CondName{cond},'.fig']);
                   fullFigNameh10 = fullfile(PATHfigure, baseFigNameh10);
                   saveas(h10,fullFigNameh10);
                                       

%% Prediction Accuracy (r) of the Multi Model
%load model
MultiModel=load([WRKPATH, '/EncodResults/EnvPhonMulti_Subj_all_N5_lambda_100_-100_600_TRF.mat']);

                               
                avgAcc_Fwd_acrsubj = mean(MultiModel.r_Fwd_s_cond{cond}(:,:),1); %averaged across subjects
                    
                   %Plot
                   clear h11
                   h11=figure('Position',[800 100 900 700]);
  
                   ylim = [-.05 .05]; 
                   topoplot(avgAcc_Fwd_acrsubj, ChanlocsFinal, 'maplimits', ylim , 'electrodes', 'off'); 
                   str=sprintf('Model between -100 600'); 
                   title({['AVG ACC Multi Model Env+PhonOnset ', CondName{cond}],str})
                   colorbar
                   
                   baseFigNameh11 = sprintf(['GA_ACC_MultiModel_Topo', '_N' num2str(nsubj), '_' CondName{cond},'.fig']);
                   fullFigNameh11 = fullfile(PATHfigure, baseFigNameh11);
                   saveas(h11,fullFigNameh11);
                      
                    
                
