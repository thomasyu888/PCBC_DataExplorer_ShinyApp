library(synapseClient)
library(plyr)
library(dplyr)
library(stringr)
synapseLogin()

miRNA_to_genesFile <- synGet('syn2246991', version=1)
miRNA_to_genes <- read.delim(miRNA_to_genesFile@filePath, header=T, sep="\t",
                             stringsAsFactors=FALSE, check.names=F) %>% 
  rename(mirName=Pathway) %>% 
  select(GeneID,mirName) %>%
  mutate(mirName=tolower(gsub('\\*', '', mirName))) %>%
  mutate(mirName=gsub('-.p', '', mirName))


miRNA_normCounts_newFile <- synGet('syn3355993')
# miRNA_normCounts_new <- fread(getFileLocation(miRNA_normCounts_newFile), data.table=FALSE)
miRNA_normCounts_new <- read.delim(miRNA_normCounts_newFile@filePath, header=T, sep='\t', 
                                   as.is=T, stringsAsFactors = F, check.names=F)
rownames(miRNA_normCounts_new) <- tolower(gsub('-.p', '', miRNA_normCounts_new$id))
miRNA_normCounts_new$id <- NULL

miRNA_normCountsFile <- synGet('syn2701942')
miRNA_normCounts <- read.delim(miRNA_normCountsFile@filePath, header=T, sep='\t', 
                               as.is=T, stringsAsFactors = F, check.names=F)

## Group by the mature and take distinct
## Some have different precursors, but the values are all identical!
miRNA_normCounts_unique <- miRNA_normCounts %>%
  mutate(mirName=str_replace(str_extract(mir, ",.*"), ",", "")) %>% 
  group_by(mirName) %>% 
  distinct() %>% 
  as.data.frame()

rownames(miRNA_normCounts_unique) <- miRNA_normCounts_unique$mirName
miRNA_normCounts_unique$mir <- NULL
# miRNA_normCounts_unique$mirMature <- NULL

anti_join(miRNA_normCounts_unique, miRNA_to_genes, by="mirName")


miRNA_to_genes <- merge(temp_miRNAs_names, 
                        miRNA_to_genes, 
                        by.x='miRNAPrecursor', by.y='mirName', 
                        all.x=T)

#remove dups
miRNA_to_genes <- miRNA_to_genes[!duplicated(miRNA_to_genes),]

## Convert mir name to precursor
miRNA_precursors <- data.frame(miRNAPrecursor=rownames(miRNA_normCounts_new)) %>%
  mutate(miRNAPrecursor=str_replace(miRNAPrecursor, "-[35]p", ""))

miRNA_to_genes %>% filter(mirName %in% miRNA_precursors$miRNAPrecursor) %>% nrow()

miRNA_to_genes %>% filter(mirName %in% temp_miRNAs_names$miRNAPrecursor) %>% nrow()
