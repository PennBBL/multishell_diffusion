% Get squareform of all subjects in directory specified below. Currently set to streamline count-assessed connectivity matrix in their tractography folder

cd '/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/'
subjects = dir

for i=3:length(subjects)
	
    subD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', sprintf(subjects(i).name))
    
    cd(subD)
   
    date = dir
    
    currD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', sprintf(subjects(i).name), sprintf(date(3).name), 'tractography')
	%currD = fullfile('/', 'data','joy','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', '106880', '20160819x10302', 'tractography')
    cd(currD)
    icvf_path = dir('*ODI_matrixsc.csv')
    icvf_mat = csvread(sprintf(icvf_path.name),1,0);
	sqi=squareform(icvf_mat);
	csvwrite('sqsc.csv',sqi)

	%fa_path ='/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*FA_matrixts.csv'; fa_mat = csvread(fa_path,1,0); figure, imagesc(fa_mat); colormap(jet); set(gcf,'color','white'); 

	%odi_path='/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*ODI_matrixts.csv'; sc_mat = csvread(odi_path,1,0); figure, imagesc(log(sc_mat); colormap(jet); set(gcf,'color','white')


end
