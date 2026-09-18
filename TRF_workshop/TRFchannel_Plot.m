%% PLOT TRF single channel

%% Clear memory and the command window
clear;
close all;
clc;

%% set the path so that it specifies the correct folder on your computer
MYPATH = fileparts(pwd);
WRKPATH =[MYPATH,'/TRF_workshop'];

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

%Final sampling rate envelopes and EEG to
Fs=100; 
                                        
chan_name = {'Fz';'CZ';'OZ'}; %10-20 analog from EGI layout; channels to which visualize TRFs
chan_idx = {31; 32; 16}; %channel indices                                             

%% Load file
load([WRKPATH, '/EncodResults/EnvModel_Uni_Subj_all_N5_lambda_100_-100_600_TRF.mat'])

%% Plot TRF single channel
for cond=1:NoConditions
    
  for subj=1%:length(Subjects)
   
      subject=Subjects{subj};
      
       %%Plot individual TRFs 
        clear i
        for i = 1:length(chan_idx)

            clear h2
            h2 = figure('Position',[100 100 300 200]);
            plot(t_lag,model_Fwd_s_cond{cond,1}(subj,:,chan_idx{i}), 'LineWidth', 3);      
            axis([-100 600 -1.5 1.5])
            xlabel('Time Lag (ms)'); ylabel('TRF (a.u.)');
            title({['TRF ' chan_name{i}] Subjects{subj}});
            
            baseFigNameh2 = sprintf(['TRF_cond%s','_',num2str(Subjects{subj}),'_chan_', chan_name{i},'.fig'],CondName{cond}); 
            fullFigNameh2 = fullfile(PATHfigure, baseFigNameh2);
            %saveas(h2,fullFigNameh2);              
        end

        %pause
           
  end
                
 
end
  

%% Plot Overlayed GA TRFs mean with SEM 
 
clear nsubj
nsubj = length(Subjects);


%%Plot
        clear i
        for i = 1:length(chan_idx)
            
            clear cond
            for cond = 1:NoConditions

                subTRF_cond = model_Fwd_s_cond{cond}(:,:,:);
                
                subTRF_chan = subTRF_cond(:,:,chan_idx{i});
                subTRF_chan_GA(cond,:) = squeeze(mean(subTRF_chan,1)); %averaged across subjects
                             
                clear k
                for k=1:size(subTRF_chan,2)
                 OutputERR(cond,k)=std(subTRF_chan(:,k))/sqrt(size(subTRF_chan,1));
                end
           
                lowerERR(cond,:)=subTRF_chan_GA(cond,:)-OutputERR(cond,:);
                upperERR(cond,:)=subTRF_chan_GA(cond,:)+OutputERR(cond,:);    
                
                clear subTRF_cond subTRF_chan  
               
            end                                                                 
                
            clear h5b 
                h5b = figure('Position',[100 100 300 200]);
            
                plot(t_lag, subTRF_chan_GA(cond,:), 'LineWidth', 2, 'DisplayName',CondName{1}); 
                hold on
                evb_ciplot(lowerERR(cond,:), upperERR(cond,:), t_lag, 0.2);
                axis([-100 600 -1.5 1.5])
                title({'avg TRF' chan_name{i}})

                         
              baseFigName = sprintf(['TRF_GA', '_chan_', chan_name{i},'_N', num2str(nsubj) '.fig']); 
              fullFigName = fullfile(PATHfigure, baseFigName);
              %saveas(h5b,fullFigName);
        
                 
            clear subTRF_chan_GA  
            clear lowerERR upperERR OutputERR 
            
      end