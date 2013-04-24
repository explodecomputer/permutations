expDecay <- function(x, C, k)
{
	stopifnot(k > 0)
	y <- C * (1 - exp(-k*x))
}

x <- 1:100
y <- expDecay(x, 100, 0.001)
plot(y ~ x)

library(lattice)

expDecay2D <- function(x1, x2, C, k1, k2, a)
{
	stopifnot(k1 > 0)
	stopifnot(k2 > 0)
	y <- C * (1 - exp(-k1*x1) - exp(-k2*x2) + exp(-k1*x1-k2*x2))^a
	return(y)
}

x1 <- seq(1, 10000, by=100)
x2 <- seq(1, 5000000, by=100000)

dat <- expand.grid(x1=x1, x2=x2, y=NA)
dat$y <- expDecay2D(dat$x1, dat$x2, 14, 0.0005, 0.000001, 1.1)

wireframe(y ~ x1 * x2, data=dat, drape=T, default.scales=list(arrows=F))
max(dat$y)