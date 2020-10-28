%SPECTRE Preprocessing
%script to perform SPMs preprocessing

%Adapted by Laura E. Meine and Jana Meier in September 2019
%Original code by Neuroimaging Center Mainz (http://www.ftn.nic.uni-mainz.de/)

function SPECTRE_preprocessing
data_path = 'P:\Psychologie\Spectre\SPECTRE\MRI_data\2_preprocessed'; %input folder (raw niftis were copied there for better organisation)

for subject = [1:28 30:52] %nr of participants, 29 is missing a run, needs to be processed separately (comment out lines for run 4)
    
    %get scans from each subject for each session
    
    name = sprintf('%.d',subject);

    Dir1    = [data_path filesep name filesep 'run1'];
    Dir2    = [data_path filesep name filesep 'run2'];
    Dir3    = [data_path filesep name filesep 'run3'];
    Dir4    = [data_path filesep name filesep 'run4'];
    Dir5    = [data_path filesep name filesep 'T1'];
    Filter1 = '^f.*\.nii$'; %get raw niftis
    
    s1      = char(select_scans(Filter1, Dir1));
    s2      = char(select_scans(Filter1, Dir2));
    s3      = char(select_scans(Filter1, Dir3));
    s4      = char(select_scans(Filter1, Dir4));
    
    t1File  = spm_select('List', Dir5, '^s.*\.nii$');
    t1      = strcat(fullfile(Dir5, t1File), ',1');
    

    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    
    %%%%%%% slice timing not necessarily needed with multiband sequence (very small TR) %%%%%%%%%
    % if commented in, correct parameter values still need to be entered,
    % Also, dependencies for realignment need to be adapted
    
    % matlabbatch{1}.spm.temporal.st.scans = {
    %                                             cellstr(s1)
    %                                             cellstr(s2)
    %                                             cellstr(s3)
    %                                             cellstr(s4)
    %     }';
    % matlabbatch{1}.spm.temporal.st.nslices = 60;
    % matlabbatch{1}.spm.temporal.st.tr = 1;
    % matlabbatch{3}.spm.temporal.st.ta = 2.4082; % which value for SPECTRE?
    %(TR-(TR/nslices)?
    % matlabbatch{3}.spm.temporal.st.so = [40 39 38 37 36 35 34 33 32 31 30
    % 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5
    % 4 3 2 1]; % which values for SPECTRE?
    % matlabbatch{3}.spm.temporal.st.refslice = 30; % middle slice
    % matlabbatch{3}.spm.temporal.st.prefix = 'a';
    
 
    %%%%%%% realign & unwarp  %%%%%%%%%
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {
                                                cellstr(s1)
                                                cellstr(s2)
                                                cellstr(s3)
                                                cellstr(s4)
        }';
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1; %1=mean, 0=first
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    %%%%%%% coregister  %%%%%%%%%
    matlabbatch{2}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
    matlabbatch{2}.spm.spatial.coreg.estimate.source(1) = cellstr(t1);
    matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    %%%%%%% segmentation  %%%%%%%%%
    matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
    matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{3}.spm.spatial.preproc.channel.write = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {'C:\Program Files\spm12\tpm\TPM.nii,1'};
    matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {'C:\Program Files\spm12\tpm\TPM.nii,2'};
    matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {'C:\Program Files\spm12\tpm\TPM.nii,3'};
    matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {'C:\Program Files\spm12\tpm\TPM.nii,4'};
    matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {'C:\Program Files\spm12\tpm\TPM.nii,5'};
    matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {'C:\Program Files\spm12\tpm\TPM.nii,6'};
    matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{3}.spm.spatial.preproc.warp.write = [0 1];
    
    %%%%%%% normalization  %%%%%%%%%
    matlabbatch{4}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
    matlabbatch{4}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 2)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','cfiles'));
    matlabbatch{4}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 3)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{3}, '.','cfiles'));
    matlabbatch{4}.spm.spatial.normalise.write.subj.resample(4) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 4)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{4}, '.','cfiles'));
    matlabbatch{4}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
        78 76 85];
    matlabbatch{4}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{4}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{4}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    %%%%%%% smoothing  %%%%%%%%%
    matlabbatch{5}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{5}.spm.spatial.smooth.fwhm = [6 6 6]; % 6mm kernel
    matlabbatch{5}.spm.spatial.smooth.dtype = 0;
    matlabbatch{5}.spm.spatial.smooth.im = 0;
    matlabbatch{5}.spm.spatial.smooth.prefix = 's';
    

    %save([name '_preprocess'],'matlabbatch'); %doesn't work for some
    %reason
    spm_jobman('run', matlabbatch);
    
    clear matlabbatch;
end 

% --------------------------------
% subfunction for selecting scans
% --------------------------------
function [files] = select_scans(file_filt, direc)

x       = []; x   = spm_select('List', direc, file_filt);
y       = []; y   = [repmat([direc filesep], size(x, 1), 1) x repmat(',1', size(x, 1), 1)];
files = []; files = mat2cell(y, ones(size(y, 1), 1), size(y, 2));

