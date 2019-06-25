# Load libraries
library(mgcv)
library(visreg)
library(ggplot2)
library(parallel)
library(multilevel)
library(pracma)



# Load general data
demographics_20180824 <- read.csv("~/demographics_20180824.csv", comment.char="#")
QAgrmpy_9_12 <- read.csv("~/QAgrmpy_9_12.csv")
ids <- read.delim("~/torun.txt", header=FALSE)
df<-merge(QAgrmpy_9_12,demographics_20180824,by='bblid')
# For gams later
covariates=" ~ s(visitagemonths, k=4)+meanRELrms+sex"   

# For attaching Subj IDs later
colnames(ids)<-c("bblid")

###MultiShellFA###
# Read in
sq_msFA<- read.csv("~/squareforms_6_21/msFA_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_msFA))) {
  names(sq_msFA)[i]<-paste((colnames(sq_msFA)[i]),"_msFA", sep = "")
}

ids$bblid->sq_msFA$bblid

df<-merge(df, sq_msFA, by = "bblid")

###SingleShellFA###
# Read in
sq_ssFA<- read.csv("~/squareforms_6_21/ssFA_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_ssFA))) {
  names(sq_ssFA)[i]<-paste((colnames(sq_ssFA)[i]),"_ssFA", sep = "")
}

ids$bblid->sq_ssFA$bblid

df<-merge(df, sq_ssFA, by = "bblid")

###MultiShellAD###
# Read in
sq_msAD<- read.csv("~/squareforms_6_21/msAD_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_msAD))) {
  names(sq_msAD)[i]<-paste((colnames(sq_msAD)[i]),"_msAD", sep = "")
}

ids$bblid->sq_msAD$bblid

df<-merge(df, sq_msAD, by = "bblid")

###SingleShellAD###
# Read in
sq_ssAD<- read.csv("~/squareforms_6_21/ssAD_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_ssAD))) {
  names(sq_ssAD)[i]<-paste((colnames(sq_ssAD)[i]),"_ssAD", sep = "")
}

ids$bblid->sq_ssAD$bblid

df<-merge(df, sq_ssAD, by = "bblid")

###MultiShellMD###
# Read in
sq_msMD_inv<- read.csv("~/squareforms_6_21/ms_MD_inv_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_msMD_inv))) {
  names(sq_msMD_inv)[i]<-paste((colnames(sq_msMD_inv)[i]),"_msMD_inv", sep = "")
}

ids$bblid->sq_msMD_inv$bblid

df<-merge(df, sq_msMD_inv, by = "bblid")

###SingleShellMD###
# Read in
sq_ssMD_inv<- read.csv("~/squareforms_6_21/ss_MD_inv_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_ssMD_inv))) {
  names(sq_ssMD_inv)[i]<-paste((colnames(sq_ssMD_inv)[i]),"_ssMD_inv", sep = "")
}

ids$bblid->sq_ssMD_inv$bblid

df<-merge(df, sq_ssMD_inv, by = "bblid")


###MultiShellRD###
# Read in
sq_msRD_inv<- read.csv("~/squareforms_6_21/ms_RD_inv_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_msRD_inv))) {
  names(sq_msRD_inv)[i]<-paste((colnames(sq_msRD_inv)[i]),"_msRD_inv", sep = "")
}

ids$bblid->sq_msRD_inv$bblid

df<-merge(df, sq_msRD_inv, by = "bblid")


###SingleShellRD###
# Read in
sq_ssRD_inv<- read.csv("~/squareforms_6_21/ss_RD_inv_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_ssRD_inv))) {
  names(sq_ssRD_inv)[i]<-paste((colnames(sq_ssRD_inv)[i]),"_ssRD_inv", sep = "")
}

ids$bblid->sq_ssRD_inv$bblid

df<-merge(df, sq_ssRD_inv, by = "bblid")

###ICVF###
# Read in
sq_ICVF<- read.csv("~/squareforms_6_21/ICVF_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_ICVF))) {
  names(sq_ICVF)[i]<-paste((colnames(sq_ICVF)[i]),"_ICVF", sep = "")
}

ids$bblid->sq_ICVF$bblid

df<-merge(df, sq_ICVF, by = "bblid")

###ODI###
# Read in
sq_1minODI<- read.csv("~/squareforms_6_21/1minODI_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_1minODI))) {
  names(sq_1minODI)[i]<-paste((colnames(sq_1minODI)[i]),"_1minODI", sep = "")
}

ids$bblid->sq_1minODI$bblid

df<-merge(df, sq_1minODI, by = "bblid")


###ISOVF###
# Read in
sq_1minISOVF<- read.csv("~/squareforms_6_21/1minISOVF_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_1minISOVF))) {
  names(sq_1minISOVF)[i]<-paste((colnames(sq_1minISOVF)[i]),"_1minISOVF", sep = "")
}

ids$bblid->sq_1minISOVF$bblid

df<-merge(df, sq_1minISOVF, by = "bblid")


###RTOP###
# Read in
sq_rtop<- read.csv("~/squareforms_6_21/rtop_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_rtop))) {
  names(sq_rtop)[i]<-paste((colnames(sq_rtop)[i]),"_rtop", sep = "")
}

ids$bblid->sq_rtop$bblid

df<-merge(df, sq_rtop, by = "bblid")


###RTAP###
# Read in
sq_rtap<- read.csv("~/squareforms_6_21/rtap_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_rtap))) {
  names(sq_rtap)[i]<-paste((colnames(sq_rtap)[i]),"_rtap", sep = "")
}

ids$bblid->sq_rtap$bblid

df<-merge(df, sq_rtap, by = "bblid")


###RTPP###
# Read in
sq_rtpp<- read.csv("~/squareforms_6_21/rtpp_all.csv", header = FALSE)

# Make colnames specific to scalar
for (i in 1:length(colnames(sq_rtpp))) {
  names(sq_rtpp)[i]<-paste((colnames(sq_rtpp)[i]),"_rtpp", sep = "")
}

ids$bblid->sq_rtpp$bblid

df<-merge(df, sq_rtpp, by = "bblid")


# Remove Low quality scans

#T1
t1ex<-grep('86722',df$bblid)
#DWI
dwiex<-grep('116354',df$bblid)

df<-df[-c(dwiex,t1ex),]


#MSFA#
# Select columns for this scalar
msFA_cols<-df[,grepl("_msFA",names(df))]

# Isolate each edge
msFAedges <- mclapply(names(msFA_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
msFAedges_Age_pvals <- mclapply(msFAedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_msFAedges_Age_pvals <- p.adjust(msFAedges_Age_pvals, method="fdr")
FDR_msFA_sig<- subset(FDR_msFAedges_Age_pvals, FDR_msFAedges_Age_pvals <0.05)

# How many edges?
paste("msFA:", length(FDR_msFA_sig))

#SSFA#
# Select columns for this scalar
ssFA_cols<-df[,grepl("_ssFA",names(df))]

# Isolate each edge
ssFAedges <- mclapply(names(ssFA_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
ssFAedges_Age_pvals <- mclapply(ssFAedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_ssFAedges_Age_pvals <- p.adjust(ssFAedges_Age_pvals, method="fdr")
FDR_ssFA_sig<- subset(FDR_ssFAedges_Age_pvals, FDR_ssFAedges_Age_pvals <0.05)

# How many edges?
paste("ssFA:", length(FDR_ssFA_sig))

#msAD#
# Select columns for this scalar
msAD_cols<-df[,grepl("_msAD",names(df))]

# Isolate each edge
msADedges <- mclapply(names(msAD_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
msADedges_Age_pvals <- mclapply(msADedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_msADedges_Age_pvals <- p.adjust(msADedges_Age_pvals, method="fdr")
FDR_msAD_sig<- subset(FDR_msADedges_Age_pvals, FDR_msADedges_Age_pvals <0.05)

# How many edges?
paste("msAD:", length(FDR_msAD_sig))

#ssAD#
# Select columns for this scalar
ssAD_cols<-df[,grepl("_ssAD",names(df))]

# Isolate each edge
ssADedges <- mclapply(names(ssAD_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
ssADedges_Age_pvals <- mclapply(ssADedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_ssADedges_Age_pvals <- p.adjust(ssADedges_Age_pvals, method="fdr")
FDR_ssAD_sig<- subset(FDR_ssADedges_Age_pvals, FDR_ssADedges_Age_pvals <0.05)

# How many edges?
paste("ssAD:", length(FDR_ssAD_sig))

#msMD_inv#
# Select columns for this scalar
msMD_inv_cols<-df[,grepl("_msMD_inv",names(df))]

# Isolate each edge
msMD_invedges <- mclapply(names(msMD_inv_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
msMD_invedges_Age_pvals <- mclapply(msMD_invedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_msMD_invedges_Age_pvals <- p.adjust(msMD_invedges_Age_pvals, method="fdr")
FDR_msMD_inv_sig<- subset(FDR_msMD_invedges_Age_pvals, FDR_msMD_invedges_Age_pvals <0.05)

# How many edges?
paste("msMD_inv:", length(FDR_msMD_inv_sig))

#ssMD_inv#
# Select columns for this scalar
ssMD_inv_cols<-df[,grepl("_ssMD_inv",names(df))]

# Isolate each edge
ssMD_invedges <- mclapply(names(ssMD_inv_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
ssMD_invedges_Age_pvals <- mclapply(ssMD_invedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_ssMD_invedges_Age_pvals <- p.adjust(ssMD_invedges_Age_pvals, method="fdr")
FDR_ssMD_inv_sig<- subset(FDR_ssMD_invedges_Age_pvals, FDR_ssMD_invedges_Age_pvals <0.05)

# How many edges?
paste("ssMD_inv:", length(FDR_ssMD_inv_sig))

#msRD_inv#
# Select columns for this scalar
msRD_inv_cols<-df[,grepl("_msRD_inv",names(df))]

# Isolate each edge
msRD_invedges <- mclapply(names(msRD_inv_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
msRD_invedges_Age_pvals <- mclapply(msRD_invedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_msRD_invedges_Age_pvals <- p.adjust(msRD_invedges_Age_pvals, method="fdr")
FDR_msRD_inv_sig<- subset(FDR_msRD_invedges_Age_pvals, FDR_msRD_invedges_Age_pvals <0.05)

# How many edges?
paste("msRD_inv:", length(FDR_msRD_inv_sig))

#ssRD_inv#
# Select columns for this scalar
ssRD_inv_cols<-df[,grepl("_ssRD_inv",names(df))]

# Isolate each edge
ssRD_invedges <- mclapply(names(ssRD_inv_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
ssRD_invedges_Age_pvals <- mclapply(ssRD_invedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_ssRD_invedges_Age_pvals <- p.adjust(ssRD_invedges_Age_pvals, method="fdr")
FDR_ssRD_inv_sig<- subset(FDR_ssRD_invedges_Age_pvals, FDR_ssRD_invedges_Age_pvals <0.05)

# How many edges?
paste("ssRD_inv:", length(FDR_ssRD_inv_sig))

#ICVF#
# Select columns for this scalar
ICVF_cols<-df[,grepl("_ICVF",names(df))]

# Isolate each edge
ICVFedges <- mclapply(names(ICVF_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
ICVFedges_Age_pvals <- mclapply(ICVFedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_ICVFedges_Age_pvals <- p.adjust(ICVFedges_Age_pvals, method="fdr")
FDR_ICVF_sig<- subset(FDR_ICVFedges_Age_pvals, FDR_ICVFedges_Age_pvals <0.05)

# How many edges?
paste("ICVF:", length(FDR_ICVF_sig))

#oneminODI#
# Select columns for this scalar
oneminODI_cols<-df[,grepl("_1minODI",names(df))]

# Isolate each edge
oneminODIedges <- mclapply(names(oneminODI_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
oneminODIedges_Age_pvals <- mclapply(oneminODIedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_oneminODIedges_Age_pvals <- p.adjust(oneminODIedges_Age_pvals, method="fdr")
FDR_oneminODI_sig<- subset(FDR_oneminODIedges_Age_pvals, FDR_oneminODIedges_Age_pvals <0.05)

# How many edges?
paste("oneminODI:", length(FDR_oneminODI_sig))

#oneminISOVF#
# Select columns for this scalar
oneminISOVF_cols<-df[,grepl("_1minISOVF",names(df))]

# Isolate each edge
oneminISOVFedges <- mclapply(names(oneminISOVF_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
oneminISOVFedges_Age_pvals <- mclapply(oneminISOVFedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_oneminISOVFedges_Age_pvals <- p.adjust(oneminISOVFedges_Age_pvals, method="fdr")
FDR_oneminISOVF_sig<- subset(FDR_oneminISOVFedges_Age_pvals, FDR_oneminISOVFedges_Age_pvals <0.05)

# How many edges?
paste("oneminISOVF:", length(FDR_oneminISOVF_sig))

#rtop#
# Select columns for this scalar
rtop_cols<-df[,grepl("_rtop",names(df))]

# Isolate each edge
rtopedges <- mclapply(names(rtop_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
rtopedges_Age_pvals <- mclapply(rtopedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_rtopedges_Age_pvals <- p.adjust(rtopedges_Age_pvals, method="fdr")
FDR_rtop_sig<- subset(FDR_rtopedges_Age_pvals, FDR_rtopedges_Age_pvals <0.05)

# How many edges?
paste("rtop:", length(FDR_rtop_sig))

#rtap#
# Select columns for this scalar
rtap_cols<-df[,grepl("_rtap",names(df))]

# Isolate each edge
rtapedges <- mclapply(names(rtap_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
rtapedges_Age_pvals <- mclapply(rtapedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_rtapedges_Age_pvals <- p.adjust(rtapedges_Age_pvals, method="fdr")
FDR_rtap_sig<- subset(FDR_rtapedges_Age_pvals, FDR_rtapedges_Age_pvals <0.05)

# How many edges?
paste("rtap:", length(FDR_rtap_sig))

#rtpp#
# Select columns for this scalar
rtpp_cols<-df[,grepl("_rtpp",names(df))]

# Isolate each edge
rtppedges <- mclapply(names(rtpp_cols), function(x) {as.formula(paste(x, covariates, sep=""))},mc.cores=2)

# Run a gam on each edge, yield p values
rtppedges_Age_pvals <- mclapply(rtppedges, function(x) { summary(gam(formula = x, fx=TRUE,data=df, REML=T))$s.table[1,4]},mc.cores = 4)

# FDR correct p-values
FDR_rtppedges_Age_pvals <- p.adjust(rtppedges_Age_pvals, method="fdr")
FDR_rtpp_sig<- subset(FDR_rtppedges_Age_pvals, FDR_rtppedges_Age_pvals <0.05)

# How many edges?
paste("rtpp:", length(FDR_rtpp_sig))

# Summarize sig. edges
paste("This is the final edge count,", " chief")
paste("msFA:", length(FDR_msFA_sig))
paste("ssFA:", length(FDR_ssFA_sig))
paste("msAD:", length(FDR_msAD_sig))
paste("ssAD:", length(FDR_ssAD_sig))
paste("msMD_inv:", length(FDR_msMD_inv_sig))
paste("ssMD_inv:", length(FDR_ssMD_inv_sig))
paste("msRD_inv:", length(FDR_msRD_inv_sig))
paste("ssRD_inv:", length(FDR_ssRD_inv_sig))
paste("ICVF:", length(FDR_ICVF_sig))
paste("oneminODI:", length(FDR_oneminODI_sig))
paste("oneminISOVF:", length(FDR_oneminISOVF_sig))
paste("rtop:", length(FDR_rtop_sig))
paste("rtap:", length(FDR_rtap_sig))
paste("rtpp:", length(FDR_rtpp_sig))
```




