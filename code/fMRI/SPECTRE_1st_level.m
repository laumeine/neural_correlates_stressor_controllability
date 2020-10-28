%SPECTRE First Level
%script to perform SPMs first level analysis based on preprocessed data

%Adapted by Laura E. Meine and Jana Meier in September 2019
%Original code by Neuroimaging Center Mainz (http://www.ftn.nic.uni-mainz.de/)

function SPECTRE_1st_level
data_path = 'P:\Psychologie\Spectre\SPECTRE\MRI_data\2_preprocessed'; %input folder scans
onset_path = 'P:\Psychologie\Spectre\SPECTRE\Onsets'; % input folder onsets
output_path = 'P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level'; % output folder

addpath(genpath('C:\Program Files\spm12\')); %load spm

for subject = [1:28 30:36 38:40 42:52]; % define participants
    % special cases need to be run separately: 29 (missing data run 4), 37 (no onsets for run 4), 41 (no onsets for run 4) 
    % comment out lines for run 4!
    
    mkdir(fullfile(output_path, filesep, num2str(subject)));
    name = sprintf('%.d',subject);

    Dir1    = [data_path filesep name filesep 'run1'];
    Dir2    = [data_path filesep name filesep 'run2'];
    Dir3    = [data_path filesep name filesep 'run3'];
    Dir4    = [data_path filesep name filesep 'run4'];

    Filter1 = '^swf.*\.nii$'; % select all preprocessed files
       
    s1      = char(select_scans(Filter1, Dir1));
    s2      = char(select_scans(Filter1, Dir2));
    s3      = char(select_scans(Filter1, Dir3));
    s4      = char(select_scans(Filter1, Dir4));

    mot1    = dir(fullfile(Dir1, '\rp*.txt'));
    mot2    = dir(fullfile(Dir2, '\rp*.txt'));
    mot3    = dir(fullfile(Dir3, '\rp*.txt'));
    mot4    = dir(fullfile(Dir4, '\rp*.txt'));
        
    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    
    % MODEL SPECIFICATION
    matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(output_path, filesep, num2str(subject))}; % output directory
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    % load scans and onsets of session 1
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(s1);
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {strcat(onset_path, '\', num2str(subject), '_run1_all_onsets.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = {strcat(mot1.folder, '\', mot1.name)};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
    % load scans and onsets of session 2
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(s2);
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {strcat(onset_path, '\', num2str(subject), '_run2_all_onsets.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = {strcat(mot2.folder, '\', mot2.name)};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;
    % load scans and onsets of session 3
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).scans = cellstr(s3);
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi = {strcat(onset_path, '\', num2str(subject), '_run3_all_onsets.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).multi_reg = {strcat(mot3.folder, '\', mot3.name)};
    matlabbatch{1}.spm.stats.fmri_spec.sess(3).hpf = 128;
    % load scans and onsets of session 4
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).scans = cellstr(s4);
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).multi = {strcat(onset_path, '\', num2str(subject), '_run4_all_onsets.mat')};
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).multi_reg = {strcat(mot4.folder, '\', mot4.name)};
    matlabbatch{1}.spm.stats.fmri_spec.sess(4).hpf = 128;

    % settings for all sessions
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    % MODEL ESTIMATION
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    
    % SET CONTRASTS
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'stress_vs_base_indicator';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 1 -2 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'con_vs_nocon_indicator';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 -1 0 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'stress_fix_vs_base_fix';
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 1 1 -2];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'con_fix_vs_noc_fix';
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1 -1 0];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'con_vs_base_indicator';
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [1 0 -1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'noc_vs_base_indicator';
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 -1 0 0 0];
    matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'con_fix_vs_base_fix';
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 1 0 -1];
    matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'noc_fix_vs_base_fix';
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 1 -1];
    matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'replsc';
    matlabbatch{3}.spm.stats.con.delete = 0;
    
    save([fullfile(output_path, filesep, num2str(subject), 'job_first_level.mat')], 'matlabbatch');
    spm_jobman('run', matlabbatch);
    
    clear matlabbatch;
end; 

% --------------------------------
% subfunction for selecting scans
% --------------------------------
function [files] = select_scans(file_filt, direc);

x       = []; x   = spm_select('List', direc, file_filt);
y       = []; y   = [repmat([direc filesep], size(x, 1), 1) x repmat(',1', size(x, 1), 1)];
files = []; files = mat2cell(y, ones(size(y, 1), 1), size(y, 2));
