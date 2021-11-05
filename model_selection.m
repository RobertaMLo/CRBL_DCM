function model_selection(mod_a, mod_b)
% =========================================================================
% Protocol to run a DCM model selection
% FFX = Fixed Effects
% RRX = Random Effects
% =========================================================================
%   @author: robertalorenzi
%   creation date: Dec 16th, 2020
%   -----------------------------------------------------------------------
%   Input:
%   mod_a: String. Model one
%   mod_b: String. Model two
%   -----------------------------------------------------------------------
%   Last update: Dec 16th, 2020
%   -----------------------------------------------------------------------


F = NaN(5,2);
nsubjects = 6;
nmodels = 2;
start_dir = '/media/bcc/Volume/Analysis/Roberta/DCM/attention_subj'

for subject = 1:nsubjects
    if (subject == 4)
        disp('*********** no data! ***********')
    else
        name = sprintf('S%d',subject)
        glm_dir = fullfile(name,'AE','stats')
        
        for models = 1:nmodels
            name = {mod_a, mod_b};
            t_path = fullfile(pwd, glm_dir, name{models});
            temp = load(t_path);
            
            F(subject,models) = temp.DCM.F; %load F. stat for each subj
        end
    end
end

F(4,:)=[];

%% FIXED EFFECTS FFX
% Compute subject specific Bayes Factor
BF = exp(F(:,1)-F(:,2))

F(:,1)-F(:,2)

% figure;
% col= [0.7 0.7 0.7];
% barh(BF, 'facecolor', col, 'edgecolor', 'none');
% ylim([0 size(F,1)+1])
% title('Bayesian Factor', 'FontSize', 16)
% ylabel('subject', 'FontSize', 12)
% xlabel('\Delta F', 'FontSize', 12)
% text(-200, 0, 'Model 2', 'FontSize', 14)
% text(0, 200, 'Model 1', 'FontSize', 14)
% box off

figure;
col= [0.7 0.7 0.7];
barh(F(:,1)-F(:,2), 'facecolor', col, 'edgecolor', 'none');
ylim([0 size(F,1)+1])
title('log model evidence difference', 'FontSize', 16)
ylabel('subject', 'FontSize', 12)
xlabel('\Delta F', 'FontSize', 12)
text(-200, 0, 'Model 2', 'FontSize', 14)
text(0, 200, 'Model 1', 'FontSize', 14)
box off

% Compute Group Bayes Factor GBF and posterior prob pp
% GBF
sumF = sum(F,1)
GBF = exp(sumF-sumF(1))

% pp
sumF = sumF - max(sumF);
pp = exp(sumF)./sum(exp(sumF));

figure;
col = [0.6 0.6 0.6];
colormap(col);
bar(pp);
xlim([0 3])
set(gca, 'xtick', [1 2])
title('Model posterior probabilities', 'FontSize', 16)
xlabel('model', 'FontSize', 12)
ylabel('probability', 'FontSize', 12)
axis square
box off

%% RANDOM EFFECTS RRX

[alpha, exp_r, xp, pxp, bor] = spm_BMS(F, 1e6, 1, 0, 1, ones(1,size(F,2)));

figure;
col = [0.6 0.6 0.6];
colormap(col);
bar(xp);
xlim([0 3])
set(gca, 'xtick', [1 2])
title('Exceedance probabilities', 'FontSize', 16)
xlabel('model', 'FontSize', 12)
ylabel('Probability', 'FontSize', 12)
axis square
box off

% probability that each model is the most likely model across all subjects 
% taking into account the null possibility that differences in model 
% evidence are due to chance
figure;
col = [0.6 0.6 0.6];
colormap(col);
bar(xp);
xlim([0 3])
set(gca, 'xtick', [1 2])
title('Protected exceedance probabilities', 'FontSize', 16)
xlabel('model', 'FontSize', 12)
ylabel('Probability', 'FontSize', 12)
axis square
box off

figure;
col = [0.6 0.6 0.6];
colormap(col);
bar(pp);
xlim([0 3])
set(gca, 'xtick', [1 2])
title('BOR - p(best model) > 0.5', 'FontSize', 16)
xlabel('model', 'FontSize', 12)
ylabel('Probability', 'FontSize', 12)
axis square
box off
