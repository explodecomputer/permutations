library(plyr)


readPerms <- function(filebase, i1, i2, nid, nsnp, d, threshold, top) {

	dat8df <- data.frame()
	dat4df <- data.frame()
	for(i in i1:i2) {
		filename <- paste(filebase, i, ".txt.gz", sep="")
		if(file.exists(filename)) {
			cat(i, "\n")
			temp <- read.table(filename, header=T, skip=7)
			temp$SNP1name <- as.character(temp$SNP1name)
			temp$SNP2name <- as.character(temp$SNP2name)
			temp$Fval[temp$df1 < 1] <- NA
			temp$Fint[temp$df1 != 8] <- NA
			temp$Fval[temp$Fval == Inf] <- NA
			temp$Fint[temp$Fint == Inf] <- NA
			temp$Fval <- -log10(pf(temp$Fval, temp$df1, temp$df2, lower.tail=FALSE))
			temp$Fint <- -log10(pf(temp$Fint, 4, temp$df2, lower.tail=FALSE))
			a <- temp$Fval > 30
			if(sum(a, na.rm=T) > 0) cat(" Fval ")
			temp$Fval[a] <- NA

			a <- temp$Fint > 30
			if(sum(a, na.rm=T) > 0) cat(" Fint ")
			temp$Fint[a] <- NA

			# snp1 snp2 snp1name snp2name df1 f

			temp1 <- subset(temp, select=c(SNP1, SNP2, SNP1name, SNP2name, df1, Fval))[order(temp$Fval, decreasing=TRUE)[1:top], ]
			names(temp1)[6] <- "pval"
			temp1$Rank <- 1:top
			temp1$N <- nid
			temp1$chip <- nsnp
			temp1$D <- d
			temp1$count <- sum(temp$Fval > threshold[1], na.rm=T)
			temp1$Test <- "8df"
			temp1$perm <- i
			dat8df <- rbind(dat8df, temp1)

			temp2 <- subset(temp, select=c(SNP1, SNP2, SNP1name, SNP2name, df1, Fint))[order(temp$Fint, decreasing=TRUE)[1:top], ]
			names(temp2)[6] <- "pval"
			temp2$Rank <- 1:top
			temp2$N <- nid
			temp2$chip <- nsnp
			temp2$D <- d
			temp2$count <- sum(temp$Fint > threshold[2], na.rm=T)
			temp2$Test <- "4df"
			temp2$perm <- i
			dat4df <- rbind(dat4df, temp2)
		} else {
			cat(i, "missing!!\n")
		}
	}
	perm <- rbind(dat8df, dat4df)
	return(perm)
}

solveQuad <- function(A, B, C)
{
	top <- -B + sqrt(B^2 - 4*A*C) * c(-1, 1)
	return(top / (2*A))
}

effectiveNumber <- function(pval)
{
	a <- solveQuad(pval, -pval, -0.1)[2]
	return(a)
}


estimatedThresh <- function(total.snp, subset.snp, pval)
{
	eff.subset <- effectiveNumber(pval)
	cat(eff.subset, "\n")
	eff.snp <- eff.subset * (total.snp / subset.snp)
	cat(eff.snp, "\n")
	return(-log10(0.05 / (eff.snp * (eff.snp-1)/2)))
}

pthresh <- function(n, m, ntrait=1)
{
	s1 <- 0.0258
	s2 <- 1.72
	s3 <- 0.0379
	s4 <- 2.33
	a <- 13

	thresh <- a - a/(s1 * exp(log(n)/s2) + s3 * exp(log(m)/s4))
	# effective number of tests:
	et <- 0.05 / 10^-thresh
	thresh <- 0.05 / (et*ntrait)

	return(thresh)
}

# Bonferroni
bthresh <- function(m, ntrait=1)
{
	0.05/(ntrait*m*(m-1)/2)
}


rtdir <- "~/repo/permutations/results/"
sets <- c("res_0.99_", "res_0.95_", "res_0.95_unrel_", "res_1kg_")
N <- c(846, 846, 329, 379)
m <- c(303123, 469675, 469675, 553580)
M <- c(3240851, 5009044, 5009044, 5981319)
param <- data.frame(sets, N, m, M)

perm <- dlply(param, .(sets), .progress="text", function(x)
{
	x <- mutate(x)
	a <- readPerms(paste(rtdir, x$sets, sep=""), 1, 500, x$N, x$m, x$sets, c(7,7), 50)
	return(a)
})

ddply(param, .(sets), function(x)
{
	x <- mutate(x)
	a <- perm[[x$sets]]

	thresh <- ddply(subset(a, Rank == 1), c("chip", "N", "Test"), function(x) {
		a <- sort(x$pval, decreasing=T)[nrow(x) * 0.05]
		return(a)
	})
	names(thresh)[4] <- "thresh1"
	thresh$M <- x$M
	thresh$sets <- x$sets

	for(i in 1:nrow(thresh))
	{
		thresh$thresh2[i] <- estimatedThresh(thresh$M[i], thresh$chip[i], 10^-thresh$thresh1[i])
		thresh$bthresh[i] <- -log10(bthresh(thresh$M[i]))
	}

	return(thresh)
})

save(thresh, perm, param, file=paste(rtdir, "perm_results.RData", sep=""))





######################






