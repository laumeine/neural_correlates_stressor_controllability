%SPECTRE gPPI - set contrasts
%script to set contrasts of PPI regressors that can be fed into second
%level analysis

%By Laura E. Meine, September 2019

function SPECTRE_1st_gPPI
data_path = 'P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level4gPPI'; %input folder scans

addpath 'C:\Programme\spm12'
spm('defaults', 'fmri');
spm_jobman('initcfg');

subject = [1:52] %choose participants

for i=[1:length(subject)];
    % special cases need to be run separately
    
    input_path = fullfile(data_path, filesep, num2str(subject(i)), filesep, 'gPPI_-6_36_-8', filesep, 'PPI_VOI_*');
    PPIfolder = dir(input_path);
    PPIpath = strcat(PPIfolder.folder, '\', PPIfolder.name)
    cd(PPIpath); % navigate to PPI folder of current subject
    
    % SET CONTRASTS
    matlabbatch{1}.spm.stats.con.spmmat = {strcat(pwd, '\','SPM.mat')}; 
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'con_fix_vs_noc_fix';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [0 0 0 0 0 0 1 -1 0]; %contrast PPI regressors
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    spm_jobman('run', matlabbatch);
    
    clear matlabbatch;
end; 