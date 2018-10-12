cd '/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/'

subjects = dlmread('~/torun.txt')

for i=1:length(subjects)
	
    subD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(i)))
    
    cd(subD)
   
    date = dir
	
   % subD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','GroupLevelAnalyses', '9_11', 'TS_matrices')
%%, sprintf(subjects(i).name))
    
      
    currD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(i)), sprintf(date(3).name), 'tractography')
	%currD = fullfile('/', 'data','joy','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', '106880', '20160819x10302', 'tractography')
    cd(currD)
%	cd '/data/jux/BBL/projects/multishell_diffusion/GroupLevelAnalyses/9_11/TS_matrices/'

    icvf_path = dir([num2str(subjects(i)),'_',sprintf(date(3).name),'_','ODI_matrixts.csv'])
    icvf_mat = csvread(sprintf(icvf_path.name),1,0);
	sqi=squareform(icvf_mat);
	csvwrite([num2str(subjects(i)),'_',sprintf(date(3).name),'_','sqODI.csv'],sqi)

	%fa_path ='/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*FA_matrixts.csv'; fa_mat = csvread(fa_path,1,0); figure, imagesc(fa_mat); colormap(jet); set(gcf,'color','white'); 

	%odi_path='/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*ODI_matrixts.csv'; sc_mat = csvread(odi_path,1,0); figure, imagesc(log(sc_mat); colormap(jet); set(gcf,'color','white')


end
