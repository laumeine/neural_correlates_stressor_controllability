function auto_gPPI
% auto_PPI analysis (RUN IN MATLAB 2015b!)
% wrapper combining create_sphere_image.m and PPPI.m by Donald McLaren

addpath 'C:\Programme\spm8' % PPPI version on NIC server doesn't run with SPM 12
addpath 'C:\Programme\spm8\toolbox\PPPI'
addpath 'P:\Psychologie\Spectre\SPECTRE\Scripts\06_gPPI' % create_sphere_image function is there

% Enter list of subject numbers
sublist = [1:52]; 

% N Voxels of interest in n x 3 matrix format
%vmPFC fixation (first local maximum with seed -6 36 -8)
VOIs_fix = [-2 40 -10; -6 42 -8; -8 32 -12; -10 40 -6; -4 34 -12; ... % subjects 1-5
        -10 40 -8; -4 40 -6; -4 40 -6; -10 36 -4; -2 36 -8; ... % 6-10
        -8 38 -10; -8 40 -6; -2 40 -6; -8 38 -10; -10 36 -4; ... % 11-15
        -6 36 -4; -8 40 -4; -10 40 -8; -8 40 -12; -2 40 -10; ... % 16-20
        -4 38 -4; -8 34 -8; -2 32 -6; -2 38 -10; -8 40 -10; ... % 21-25
        -4 32 -10; -2 40 -10; -4 40 -4; -8 32 -12; -8 38 -4; ... % 26-30
        -10 36 -8; -12 36 -8; -6 36 -14; -10 36 -4; -2 36 -6; ... % 31-35
        -2 40 -10; -2 38 -12; -8 40 -12; -2 36 -12; -2 36 -12; ... % 36-40
        -2 36 -8; -6 36 -14; -6 36 -6; -10 38 -6; -6 36 -8; ... % 41-45
        -8 32 -12; -4 32 -4; -2 36 -4; -10 40 -8; -2 34 -8; ... % 46-50
        -4 40 -10; -6 36 -14]; % 51-52
    
%vmPFC fixation (second local maximum with seed -12 44 -6)
% VOIs_fix = [-8 44 -2; -8 46 -10; -16 48 -4; -12 40 -6; -10 46 -2; ... % subjects 1-5
%         -8 44 -6; -8 42 -8; -16 42 -8; -12 46 -6; -16 46 -2; ... % 6-10
%         -8 42 -2; -8 42 -4; -16 40 -4; -14 40 -6; -14 44 -10; ... % 11-15
%         -16 44 -2; -16 48 -8; -10 42 -8; -10 48 -10; -12 42 -2; ... % 16-20
%         -10 48 -6; -10 46 -2; -8 42 -4; -8 48 -4; -10 42 -10; ... % 21-25
%         -12 48 -8; -16 46 -10; -8 46 -8; -12 38 -6; -8 40 -4; ... % 26-30
%         -10 42 -10; -12 40 -10; -14 48 -8; -8 48 -8; -12 44 -10; ... % 31-35
%         -10 48 -2; -10 48 -6; -14 46 -2; -12 44 -12; -6 44 -6; ... % 36-40
%         -14 48 -2; -16 40 -6; -10 48 -8; -10 40 -8; -16 46 -2; ... % 41-45
%         -16 48 -4; -16 48 -6; -16 48 -8; -14 44 -6; -14 48 -2; ... % 46-50
%         -8 42 -10; -16 48 -8]; % 51-52

% radius for sphere
rad = 6;

for subI = sublist
    
    % Create GLM directory name
    FirstLevelDir = ['P:\Psychologie\Spectre\SPECTRE\MRI_data\3_first_level4gPPI\', num2str(subI)];
    cd(FirstLevelDir);
        
    VOIxyz = VOIs_fix(subI,:); % make sure to use correct VOIs

    % creates a string of VOI coordinates
    VOIstr = strrep(mat2str(VOIxyz),' ','_');
    VOIstr = ['VOI_' VOIstr];
        
    % generates nifti file for VOI sphere of rad mm radius 
    create_sphere_image('SPM.mat',VOIxyz,{VOIstr},rad);

    % create P structure of ppi relevant information
    P.subject       = 'gPPI_fix';
    P.directory     = pwd;
    P.VOI           = [pwd filesep VOIstr '_mask.nii'];
    P.Region        = VOIstr;
    P.Estimate      = 1;
    P.contrast      = {'eoi_fix'}; % choose correct contrast
    P.extract       = 'eig'; % extract eigenvariate
    P.Tasks         = {'1' 'con_fix_onsets' 'noc_fix_onsets','bas_fix_onsets'}; 
    P.Weights       = [];
    P.analysis      = 'psy';
    P.method        = 'cond'; % gPPI
    P.CompContrasts = 0;
    P.Weighted=0;
    P.WB=0;

    % PPPI creates a structure containing a PPI, Y, and Psychological
    % regressor saved as *.mat file 

    PPPI(P,'fix_connectivity.mat');
end


