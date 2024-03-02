function GF = model_selection(protDir, GCM_filename)
% =========================================================================
% BMS FFX of GCM full mat
% =========================================================================
%   @author: robertalorenzi
%   creation date: Oct 27th, 2021
%   -----------------------------------------------------------------------
%   Input:
%   parent_dir : String. path of the parent folder where GLM file is stored
%   GCM_filename: String. .mat file of GCM
%
%   !!!! NEXT UPDATES: make the code flexible for BF and GBF for more
%   than 2 models!!!!!!

%   -----------------------------------------------------------------------
%   Last update:
%   -----------------------------------------------------------------------

   current_dir = pwd;
    
   load(fullfile(protDir,'GCM_models',GCM_filename));
    
    F = NaN(size(GCM,1), size(GCM,2));
    
    for nmodels = 1:size(GCM,2)
        for subj = 1:size(GCM,1)
            
            F(subj,nmodels) = GCM{subj,nmodels}.F ; %get the log model evidence
        
        end
    end
    
    %Compute subject specific Bayes Factor --------------------------------
    %BFi,j = p(y|mi) - p(y|mj) -----------------------------------------------
    delta_F = F(:,4)-F(:,5)
    
    
    figure;
    col= [0.7 0.7 0.7];
    barh(delta_F, 'b','facecolor', col, 'edgecolor', 'none');
    ylim([0 size(F,1)+1])
    title('log model evidence difference', 'FontSize', 16)
    ylabel('subject', 'FontSize', 12)
    xlabel('\Delta F', 'FontSize', 12)
    text(-200, 0, 'Model 2', 'FontSize', 14)
    text(0, 200, 'Model 1', 'FontSize', 14)
    box off
    
%     delta_F = F(:,1)-F(:,3)
%     
%     
%     figure;
%     col= [0.7 0.7 0.7];
%     barh(delta_F, 'm','facecolor', col, 'edgecolor', 'none');
%     ylim([0 size(F,1)+1])
%     title('log model evidence difference', 'FontSize', 16)
%     ylabel('subject', 'FontSize', 12)
%     xlabel('\Delta F', 'FontSize', 12)
%     text(-200, 0, 'Model 2', 'FontSize', 14)
%     text(0, 200, 'Model 1', 'FontSize', 14)
%     box off
%     
%     delta_F = F(:,2)-F(:,3)
%     
%     
%     figure;
%     col= [0.7 0.7 0.7];
%     barh(delta_F, 'm','facecolor', col, 'edgecolor', 'none');
%     ylim([0 size(F,1)+1])
%     title('log model evidence difference', 'FontSize', 16)
%     ylabel('subject', 'FontSize', 12)
%     xlabel('\Delta F', 'FontSize', 12)
%     text(-200, 0, 'Model 2', 'FontSize', 14)
%     text(0, 200, 'Model 1', 'FontSize', 14)
%     box off
    %% FIXED EFFECT ANALYSIS ----------------------------------------------
    %compute the Group Bayes Factor----------------------------------------
    %GBF_ij = Prod_ksub (BF_ij)^(k)----------------------------------------
    sumF = sum(F,1)
    GBF = exp(sumF-sumF(1))

    % pp
    sumF = sumF - max(sumF);
    pp = exp(sumF)./sum(exp(sumF));

    figure;
    col = [0.6 0.6 0.6];
    colormap(col);
    bar(pp, 'b');
    xlim([0 10])
    set(gca, 'xtick', [1 2 3 4, 5, 6, 7, 8])
    title('FFX BMS', 'FontSize', 16)
    xlabel('model', 'FontSize', 12)
    ylabel('posterior probability', 'FontSize', 12)
    axis square
    box off
    
    %% RANDOM EFFECTS ANALYSIS---------------------------------------------
   
    [alpha, exp_r, xp, pxp, bor] = spm_BMS(F, 1e6, 1, 0, 1, ones(1,size(F,2)));

    figure;
    col = [0.6 0.6 0.6];
    colormap(col);
    bar(xp, 'm');
    xlim([0 7])
    set(gca, 'xtick', [1 2 3 4 5 6])
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
    bar(xp,'m');
    xlim([0 7])
    set(gca, 'xtick', [1 2 3 4 5 6])
    title('Protected exceedance probabilities', 'FontSize', 16)
    xlabel('model', 'FontSize', 12)
    ylabel('Probability', 'FontSize', 12)
    axis square
    box off

    figure;
    col = [0.6 0.6 0.6];
    colormap(col);
    bar(bor, 'm');
    xlim([0 7])
    set(gca, 'xtick', [1 2 3 4 5 6])
    title('BOR - p(best model) > 0.5', 'FontSize', 16)
    xlabel('model', 'FontSize', 12)
    ylabel('Probability', 'FontSize', 12)
    axis square
    box off
%     
    cd(current_dir)
    
    
end

