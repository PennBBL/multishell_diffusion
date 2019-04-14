cd '/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/'

subjects = dlmread('/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/reprod_list.txt')

for i=1:length(subjects)
	
    subD = fullfile('/', 'data','joy','BBL','tutorials','exampleData','AMICO_NODDI','Processed_Data', num2str(subjects(i)))
    
    cd(subD)
   
    date = dir
      
    currD = fullfile('/', 'data','joy','BBL','tutorials','exampleData','AMICO_NODDI','Processed_Data', num2str(subjects(i)), sprintf(date(3).name), 'tractography')

    cd(currD)

	fa_path = dir([num2str(subjects(i)),'_',sprintf(date(3).name),'_','FA_matrixts.csv'])
	fa_mat = csvread(sprintf(fa_path.name),1,0);
	sqf=squareform(fa_mat);
	csvwrite([num2str(subjects(i)),'_',sprintf(date(3).name),'_','sqfa.csv'],sqf)

	icvf_path = dir([num2str(subjects(i)),'_',sprintf(date(3).name),'_','ICVF_matrixts.csv'])
	icvf_mat = csvread(sprintf(icvf_path.name),1,0);
	sqi=squareform(icvf_mat);
	csvwrite([num2str(subjects(i)),'_',sprintf(date(3).name),'_','sqicvf.csv'],sqi)

	rtop_path = dir([num2str(subjects(i)),'_',sprintf(date(3).name),'_','rtop_matrixts.csv'])
	rtop_mat = csvread(sprintf(rtop_path.name),1,0);
	sqr=squareform(rtop_mat);
	csvwrite([num2str(subjects(i)),'_',sprintf(date(3).name),'_','sqrtop.csv'],sqr)

end
