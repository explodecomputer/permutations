
readPerm <- function(filename)
{
	if(file.exists(filename))
	{
		dat <- read.table(filename, header=T, skip=7,
			colClasses=c("numeric", "character", "numeric", "numeric", "character", "numeric", "numeric", "numeric", "numeric", "numeric"))
		return(dat)
	} else {
		cat(filename, "missing")
	}
}


readPermOld <- function(filename)
{
	if(file.exists(filename))
	{
		dat <- read.table(filename, header=T,
			colClasses=c("numeric", "character", "numeric", "character", "numeric", "numeric", "numeric", "numeric"))
		return(dat)
	} else {
		cat(filename, "missing")
	}
}


cleanPerm <- function(dat)
{
	dat$Fval[dat$df1 < 1] <- NA
	dat$Fint[dat$df1 != 8] <- NA
	dat$Fval[dat$Fval == Inf] <- NA
	dat$Fint[dat$Fint == Inf] <- NA
	dat$Pval <- -log10(pf(dat$Fval, dat$df1, dat$df2, lower.tail=FALSE))
	dat$Pint <- -log10(pf(dat$Fint, 4, dat$df2, lower.tail=FALSE))

	a <- dat$Pval > 30
	if(sum(a, na.rm=T) > 0) cat(" Pval ")
	dat$Pval[a] <- NA

	a <- dat$Pint > 30
	if(sum(a, na.rm=T) > 0) cat(" Pint ")
	dat$Pint[a] <- NA

	dat <- subset(dat, ! (is.na(df1) | is.na(df2) | is.na(Fval) | is.na(Fint)))

	return(dat)
}


makeSummary <- function(dat, machine, top)
{
	n <- min(top, nrow(dat))
	dat8 <- dat[order(dat$Pval, decreasing=TRUE), ]
	dat8 <- dat8$Pval[1:n]
	dat4 <- dat[order(dat$Pint, decreasing=TRUE), ]
	dat4 <- dat4$Pint[1:n]

	out <- data.frame(machine = machine, test=rep(c("8df", "4df"), each=n), pval=c(dat8, dat4), rank=rep(1:n, 2))
	return(out)
}


writeSummary <- function(filename, machine, top, outfile, old="")
{
	if(old == "old")
	{
		dat <- readPermOld(filename)
	} else {
		dat <- readPerm(filename)
	}
	datsum <- makeSummary(cleanPerm(dat), machine, top)
	save(datsum, file=outfile)
}


#=======================================================#
#=======================================================#


arguments <- commandArgs(T)

rootin <- arguments[1]
first <- as.numeric(arguments[2])
last <- as.numeric(arguments[3])
top <- as.numeric(arguments[4])
rootout <- arguments[5]
machine <- arguments[6]
old <- arguments[7]


#=======================================================#
#=======================================================#


for(i in first:last)
{
	filein <- gsub("@", i, rootin)
	fileout <- gsub("@", i, rootout)
	if(!file.exists(filein))
	{
		cat(filein, "missing\n")
		next
	} else {
		cat(i, "\n")
	}

	writeSummary(filein, machine, top, fileout, old)
}

