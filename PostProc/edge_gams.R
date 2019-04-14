# Load libraries
library(mgcv)
library(visreg)
library(ggplot2)
library(parallel)
library(multilevel)
library(pracma)

# Load data
demographics_20180824 <- read.csv("/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/demographics_20180824.csv", comment.char="#")
sqFA<- read.csv("~/facon_all.csv", header = FALSE)
sqICVF<- read.csv("~/icvfcon_all.csv", header = FALSE)
sqRTOP<- read.csv("~/rtopcon_all.csv", header = FALSE)
QAgrmpy_9_12 <- read.csv("/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/QAgrmpy_9_12.csv")
ids <- read.delim("/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/reprod_list.txt", header=FALSE)

# attach scalar metric suffix to each column name
for (i in 1:length(colnames(sqFA))) {
  names(sqFA)[i]<-paste((colnames(sqFA)[i]),"_FA", sep = "")
}

for (i in 1:length(colnames(sqICVF))) {
  names(sqICVF)[i]<-paste((colnames(sqICVF)[i]),"_ICVF", sep = "")
}

for (i in 1:length(colnames(sqRTOP))) {
  names(sqRTOP)[i]<-paste((colnames(sqRTOP)[i]),"_RTOP", sep = "")
}

# attach Subj IDs
colnames(ids)<-c("bblid")
ids$bblid->sqFA$bblid
ids$bblid->sqICVF$bblid
ids$bblid->sqRTOP$bblid

# attach demographics (for age)
df<-merge(demographics_20180824 ,QAgrmpy_9_12, by = "bblid")
df<-merge(df, sqFA, by = "bblid")
df<-merge(df, sqICVF, by = "bblid")
df<-merge(df, sqRTOP, by = "bblid")
df$Age<-((df$visitagemonths)/12)
df$sex<-as.factor(df$sex)

# Remove Low quality scans

#T1
#t1ex<-grep('86722',df$bblid)
#DWI
#dwiex<-grep('116354',df$bblid)

#df<-df[-c(dwiex,t1ex),]

### Gam on each edge for Age ###
fa_cols<-df[,grepl("_FA",names(df))]
icvf_cols<-df[,grepl("_ICVF",names(df))]
rtop_cols<-df[,grepl("_RTOP",names(df))]

# Sex taken out of example analyses

covariates=" ~ s(Age, k=4)+meanRELrms"   

#FA edge gams
covariates=" ~ s(Age, k=4)+meanRELrms"    
faedges <- mclapply(names(fa_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)
faedges_Age_pvals <- mclapply(faedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

#ICVF edge gams
covariates=" ~ s(Age, k=4)+meanRELrms"    
icvfedges <- mclapply(names(icvf_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)
icvfedges_Age_pvals <- mclapply(icvfedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

#RTOP edge gams
covariates=" ~ s(Age, k=4)+meanRELrms"    
rtopedges <- mclapply(names(rtop_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)
rtopedges_Age_pvals <- mclapply(rtopedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

## FDR correction
FDR_faedges_Age_pvals <- p.adjust(faedges_Age_pvals, method="fdr")
FDR_fa_sig<- subset(FDR_faedges_Age_pvals, FDR_faedges_Age_pvals <0.05)

FDR_icvfedges_Age_pvals <- p.adjust(icvfedges_Age_pvals, method="fdr")
FDR_ICVF_sig<- subset(FDR_icvfedges_Age_pvals, FDR_icvfedges_Age_pvals <0.05)

FDR_rtopedges_Age_pvals <- p.adjust(rtopedges_Age_pvals, method="fdr")
FDR_RTOP_sig<- subset(FDR_rtopedges_Age_pvals, FDR_rtopedges_Age_pvals <0.05)

# Print out number of significant edges for each metric
length(FDR_fa_sig)
length(FDR_ICVF_sig)
length(FDR_RTOP_sig)

#ztransform - this was for brainnet viewer weightings

#ztrans_fa_sig<-(-(qnorm(FDR_fa_sig)))
#ztrans_icvf_sig<-(-(qnorm(FDR_ICVF_sig)))
#ztrans_rtop_sig<-(-(qnorm(FDR_RTOP_sig)))

#ztrans_sc_sig<-(-(qnorm(as.numeric(sc_sig))))
#ztrans_fa_sig<-(-(qnorm(as.numeric(fa_sig))))
#ztrans_icvf_sig<-(-(qnorm(as.numeric(icvf_sig))))
#ztrans_rtop_sig<-(-(qnorm(as.numeric(rtop_sig))))

### For Brainnet viewer
### squareform(FDR_faedges_Age_pvals)->sqFA
### squareform(FDR_icvfedges_Age_pvals)->sqICVF
### squareform(FDR_rtopedges_Age_pvals)->sqRTOP

### sqFA[sqFA>0.05]<-0
### sqICVF[sqICVF>0.05]<-0
### sqRTOP[sqRTOP>0.05]<-0

### qnorm(sqFA)->qsqFA
### qnorm(sqICVF)->qsqICVF
### qnorm(sqRTOP)->qsqRTOP

### qsqFA[is.na(qsqFA)]<-0
### qsqICVF[is.na(qsqICVF)]<-0
### qsqRTOP[is.na(qsqRTOP)]<-0

### qsqFA[qsqFA=='-Inf']<-0
### qsqICVF[qsqICVF=='-Inf']<-0
### qsqRTOP[qsqRTOP=='-Inf']<-0
### qsqFA=qsqFA*-1
### qsqICVF=qsqICVF*-1
### qsqRTOP=qsqRTOP*-1

### write.table(qsqFA,'~/Desktop/grmpy/qsqFA.csv', sep=',', col.names=FALSE, row.names = FALSE)
### write.table(qsqICVF,'~/Desktop/grmpy/qsqICVF.csv', sep=',', col.names=FALSE, row.names = FALSE)
### write.table(qsqRTOP,'~/Desktop/grmpy/qsqRTOP.csv', sep=',', col.names=FALSE, row.names = FALSE)
