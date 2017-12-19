cd '/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/'
subjects = dir

%subjects(1) = []
%subjects(1) = []

%output_df = zeros(66, 4)
%bblid = zeros(66, 1)
%allSubj_netStrength = zeros(66, 1)
%allSubj_betweenCon = zeros(66, 1)
%allSubj_withinCon = zeros(66, 1)
for l=3:length(subjects)
	
    subD = fullfile('/', 'data','joy','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', sprintf(subjects(l).name))
    
    cd(subD)
   
    date = dir
    
    currD = fullfile('/', 'data','joy','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', sprintf(subjects(l).name), sprintf(date(3).name), 'tractography')
	%currD = fullfile('/', 'data','joy','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', '104235', '20170623x10585', 'tractography')
   % l=3
    cd(currD)
    icvf_path = dir('*ICVF_matrixts.csv')
    icvf_mat = csvread(sprintf(icvf_path.name),1,0); 
    % figure, imagesc(icvf_mat); colormap(jet); set(gcf,'color','white'); 

	%fa_path ='/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*FA_matrixts.csv'; fa_mat = csvread(fa_path,1,0); figure, imagesc(fa_mat); colormap(jet); set(gcf,'color','white'); 

	%odi_path='/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/tractography/*ODI_matrixts.csv'; sc_mat = csvread(odi_path,1,0); figure, imagesc(log(sc_mat); colormap(jet); set(gcf,'color','white')

	% Define community affiliation vector
	input_commAff=dlmread('/data/joy/BBL/projects/pncBaumDti/Schaefer200_Yeo7_affil.txt')

	% A = connectivity matrix
	A = icvf_mat;
    Avec=squareform(A)';
    total_strength=sum(Avec);

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
        %number of subjects by number of modules 
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
    
    %network specific values
    withinConn=comm_wb_mat(:,1)'
    
    % print stuff to csvs
   % ICVF_csvcontents = [Avg_Within_Conn,Avg_Between_Conn,total_strength];
    csvwrite('ICVFNetworkCon.csv', withinConn) 
    
    % Total strength
    allSubj_netStrength(l) = total_strength;
    
    % subject id
    %bblid(l)= sprintf('%s',subjects(l).name)
    
    % withincon
   allSubj_betweenCon(l) = Avg_Between_Conn;
   
   % betweencon
   allSubj_betweenCon(l) =  Avg_Within_Conn;
   
end

%output_df(:,1) = bblid;
%output_df(:,2) = allSubj_netStrength;
%output_df(:,3) = allSubj_betweenCon;
%output_df(:,4) = allSubj_withinCon;

%dlmwrite('/data/joy/BBL/projects/multishell_diffusion/processedData/Connectivity/within_between_strength.csv', output_df)
