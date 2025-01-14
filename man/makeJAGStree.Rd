% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makeJAGStree.R
\name{makeJAGStree}
\alias{makeJAGStree}
\title{makeJAGStree}
\usage{
makeJAGStree(data, prior = "lognormal", filename = "JAGSmodel.mod")
}
\arguments{
\item{data}{A dataframe object representing tree-structure}

\item{prior}{A string representing the choice of prior for the root
node population size; can be set to "lognormal" (default) or "uniform"}

\item{filename}{A string containing the file name for resulting output
'JAGS' model file; must end in .mod or .txt}
}
\value{
A .mod or .txt file that contains code ready to run a Bayesian
 hierarchical model in 'JAGS' based on the input tree-structured data
}
\description{
Generates a .mod or .txt file with 'JAGS' code for Bayesian
 hierarchical model on tree structured data
}
\examples{
\donttest{
  # optional use of the AutoWMM package to show tree structure
  Sys.setenv("RGL_USE_NULL" = TRUE)
  tree <- makeTree(data1)
  drawTree(tree)

  makeJAGStree(data1, filename=file.path(tempdir(), "data1_JAGSscript.mod"))
  makeJAGStree(data1, filename=file.path(tempdir(), "data1_JAGSscript.txt"))

  # second example
  makeJAGStree(data2, filename=file.path(tempdir(), "data2_JAGSscript.mod"))
  makeJAGStree(data2, filename=file.path(tempdir(), "data2_JAGSscript.mod", prior = "uniform"))

  # third example, showing optional execution with MCMC in R
  makeJAGStree(data3, filename=file.path(tempdir(), "multiScript.mod"))
  makeJAGStree(data3, filename=file.path(tempdir(), "multiScript.txt"))

  mcmc.data <- list( "DE" = c(50, NA),
  "ABC" = c(NA, 500, NA),
  "pZ1" = 4,     # dirichlet parameters for prior on u
  "pZ2" = 5,      # last parameter to sample U
  "pZ3" = 1,
  "pA1" = 10,      # beta parameters for prior on p
  "pA2" = 1,
  "mu" = log(1000),    # lognormal mean Z
  "tau" = 1/(0.1^2))    # lognormal precision (1/variance) of Z

  ## define parameters whose posteriors we are interested in
  mod.params <- c("Z",  "ABC", "DE", "pZ", "pA")

  ## modify initial values
  mod.inits.cont <- function(){ list("Z.cont" = runif(1, 700, 1500),
                                  "ABC" = c(round(runif(1, 100, 200)), NA, NA),
                                  "pA" = as.vector(rbeta(1,1,1)),
                                  "pZ" = as.vector(rdirichlet(1, c(1,1,1))))
                               }

  ## Generate list of initial values to match number of chains
  numchains <- 6
  mod.initial.cont <- list()
  i <- 1
  while(i <= numchains){
  mod.initial.cont[[i]] <- mod.inits.cont()
  i = i+1
  }

  ## now fit the model in JAGS
  mod.fit <- jags(data = mcmc.data,
                inits = mod.initial.cont,
                parameters.to.save = mod.params,
                n.chains = numchains,
                n.iter = 500, n.burnin = 200,
                model.file = "multiScript.mod")
  print(mod.fit)

  ## plots using mcmcplots library
  mod.fit.mcmc <- as.mcmc(mod.fit)
  denplot(mod.fit.mcmc, parms = c("Z", "ABC[1]", "ABC[3]"))
  denplot(mod.fit.mcmc, parms = c("pZ", "pA"))
  traplot(mod.fit.mcmc, parms = c("Z", "ABC[1]", "ABC[3]"))
  traplot(mod.fit.mcmc, parms = c("pZ", "pA"))
  }
}
