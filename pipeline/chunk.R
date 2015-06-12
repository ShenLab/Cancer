args <- commandArgs(trailingOnly=T)
num_partitions <- as.numeric(args[1])
out_file <- args[2]

seq_len <- c(249250621, 243199373, 198022430,
             191154276, 180915260, 171115067, 
             159138663, 146364022, 141213431, 
             135534747, 135006516, 133851895, 
             115169878, 107349540, 102531392, 
              90354753,  81195210,  78077248, 
              59128983,  63025520,  48129895, 
              51304566, 155270560,  59373566, 
                 16569)
names(seq_len) <- c(seq(1:22), "X", "Y", "MT")
partitions <- rep(0, length(seq_len))

sum_partitions <- rep(0, num_partitions)

for (i in 1:length(seq_len)){
  partitions[i] <- which.min(sum_partitions)
  sum_partitions[partitions[i]] <- 
    sum_partitions[partitions[i]] + seq_len[i]              
}
partitions_codes <- rep(0, num_partitions)
for (i in 1:num_partitions){
  partitions_codes[i] <- paste(names(seq_len)[partitions==i], collapse=" -L ")
}
write.table(partitions_codes, out_file, row.names=F, col.names=F, quote=F)


