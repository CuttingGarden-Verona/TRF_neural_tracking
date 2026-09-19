%% STEP 2 ENCODING

% Performe Univariate Encoding Model with speech envelope as predictor using the Optimal Lambda obtained in previous steps

%% Clear memory and the command window
clear;
close all;
clc;

%%  Set paths
MYPATH = fileparts(pwd);
WRKPATH =[MYPATH,'/TRF_workshop'];
 
%%Software
addpath([WRKPATH,'/Toolboxes/mTRF-Toolbox_v2/mtrf/']);       

%%EEG processed trials
CNDpath=[WRKPATH,'/dataCND/'];

%%Audio envelpe trials
PATHINstim=[WRKPATH,'/StimEnv/'];

%Define the path for save TRF results
PATHOUT=[WRKPATH,'/EncodResults/']; 

% create output folder if it does not exist yet
if ~exist(PATHOUT)
    mkdir(PATHOUT);
end
 

%% Experimental details

%%load info subj
InfoSubj=table2struct( readtable('InfoSubject.xlsx') ) ; 

Subjects={};  
for n=1:length(InfoSubj)
Subjects(n)=num2cell(InfoSubj(n).Subj)';
end

CondName = {'Auditory'}; %specify names for condition
NoConditions=length(CondName);  %number of conditions                   

%% Specify Parameters needed to run the model
%Specify the sampling rate
Fs=100; 

%%T-lag values 
MinTlag=-100; %minimum time lag to consider (ms)
MaxTlag=600;  %maximum time lag to consider (ms)  

%direction of the model
ModDir = 1;   %"1" = encoding; "-1" = decoding

%best regularization parameter previously estimated using the cross-validation
scalp_lambda=100;                                 

%% Speech-EEG Encoding model

for cond=1:NoConditions
    
 for subj=1:length(Subjects)
     
     %%Load normalized Audio envelope and normalized EEG trials
     %load Audio Envelope rescale     
     stimNameNorm='AudioEnvSp_norm.mat';
     AudioFeature_norm = dir(fullfile(PATHINstim, [num2str(Subjects{subj}),stimNameNorm])); 
     AudioFullPaths_norm = fullfile({AudioFeature_norm.folder}, {AudioFeature_norm.name}); 

     load(AudioFullPaths_norm{1}); 
     AudioFeatureSp=AudioEnvSp_rescale;


     %load EEG data
     MYfiles_Nom = dir([CNDpath 'dataSub' num2str(Subjects{subj}) '.mat']); 
     FileFullPaths_Norm = fullfile({MYfiles_Nom.folder}, {MYfiles_Nom.name});

     load(FileFullPaths_Norm{1});

     %Standardise EEG data (preserving the ratio between channels) 
     eeg = cndNormalise(eeg);
     EEGs=eeg.data;

         
     %%Select for each condition separately     
     AudioFeatureSps_cond=AudioFeatureSp(cond,:);  %Speech envelope
     EEGs_cond=EEGs(cond,:);                 %EEG data
    
     %%Forward TRF model   
     fprintf('Encoding model Subject %s...\n', num2str(Subjects{subj}));    
 
        ntr=size(AudioFeatureSps_cond,2);
        
        for test_tr = 1:ntr
            %test_tr is the testing, trial train on all others
            train_trs = setxor(1:ntr,test_tr);
            
            %fit the model with the optimal lambda to all training trials
            mdl_Env{test_tr} = mTRFtrain(AudioFeatureSps_cond(train_trs), EEGs_cond(train_trs), Fs, ModDir, MinTlag, MaxTlag,scalp_lambda,'Verbose',false);                                               
        
            %test on the left out trial
            [~,stats_test] = mTRFpredict(AudioFeatureSps_cond{test_tr},EEGs_cond{test_tr},mdl_Env{test_tr}, 'Verbose',false);
            r_Env(test_tr,:) = stats_test.r;
        
        end

        %mean across trials
        r_Fwd_s =  squeeze(mean(r_Env,1)); 
        
        %train model on all trials
        mdl_all_Env= mTRFtrain(AudioFeatureSps_cond, EEGs_cond, Fs, ModDir, MinTlag, MaxTlag,scalp_lambda,'Verbose',false);                                               
        model_Fwd_s = mdl_all_Env.w; 
        t_lag=mdl_all_Env.t;

        %%Get model weights and corr coeff for each subject for that condition             
        model_Fwd_s_cond{cond}(subj,:,:)= model_Fwd_s; 
        r_Fwd_s_cond{cond}(subj,:)=r_Fwd_s;
        
   
        clear mdl_Env mdl_all_Env stats_test r_Env

      clear model_Fwd_s r_Fwd_s
 
    clear AudioFeatureSps_cond EEGs_cond AudioFeatureSp EEGs AudioEnvSp_rescale eeg

 end
 
end
  
    nsubj=length(Subjects);
    
    save([PATHOUT, 'EnvModel_Uni_Subj_all', '_N' num2str(nsubj) '_lambda_', num2str(scalp_lambda), '_', num2str(MinTlag), '_', num2str(MaxTlag), '_TRF', '.mat'], 'model_Fwd_s_cond','r_Fwd_s_cond','t_lag');

    disp('Done!')


