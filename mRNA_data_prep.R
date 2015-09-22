###
#get the PCBC samples geneExp normalized counts
###

flog.info('Reading the PCBC normalized mRNA Exp data from Synapse', name='synapse')

#mRNA_NormCounts <- synGet('syn2701943')
#TreeOfLife
# mRNA_NormCounts <- synGet('syn3546481')
# 
# #read in the file
# mRNA_NormCounts <- read.delim(mRNA_NormCounts@filePath, header=T, sep='\t',
#                               as.is=T, stringsAsFactors = F, check.names=F)
# rownames(mRNA_NormCounts) <- mRNA_NormCounts$samples
# mRNA_NormCounts$samples <- NULL
# #log this log10....mRNA_normcounts + 0.001
# #scale by row and columns
# #Save this data and reupload onto synapse
# 
# mRNA_NormCounts <- log10(mRNA_NormCounts+0.001)
# mRNA_NormCounts <- scale(mRNA_NormCounts)
# mRNA_NormCounts <- t(scale(t(mRNA_NormCounts)))
# save(mRNA_NormCounts,file="GTEx_normalized.Rdata")
# max(mRNA_NormCounts)
#data
data_GTEx <- synGet("syn4943851")
load(data_GTEx@filePath)
#mRNA_NormCounts<- mRNA_NormCounts[c(1:100),]

## remove version from ENSEMBL ID
#rownames(mRNA_NormCounts) <- gsub('\\..*', '',mRNA_NormCounts$tracking_id)


#mRNA_NormCounts$symbol <- NULL
#mRNA_NormCounts$tracking_id <- NULL
#mRNA_NormCounts$locus <- NULL

###
#get the metadata from synapse for PCBC geneExp samples
###
flog.info('Reading the PCBC mRNA metadata from Synapse', name='synapse')

mRNAMeta <- synGet("syn3555917")##Create a synapse Table with csv

mRNAMeta <- read.csv(mRNAMeta@filePath)
mRNA_metadata<- mRNAMeta[c(metadataIdCol, metadataColsToUse)]

rownames(mRNA_metadata) <- mRNA_metadata[, metadataIdCol]
#mRNA_metadata[, metadataIdCol] <- NULL
mRNA_metadata$Sample.Tissue <- tolower(mRNA_metadata$Sample.Tissue)
mRNA_metadata$Sample.Developmental.Sage <- tolower(mRNA_metadata$Sample.Developmental.Sage)


## Only keep samples in both
mrna_in_common <- intersect(rownames(mRNA_metadata), colnames(mRNA_NormCounts))
mRNA_metadata <- mRNA_metadata[mrna_in_common, ]
mRNA_NormCounts <- mRNA_NormCounts[, mrna_in_common]


  
mRNA_features<-  data.frame(explicit_rownames = rownames(mRNA_NormCounts))
rownames(mRNA_features) <- rownames(mRNA_NormCounts)

#sample_gene_list <- rownames(mRNA_NormCounts)

eset.mRNA <- ExpressionSet(assayData=as.matrix(mRNA_NormCounts),
                           phenoData=AnnotatedDataFrame(mRNA_metadata),
                           featureData=AnnotatedDataFrame(mRNA_features))
