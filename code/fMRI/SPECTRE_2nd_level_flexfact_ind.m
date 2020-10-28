%SPECTRE Second Level FlexFact - indicator phase
%script to perform SPMs second level analysis based on betas estimated in
%first level analysis using a flexible factorial model

%Adapted by Laura E. Meine in September 2020
%Original code by Benjamin Meyer, Neuroimaging Center Mainz, 16.06.2020

clear variables 
close all
clc

sublist = [1 4:10 13:17 19:26 28 30:35 38:40 42:52];
%exclude 29,37,41 (missing data for run 4), 18 (excessive motion), 3,12 (noticed more shocks in con vs. noc),
% 11(faulty digitimer, shocks not consistent), 2,27,36 (low aversiveness,
% i.e. loose/malfunctioning electrode)

outdir  = ['P:\Psychologie\Spectre\SPECTRE\MRI_data\4_second_level\flexfact_ind'];

if ~exist(outdir)
    mkdir(outdir)
end

addpath(genpath('C:\Program Files\spm12\'));

%1 factor with 3 levels
matlabbatch{1}.spm.stats.factorial_design.dir                           = {outdir};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name        = 'Condition'; %controllable, uncontrollable, baseline
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept        = 1; %not independent (allow for dependencies between measurements)
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance    = 1; %not assuming equal variance (baseline condition is rather different)
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca       = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova      = 0;

%subject random factor
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name        = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept        = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance    = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca       = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova      = 0;

%get relevant betas from first level
for i=1:length(sublist)    
    subRNR      = i;
    sub         = sublist(i);
    substr      = sprintf('%02d',sub);  
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(subRNR).scans = {
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0001.nii,1']; % con ind run1
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0002.nii,1']; % noc ind run1
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0003.nii,1']; % bas ind run1
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0013.nii,1']; % con ind run2
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0014.nii,1']; % noc ind run2
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0015.nii,1']; % bas ind run2
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0025.nii,1']; % con ind run3
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0026.nii,1']; % noc ind run3
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0027.nii,1']; % bas ind run3
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0037.nii,1']; % con ind run4
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0038.nii,1']; % noc ind run4
        ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level\' num2str(sub) filesep 'beta_0039.nii,1']; % bas ind run4
        };
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(subRNR).conds = [1
        2
        3
        1
        2
        3
        1
        2
        3
        1
        2
        3
        ];
end

matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum   = 1; %condition main effect
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum   = 2;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {}); %no covariate
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; %no masking
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%set contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'con_ind_vs_noc_ind';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'noc_ind_vs_con_ind';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'stress_ind_vs_bas_ind';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 1 -2];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'bas_ind_vs_stress_ind';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [-1 -1 2];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'con_ind_vs_bas_ind';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [1 0 -1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'noc_ind_vs_bas_ind';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 1 -1];
matlabbatch{3}.spm.stats.con.delete = 0;

spm_jobman('run',matlabbatch);
