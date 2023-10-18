## created on Oct 13, 2021
## modified on Oct 13, 2021

## The cleanAS function is from Ulrich
library(magrittr)
library(dplyr)

cleanAS <- function(x,                                           # Quality column of one sample
                    complexCol,                                  # Column 'COMPLEX' of vast-tools output
                    covThresCE    = c("SOK","OK","LOW","VLOW"),  # Allowable coverage score (score 3) for CE
                    covThresOther = c("SOK","OK","LOW","VLOW"),  # Allowable coverage score (score 3) for ME, Alt3, Alt5
                    covThresIR    = 10,                          # Minimum coverage (score 3) for IR
                    balThresCE    = c("OK","B1","B2","Bl","Bn"), # Allowable balance score (score 4) for CE
                    balThresIR    = 0.05                         # Maximum balance p-value (score 4, bigger is better) for IR
) {
  ### Filter PSI output of vast-tools pipeline using the quality column
  ### Value: logical vector indicating which events passed the criteria
  
  if(0){  ## for debugging
    x <- vast_out$siNT_S1.Q                                        
    complexCol <- vast_out$COMPLEX                                 
    covThresCE    = c("SOK","OK","LOW","VLOW") 
    covThresOther = c("SOK","OK","LOW","VLOW")  
    covThresIR    = 10                          
    balThresCE    = c("OK","B1","B2","Bl","Bn")
    balThresIR    = 0.05
  }
  
  is.ce <- complexCol %in% c("S","C1","C2","C3","ANN")
  is.ir <- grepl("IR", complexCol)
  is.o  <- complexCol %in% c("Alt5", "Alt3", "MIC")
  
  score1 <- sub("([^,]+),.+", "\\1", x)
  score3 <- sub("[^,]+,[^,]+,([^,]+),.+", "\\1", x)
  score4 <- sub("[^,]+,[^,]+,[^,]+,([^,]+),.+", "\\1", x)
  score5 <- sub("[^,]*,[^,]*,[^,]*,[^,]*,([^,@]*)[@,].*", "\\1", x)
  
  oldVast <- ifelse(any(grepl("=", score3)), FALSE, TRUE)
  cat("Vast-tools version", ifelse(oldVast, "<", ">="), "2.2.2 detected", "\n")
  
  if (oldVast) {  # The content of score4 has changed in vast-tools 2.2.2
    ok.ce <- is.ce & score3 %in% covThresCE & score4 %in% balThresCE
    ok.o  <- is.o  & score3 %in% covThresOther
  } else {
    ok.ce <- is.ce & score1 %in% covThresCE & score4 %in% balThresCE
    ok.o  <- is.o  & score1 %in% covThresOther
  }
  
  suppressWarnings(
    nreads <- as.integer(sub("([^=]*)=.+", "\\1", score4)) +
      as.integer(sub("[^=]*=([^=]*)=.*", "\\1", score4)) +
      as.integer(sub("[^=]*=[^=]*=(.*)", "\\1", score4))
  )
  suppressWarnings(
    ok.ir <- is.ir & nreads >= covThresIR & as.numeric(score5) > balThresIR
  )
  
  ok.ce | ok.ir | ok.o
}


## MAIN
args = commandArgs(trailingOnly=TRUE)
wd <- args[1] ##"NC_score.bw,PC_score.bw" #args[1] ## file names with .bw
operation <- args[2]

#wd <- "C:\\RSYNC\\Nabeel\\VAST-TOOLS"
setwd(wd)

if(operation == "clean"){
  
  inclusion <- list.files(pattern="^INCLUSION_LEVELS_FULL-")[1]
  
  print(paste("Cleaning", inclusion))
  
  vast_out <- read.delim(inclusion, header=T, sep="\t")
  head(vast_out)
  
  qual_cols <- colnames(vast_out)[grep("\\.Q", colnames(vast_out))]
  complexCol <- vast_out$COMPLEX
  
  clean <- apply(vast_out[,qual_cols], 2, function(x)cleanAS(x, complexCol))
  head(clean)
  
  #all_clean <- apply(clean, 1, all)
  #head(all_clean)
  #cleaned_vast_out <- vast_out[all_clean,]
  
  sum_clean <- apply(clean, 1, function(x) sum(x) > ncol(clean)/2) ## more than half of samples are OK
  
  head(sum_clean)
  
  cleaned_vast_out <- vast_out[sum_clean,]
  
  write.table(cleaned_vast_out, paste("CLEANED", inclusion, sep="_"), sep="\t", quote=F, col.names=T, row.names=F)
  
  print("Before cleaning:")
  print(dim(vast_out))
  print("After cleaning:")
  print(dim(cleaned_vast_out))
} else if(operation %in% c("GOyes", "GOno")){

  cleaned <- list.files(pattern="^CLEANED_INCLUSION_LEVELS_FULL-")[1]
  cleaned_out <- read.delim(cleaned, header=T, sep="\t")

  if(operation == "GOyes"){
  #source("C:/RSYNC/worksapce2015/RNA_seq/R_script/Function_analysis_for_RNAseq_lib.R")
    source("/home/greenblattlab/shuyepu/R_script/Function_analysis_for_RNAseq_lib.R")
  }
  
  diff <- list.files(pattern="^DIFF_.+\\.tab")[1]
  
  print(paste("GO enrichment analysis", diff))
  
  diff_table <- read.delim(diff, header=T, sep="\t")
  head(diff_table)
  
  ASs <- c("HsaEX", "HsaINT", "HsaALTD", "HsaALTA")
  names(ASs) <- c("Exon_inclusion", "Intron_retention", "Alternative5SS", "Alternative3SS")
  
  group_table <- NULL
  for(ASn in names(ASs)){
    #ASn <- "Intron_retention"
    AS <- ASs[ASn]
    events <- grepl(AS, diff_table$EVENT)
    univ <- unique(diff_table$GENE[events])
    sig_up <- unique(diff_table$GENE[events & diff_table$MV.dPsi._at_0.95 >= 0.1 & diff_table$E.dPsi. > 0])
    sig_down <- unique(diff_table$GENE[events & diff_table$MV.dPsi._at_0.95 >= 0.1 & diff_table$E.dPsi. < 0])
    sig <- union(sig_up, sig_down)
    if(operation == "GOyes"){
      run_enrichGO_simpleList(sig_up, "BP", paste(ASn, "up", sep="_"), adjp_cutoff=0.05, universe=univ)
      run_enrichGO_simpleList(sig_down, "BP", paste(ASn, "down", sep="_"), adjp_cutoff=0.05, universe=univ)
      run_enrichGO_simpleList(sig, "BP", paste(ASn, "regulated", sep="_"), adjp_cutoff=0.05, universe=univ)
    }
    up_table <- diff_table[events & diff_table$MV.dPsi._at_0.95 >= 0.1 & diff_table$E.dPsi. > 0,]
    up_table <- merge(x=cleaned_out, y=up_table, by=c("GENE", "EVENT"), all.y=T) %>%
    mutate(GROUP=rep(ASn, nrow(up_table)), CHANGE=rep("up", nrow(up_table)))

    down_table <- diff_table[events & diff_table$MV.dPsi._at_0.95 >= 0.1 & diff_table$E.dPsi. < 0,]
    down_table <- merge(x=cleaned_out, y=down_table, by=c("GENE", "EVENT"), all.y=T) %>%
    mutate(GROUP=rep(ASn, nrow(down_table)), CHANGE=rep("down", nrow(down_table)))

    unregulated_table <- diff_table[events & diff_table$MV.dPsi._at_0.95 < 0.1,]
    unregulated_table <- merge(x=cleaned_out, y=unregulated_table, by=c("GENE", "EVENT"), all.y=T) %>%
    mutate(GROUP=rep(ASn, nrow(unregulated_table)), CHANGE=rep("unregulated", nrow(unregulated_table)))


    sig_table <- rbind(up_table, down_table, unregulated_table)
    group_table <- rbind(group_table, sig_table)

    write.table(up_table, paste(ASn, "up_events.tab", sep="_"), sep="\t", row.names=F, col.names=T, quote=F)
    write.table(down_table, paste(ASn, "down_events.tab", sep="_"), sep="\t", row.names=F, col.names=T, quote=F)
    write.table(sig_table, paste(ASn, "regulated_events.tab", sep="_"), sep="\t", row.names=F, col.names=T, quote=F)
  }
  write.table(group_table, "cleaned_events_grouped_based_on_diff.tab", sep="\t", row.names=F, col.names=T, quote=F)
  complex_group <- unique(group_table[, c("COMPLEX", "GROUP")])
  regulated_tally <- table(group_table[, c("GROUP", "CHANGE")])
  write.table(regulated_tally, "cleaned_events_group_tally.tab", sep="\t", row.names=T, col.names=NA, quote=F)

  complex_tally <- table(group_table[, c("COMPLEX", "CHANGE")])
  complex_tally <- complex_tally[complex_group$COMPLEX,]
  complex_tally <- cbind(GROUP=complex_group$GROUP, complex_tally)
  write.table(complex_tally, "cleaned_events_subtype_tally.tab", sep="\t", row.names=T, col.names=NA, quote=F)

}else{
  print("sub-command is not provided")
}

## END
