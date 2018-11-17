%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate Regional and Module-level Segregation (mean PC) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stolen/adapted from GB

% Read in regional module assignments
Yeo_part = dlmread('/data/jux/BBL/projects/pncBaumDti/Schaefer200_Yeo7_affil.txt');
full = csvread('~/SQ_ODI_All_10_1.csv')
struct_edgevec = csvread('~/SQ_ODI_All_10_1.csv',0,1)
% Define dimensions of input data
ncomms=(length(unique(Yeo_part)));
nsub=size(struct_edgevec,1);
nreg=length(squareform(struct_edgevec(1,:)));

% Allocate outputs
regional_PC=zeros(nsub,nreg);
modular_mean_PC=zeros(nsub, ncomms);

for i = 1:nsub
	% Define subject connectivity matrix
	A=squareform(struct_edgevec(i,:));

	% Calculate regional Participation Coefficient
	P=participation_coef(A, Yeo_part, 0);
	regional_PC(i,:) = P';

	% Calculate mean modular Participation Coefficient
	for j = 1:ncomms
		mod_index=find(Yeo_part==j);
		mod_nodes=P(mod_index);
		modular_mean_PC(i,j)=mean(mod_nodes);
	end
	subj = full(i,1)
end
