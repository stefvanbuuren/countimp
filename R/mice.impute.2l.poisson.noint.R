mice.impute.2l.poisson.noint <-
function(y,ry,x,type,intercept=FALSE)
{
Y <- y[ry]
X <- x[ry,]
nam <- paste("V",1:ncol(X),sep="")
colnames(X) <- nam
if(sum(type==-2)>1){stop("only one class allowed!")}
grp <- which(type==-2)
fixedeff <- paste("+",paste(nam[-grp],collapse="+"),sep="")
if (any(type==2)){
  
  ran <- which(type==2)  
  randeff <- paste("+",paste(nam[ran],collapse="+"),sep="")
  if(!intercept)
  {
    randeff <- paste("~0",randeff,"|",paste(nam[grp]),sep="")
  } else {
    randeff <- paste("~1",randeff,"|",paste(nam[grp]),sep="")
  }
} else{
  if(!intercept)
  {
    randeff <- paste("~0","|",paste(nam[grp]),sep="")
  } else {
    randeff <- paste("~1","|",paste(nam[grp]),sep="")
  }  
}
randeff <- as.formula(randeff)	
fixedeff <- as.formula(paste("Y","~",fixedeff,sep=""))
dat <- data.frame(Y,X)
fit <- glmmPQL(fixed=fixedeff, data=dat, random=randeff,
family="poisson", control=list(opt="optim"), na.action=na.omit)
fit.sum <- summary(fit)
beta <- fit$coefficients$fixed
rv <- t(chol(vcov(fit)))
b.star <- beta + rv %*% rnorm(ncol(rv))
fitmis <- fit
fitmis$coefficients$fixed <- b.star
newdatamis <- data.frame(X=x[!ry,])
colnames(newdatamis) <- nam	
yhatmis <- predict(fitmis,
newdata=newdatamis, type="response", na.action=na.pass)
yhatmis <-rpois(length(yhatmis),yhatmis)
return(yhatmis)
}
