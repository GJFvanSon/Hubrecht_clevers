arguments <- commandArgs(trailingOnly = T)
foldertomap <- arguments[1]
STAR_index <- arguments[2]
genomeannot <- arguments[3]
outputfolder <- arguments[4]
ends <- arguments[5]

filestomap <- grep(".fastq.gz", list.files(foldertomap), value = T)
filestomap2 <- unlist(lapply(filestomap, function(x){return(strsplit(x, split = "_")[[1]][1])}))
filestomap2_unique <- unique(filestomap2)
print("Samples:")
print(filestomap2_unique)

if(ends == "single"){
  for (sample in filestomap2_unique){
    samplelist <- grep(paste0(sample, "_"), filestomap, value = T)
    outname <- paste0(outputfolder, sample, "_")
    if(length(samplelist) == 4){
      R1L1 <- file.path(foldertomap, grep("_L001_R1_",samplelist, value = T))
      R1L2 <- file.path(foldertomap, grep("_L002_R1_",samplelist, value = T))
      R1L3 <- file.path(foldertomap, grep("_L003_R1_",samplelist, value = T))
      R1L4 <- file.path(foldertomap, grep("_L004_R1_",samplelist, value = T))
      command <- paste0("STAR --runThreadN 8 --outFilterScoreMinOverLread 0.3 --outFilterMatchNminOverLread 0.3 ",
                        "--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --readFilesIn ", R1L1,",",
                        R1L2, ",", R1L3, ",", R1L4, " --outFileNamePrefix ", outname, " --genomeDir ", STAR_index)
    }
    if(length(samplelist) == 1){
      R1 <- file.path(foldertomap, grep(sample,samplelist, value = T))
      command <- paste0("STAR --runThreadN 8 --outFilterScoreMinOverLread 0.3 --outFilterMatchNminOverLread 0.3 ",
                        "--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --limitBAMsortRAM 60591780759 --outReadsUnmapped Fastx --readFilesIn ", R1,
                        " --outFileNamePrefix ", outname, " --genomeDir ", STAR_index, " --limitOutSJcollapsed 2000000")
    }
    if(length(samplelist) < 1){print("number of fastq files does not match the ends expectation")}
    if(length(samplelist) > 4){print("number of fastq files does not match the ends expectation")}
    print(command)
    system(command, intern = T)
  }
}

if(ends == "paired"){
  for (sample in filestomap2_unique){
    samplelist <- grep(paste0(sample, "_"), filestomap, value = T)
    outname <- paste0(outputfolder, sample, "_") 
    if(length(samplelist) == 8){
      R1L1 <- file.path(foldertomap, grep("_L001_R1_",samplelist, value = T))
      R1L2 <- file.path(foldertomap, grep("_L002_R1_",samplelist, value = T))
      R1L3 <- file.path(foldertomap, grep("_L003_R1_",samplelist, value = T))
      R1L4 <- file.path(foldertomap, grep("_L004_R1_",samplelist, value = T))
      R2L1 <- file.path(foldertomap, grep("_L001_R2_",samplelist, value = T))
      R2L2 <- file.path(foldertomap, grep("_L002_R2_",samplelist, value = T))
      R2L3 <- file.path(foldertomap, grep("_L003_R2_",samplelist, value = T))
      R2L4 <- file.path(foldertomap, grep("_L004_R2_",samplelist, value = T))
      command <- paste0("STAR --runThreadN 8 --outFilterScoreMinOverLread 0.3 --outFilterMatchNminOverLread 0.3 ",
                        "--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --readFilesIn ", R1L1,",",
                        R1L2, ",", R1L3, ",", R1L4, " ", R2L1, ",", R2L2, ",", R2L3, ",", R2L4,
                        " --outFileNamePrefix ", outname, " --genomeDir ", STAR_index)
    }  
    if(length(samplelist) == 4){
      R1L1 <- file.path(foldertomap, grep("_L001_R1_",samplelist, value = T))
      R1L2 <- file.path(foldertomap, grep("_L002_R1_",samplelist, value = T))
      R2L1 <- file.path(foldertomap, grep("_L001_R2_",samplelist, value = T))
      R2L2 <- file.path(foldertomap, grep("_L002_R2_",samplelist, value = T))
      command <- paste0("STAR --runThreadN 8 --outFilterScoreMinOverLread 0.3 --outFilterMatchNminOverLread 0.3 ",
                        "--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --readFilesIn ", R1L1,",",
                        R1L2, " ", R2L1, ",", R2L2,
                        " --outFileNamePrefix ", outname, " --genomeDir ", STAR_index)
    }                         
    if(length(samplelist) == 2){
      R1 <- file.path(foldertomap, grep("_R1_",samplelist, value = T))
      R2 <- file.path(foldertomap, grep("_R2_",samplelist, value = T))                             
      command <- paste0("STAR --runThreadN 8 --outFilterScoreMinOverLread 0.3 --outFilterMatchNminOverLread 0.3 ",
                        "--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx --readFilesIn ", R1, " ", R2,
                        " --outFileNamePrefix ", outname, " --genomeDir ", STAR_index, " --limitBAMsortRAM 50000000000")
    }
    if(length(samplelist) < 2){print("number of fastq files does not match the ends expectation")}
    if(length(samplelist) > 8){print("number of fastq files does not match the ends expectation")}
    print(command)
    system(command, intern = T)
  }
}

print("mapping done")
print("assigning readcounts using featureCounts")

outputfilelist <- list.files(outputfolder)
samplesam <- lapply(grep("sortedByCoor", outputfilelist, value = T), function(x){
 return(paste0(outputfolder, x))})
samplesams <- paste0(samplesam, collapse = " ")
outname <- paste0(outputfolder, "ReadCounts.txt")
command <- paste0("featureCounts -a ", genomeannot, " -p -T 4 -F GFF -g Name -t gene -o ", outname, " ", samplesams)
print(command)
system(command, intern = T)

print("assigning readcounts done")

readcounts <- read.table(outname, header = T)
readcounts <- readcounts[,-c(2:6)]
rownames(readcounts) <- readcounts$Geneid
readcounts <- readcounts[, -1]
colnames(readcounts) <- filestomap2_unique
write.table(readcounts, file = paste0(outputfolder, "readcounts_raw.csv"))



