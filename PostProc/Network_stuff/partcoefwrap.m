% Wrap participation coefficient on list of subjects (~/torun.txt)

addpath('/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/BCT/2017_01_15_BCT')
subjects = dlmread('~/torun.txt')
ci = dlmread('/data/jux/BBL/projects/pncBaumDti/Schaefer200_Yeo7_affil.txt')
for x=1:length(subjects)
currD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(x)))
cd(currD)
date = dir
%file = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(x)), sprintf(date(3).name), 'tractography')
file = ([pwd, '/', sprintf(date(3).name), '/', 'tractography', '/', num2str(subjects(x)),'_',sprintf(date(3).name),'_','ICVF_matrixts.csv'])
W = csvread(file, 1,0)

% From brain connectivity toolbox
participation_coef(W,ci)
filename = ([sprintf(date(3).name), '/', 'tractography', '/', num2str(subjects(x)),'_',sprintf(date(3).name),'_','PartCoef.csv'])
csvwrite(ans,filename)
end

