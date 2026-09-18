%% STEP 1 TUNING OF REGULARIZATION PARAMETER

% 1. Load normalized Audio envelope + phoneme onset and normalized EEG trials
% 2. Estimate the 'best' lambda (ridge/regularization parameter) via cross-val on normalized data
% 3. Plot mse for each lambda 

%% Clear memory and the command window
clear;
close all;
clc;

%% Set specific paths
MYPATH = fileparts(pwd);
WRKPATH =[MYPATH,'/TRF_workshop'];

%%Software
addpath([WRKPATH,'/Toolboxes/mTRF-Toolbox_v2/mtrf']);        

%%EEG processed trials
CNDpath=[WRKPATH,'/dataCND/'];

%%Audio envelpe + phoneme onset trials
PATHINstim=[WRKPATH,'/StimEnvPhonOnset/'];

%Define the path for save lambda results
PATHOUT=[WRKPATH,'/Crossval_results/']; 
    
% create output folder if it does not exist yet
if ~exist(PATHOUT)
    mkdir(PATHOUT);
end

%% Parameters

%load a table with information subject (i.e., code Subj, CodeStory, NameStory)
InfoSubj=table2struct( readtable('InfoSubject.xlsx') ) ; 

%creare a cell array with the analyzed subjects
nSubj=length(InfoSubj);
Subjects={}; 
for n=1:nSubj
Subjects(n)=num2cell(InfoSubj(n).Subj)';
end

clear n;
                                 
CondName={'Auditory'}; %specify names for condition
cond=length(CondName); %number of conditions 

%% Parameters for the Encoding/Decoding model
%Specify the sampling rate
Fs=100;

%%T-lag values 
MinTlag=-100; %minimum time lag to consider (ms)
MaxTlag=600;  %maximum time lag to consider (ms)  

%direction of the model
ModDir = 1;   %"1" = encoding; "-1" = decoding

%set lambda values
lambdas = 10.^(-2:1:5); % very wide range

%% Load Audio envelope and EEG trials

for subj=1:length(Subjects)
       
     %%[1] Load stimulus and EEG trials
     %load Audio Envelope rescale + Phoneme Onset    
     stimNameNorm='AudioEnvPhonSp.mat';
     AudioFeature_norm = dir(fullfile(PATHINstim, [num2str(Subjects{subj}),stimNameNorm])); 
     AudioFullPaths_norm = fullfile({AudioFeature_norm.folder}, {AudioFeature_norm.name}); 

     load(AudioFullPaths_norm{1}); 
     AudioFeatureSp=AudioEnvPhonSp;


     %load EEG data
     MYfiles_Nom = dir([CNDpath 'dataSub' num2str(Subjects{subj}) '.mat']); 
     FileFullPaths_Norm = fullfile({MYfiles_Nom.folder}, {MYfiles_Nom.name});

     load(FileFullPaths_Norm{1});
 
     %Standardise EEG data (preserving the ratio between channels) 
     eeg = cndNormalise(eeg);
     EEGs=eeg.data;


        %%[2] Lambda Test 
        fprintf('Cross validation Subject %s...\n', num2str(Subjects{subj}));    
 
        %Estimate lambda via crossval
        [stats] = mTRFcrossval(AudioFeatureSp, EEGs, Fs, ModDir, MinTlag, MaxTlag, lambdas, 'Verbose',false);
    
        mse_mean_SpFeature = mean(stats.err,1); %avg across trials
        mse_mean_SpFeature_subj(subj,:) = squeeze(mean(mse_mean_SpFeature,3)); %avg across electrodes   
            
        r_mean_SpFeature = mean(stats.r,1); %avg across trials
        r_mean_SpFeature_subj(subj,:) = squeeze(mean(r_mean_SpFeature,3)); %avg across electrodes


            %[3] Plot the result of cross-val for each participant
            [M_mse,I_mse] = min(mse_mean_SpFeature_subj(subj,:));        
            [M_r,I_r] = max(r_mean_SpFeature_subj(subj,:));
          
            mse_opt_lambda(subj,:) = lambdas(I_mse);
            r_opt_lambda(subj,:) = lambdas(I_r);
            
            %Obtain prediction metrics as MSE
            x = lambdas;
            y1 = mse_mean_SpFeature_subj(subj,:);
           
            h1 = figure('Position', [100 100 700 700]);
            plot(x, y1, '-bo', x(I_mse), y1(I_mse),'b*'); 
            title(['Cross-validation: lambda subj' num2str(subj)])
            set(gca, 'xscale', 'log')
            ax = gca;
            ax.YAxis.Exponent = 0; 
         
            ylabel('MSE')
            xlabel('Lambda')
            
       
            baseFigName = sprintf(['%s_crossval_lambda_Sp_Multi_cond_',CondName{1}, '_' ,num2str(MinTlag), '_', num2str(MaxTlag), '.fig'],num2str(Subjects{subj}));
            fullFigName = fullfile(PATHOUT, baseFigName);
            saveas(h1,fullFigName);
                
        clear I_mse mse_mean_SpFeature r_mean_SpFeature
        clear y1 h1
        %close all 

clear eeg EEGs AudioEnvPhonSp AudioFeatureSp

 end

%%  %[3] Plot the result of cross-val across participants
            [M_mse,I_mse] = min(mean(mse_mean_SpFeature_subj));        
            [M_r,I_r] = max(mean(r_mean_SpFeature_subj));
                    
            %Obtain prediction metrics as MSE
            x = lambdas;
            y1 = mean(mse_mean_SpFeature_subj);
           
            h1 = figure('Position', [100 100 700 700]);
            plot(x, y1, '-bo', x(I_mse), y1(I_mse),'b*'); 
            title(['Cross-validation: lambda mean subj'])
            set(gca, 'xscale', 'log')
            ax = gca;
            ax.YAxis.Exponent = 0; 
         
            ylabel('MSE')
            xlabel('Lambda')
            

save([PATHOUT,'LambdaTest_Multi' 'N' num2str(length(Subjects)) '_SpFeature', num2str(MinTlag), '_', num2str(MaxTlag), '.mat'], 'mse_mean_SpFeature_subj','r_mean_SpFeature_subj','lambdas') 
disp ('Done!')


