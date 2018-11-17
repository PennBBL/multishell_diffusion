%% get within and average and individualized between network connectivity of networks of subjects
% subjects specified in ~torun.txt
% networks specified in yeo_7_afil
% connectivity matrices specified in path_name
% Output currently set to print out individual networks for individual subjects

cd '/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/'
subjects = dlmread('~/torun.txt')
for x=1:length(subjects)
	
    subD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(x)))
    
    cd(subD)
   
    date = dir
    
    currD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(x)), sprintf(date(3).name), 'tractography')
	%currD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', '106880', '20160819x10302', 'tractography')
    cd(currD)
	%filename=[num2str(subjects(x)),'_',sprintf(date(3).name),'_','ICVF_matrixts.csv']
    icvf_path = fullfile('/','data','jux','BBL','projects','multishell_diffusion', 'GroupLevelAnalyses', '10_1', 'TS_matrices')
	cd(icvf_path)
	path_name = dir([num2str(subjects(x)),'_',sprintf(date(3).name),'_','FA_matrixsc.csv'])
   icvf_mat = csvread((path_name.name),1,0);
	%figure, imagesc(icvf_mat); colormap(jet); set(gcf,'color','white'); 

	%fa_path ='/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*FA_matrixts.csv'; fa_mat = csvread(fa_path,1,0); figure, imagesc(fa_mat); colormap(jet); set(gcf,'color','white'); 

	%odi_path='/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*ODI_matrixts.csv'; sc_mat = csvread(odi_path,1,0); figure, imagesc(log(sc_mat); colormap(jet); set(gcf,'color','white')

	%Define community affiliation vector
	input_commAff=dlmread('/data/jux/BBL/projects/pncBaumDti/Schaefer200_Yeo7_affil.txt')

	% A = connectivity matrix
	A = icvf_mat;

	% Define Modules and Nodes in network
	unique_S=unique(input_commAff);
	numNodes=length(A)

	% Number of communities 
	numComm=length(unique_S);

	% Set diagonal of adjacency matrix to nan
	A=A + diag(repmat(nan,[numNodes,1]));

	% Define community by community matrix
	comm_comm_mat=zeros(numComm,numComm);

	% Define Within/Between Module connectivity matrix
	comm_wb_mat=zeros(numComm,2);
	wb_vec=zeros(1,2);
	com1 = 1
	for i=unique_S'
		com2 = 1;
		% Define index for nodes in each community
		comidx = find(input_commAff==i);
		not_comidx=find(input_commAff~=i)
		for j = unique_S'
			comidx_2= find(input_commAff==j);
			% Get mean edge weights of edges connecting each pair of communities
			% Pair-wise Between-module connectivity
			current_edges=A(comidx,comidx_2);
			mean_edgeWeight=nanmean(nanmean(current_edges));
			% Define a community X community matrix for each pair of communities
			comm_comm_mat(com1,com2)=mean_edgeWeight;
			com2= com2 + 1;
		end

		% Within module connectivity
		comm_wb_mat(i,1) = nanmean(nanmean(A(comidx,comidx)));
		% Between module connectivity
		comm_wb_mat(i,2) = nanmean(nanmean(A(comidx,not_comidx)));

		com1 = com1 + 1;

	end

	% Compute the overall average within- and between-module connectivity
	within = logical(bsxfun(@eq,input_commAff,input_commAff'));
	wb_vec(1) = nanmean(A(within));
	wb_vec(2) = nanmean(A(~within));

	within_between_ratio = wb_vec(1) / wb_vec(2)

	% Average Within-Module Connectivity
	Avg_Within_Conn=wb_vec(1)
	% Average Between-Module Connectivity
	Avg_Between_Conn=wb_vec(2)
    
    % print stuff to csvs
    ICVF_csvcontents = [num2str(subjects(x)), ', ' num2str(wb_vec(1)), ', ' num2str(wb_vec(2))]
	csv_name=[num2str(subjects(x)), '_', sprintf(date(3).name), '_','SCcon_ind_nets.csv']
  % dlmwrite(csv_name,ICVF_csvcontents) 
	dlmwrite(csv_name, comm_wb_mat)

end
