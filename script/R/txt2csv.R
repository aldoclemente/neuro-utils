# parsing arguments ------------------------------------------------------------
args <- commandArgs(TRUE)
if(length(args)==0) stop("input directory needed.")
# ------------------------------------------------------------------------------

inputdir = paste0( strsplit( args[1], "/" )[[1]], "/", collapse = "")
for(file in list.files(inputdir, pattern = ".txt")){
  dat = read.table(paste0(inputdir, file))
  write.csv(dat, paste0(inputdir, strsplit(file, ".txt")[[1]], ".csv")) 
}
