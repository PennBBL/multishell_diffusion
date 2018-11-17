% Wrap global efficiency calculation. Also calculates mean network strength which can be useful if you're into that kind of stuff.

addpath('/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/BCT/2017_01_15_BCT/')
cd '/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/'
subjects = dlmread('~/torun.txt')
nsub=length(subjects)
outputs=zeros(nsub,3);

%201 for 200 nodes plus 1 for IDs
nodestrs=zeros(nsub,201);

% Was having rounding problems without this. May still have rounding problems. Gore may still win the 2000 election if they do another recount. So many unknowns.

format longE

for i=1:nsub
	
    subD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(i)))
    cd(subD)
    date = dir
 
	currD = fullfile('/', 'data','jux','BBL','projects','multishell_diffusion','processedData','multishellPipelineFall2017', num2str(subjects(i)), sprintf(date(3).name), 'tractography')
	cd(currD)
	filename=[num2str(subjects(i)),'_',sprintf(date(3).name),'_','FA_matrixsc.csv']
	W = csvread((filename),1,0);
	strength=strengths_und(W);
	meanstr=mean(strength)
	efficiency_wei(W)
	% Global E and Mean Str
	% output=[num2str(subjects(i)), ', ', num2str(meanstr),', ', num2str(ans)]
	% Node Str
	strengtht=str2double(strsplit(char(strcat(num2str(subjects(i)),{'	'},(num2str(strength))))));
%cell2mat(strsplit(char(strcat(num2str(subjects(i)),{'	'},(num2str(strength))))))
	%strengtht(2:(length(strength))+1)=strength(1:200)
	%strengtht{1}={num2str(subjects(i))}
	%output=[n2str(subjects(i)), ', ', strength]
	nodestrs(i,1:201)=strengtht(1:201)
end