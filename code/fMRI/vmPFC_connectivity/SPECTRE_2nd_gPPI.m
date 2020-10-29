%SPECTRE gPPI - second level
%script to perform SPMs second level analysis (t contrast) with gPPI data

%By Laura E. Meine, September 2019

clear all

addpath(genpath('C:\Program Files\spm12\'));

data_path = 'P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level4gPPI'; %input folder
output_dir = 'P:\Psychologie\Spectre\SPECTRE\MRI_data\4_second_level4gPPI\t-test_-6_36_-8';

if ~exist(output_dir)
    mkdir(output_dir)
end

spm('defaults', 'fmri');

subjects = [1 4:10 13:17 19:26 28 30:35 38:40 42:52];
%exclude 29,37,41 (missing data for run 4), 18 (excessive motion), 3,12 (noticed more shocks in con vs. noc),
% 11(faulty digitimer, shocks not consistent), 2,27,36 (low aversiveness,
% i.e. loose/malfunctioning electrode)

for i = [1:length(subjects)]
    
    input_path = fullfile(data_path, filesep, num2str(subjects(i)), filesep, 'gPPI_-6_36_-8', filesep, 'PPI_VOI_*');
    PPIfolder = dir(input_path);
    PPIpath = strcat(PPIfolder.folder, '\', PPIfolder.name);
    s(i,:) = select_scans('con_0001', PPIpath);
end

matlabbatch{1}.spm.stats.factorial_design.dir = {output_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(s);
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'main_pos';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'main_neg';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);
clear matlabbatch;

   
% --------------------------------
% subfunction for selecting scans
% --------------------------------
function [files] = select_scans(file_filt, direc);

x       = []; x   = spm_select('List', direc, file_filt);
y       = []; y   = [repmat([direc filesep], size(x, 1), 1) x repmat(',1', size(x, 1), 1)];
files = []; files = mat2cell(y, ones(size(y, 1), 1), size(y, 2));
end
