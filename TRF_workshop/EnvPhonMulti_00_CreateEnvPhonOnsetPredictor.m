%% STEP Create the matrix with the preditors for the multivariate model

% 1. Load Envelope rescale and phoneme onset for each subject
% 2. Concatenate vector for the model (env + phon onset)
% 3. save the matrix with both predictors

%% Clear memory and the command window
clear;
close all;
clc;

%% set the path so that it specifies the correct folder on your computer
MYPATH = fileparts(pwd);
WRKPATH =[MYPATH,'/TRF_workshop'];

%Set paths Envelope
StimEnvPath=[WRKPATH,'/StimEnv/'];

%Set paths Phoneme onset
StimPhonOnsetPath=[WRKPATH,'/PhonOnset/'];
 
%Set paths output
StimMatrixPath=[WRKPATH,'/StimEnvPhonOnset/'];

% create output folder if it does not exist yet
if ~exist(StimMatrixPath)
    mkdir(StimMatrixPath);
end

%Set CND paths
CNDpath=[WRKPATH,'/dataCND/'];

% create output folder if it does not exist yet
if ~exist(CNDpath)
    mkdir(CNDpath);
end


%% Experimental details%%
CondName={'Auditory'}; %name of analyzed condition
cond=length(CondName); %number of conditions              

%%load info subj 
InfoSubj=table2struct(readtable([WRKPATH,'/InfoSubject.xlsx']) ) ; 

Subjects={}; 
nSubj=length(InfoSubj);
for n=1:nSubj
Subjects(n)=num2cell(InfoSubj(n).Subj)';
end

clear n;           

%% 3. Create matrix of env + phoneme onset predictors

for subj=1:length(Subjects)
    
    %%%[1] load feautre of interest
    %load envelope rescale
    load([StimEnvPath,strcat(num2str(Subjects{subj}),'AudioEnvSp_norm.mat')]);
    
    %load phoneme onset
    load([StimPhonOnsetPath,strcat(num2str(Subjects{subj}),'AudioPhonSp.mat')]);

    %load stim CND file to store phonemeOnset
    load([CNDpath,strcat('dataStim',num2str(Subjects{subj}),'.mat')])
    stim.names{1,2}='Phoneme Onset';        

        %%[2] Concatenate predictor for the model 
        for trial = 1:length(AudioEnvSp_rescale)
            AudioEnvPhonSp{trial} = cat(2,AudioEnvSp_rescale{trial}, AudioPhonSp{trial});

            %also store phoneme onset in CND
            stim.data{2,trial}=single(AudioPhonSp{trial});
        end
                
            %[3] save
            save([StimMatrixPath,num2str(Subjects{subj}),'AudioEnvPhonSp.mat' ], 'AudioEnvPhonSp')          
            
            %save also CND file updated
            save([CNDpath,strcat('dataStim',num2str(Subjects{subj}),'.mat') ], 'stim') 
  
  clear AudioEnvSp_rescale AudioPhonSp AudioEnvPhonSp stim

end

 disp('Done!')
  
         