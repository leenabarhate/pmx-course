
#IV Bolus model

conc_iv_bolus <- function(t, dose, CL, V) {
  #input validation
  if (CL <= 0) {
    stop("Clearance (CL) must be greater than zero.")
  }
  if (V <= 0) {
    stop("Volume of distribution (V) must be greater than zero.")
  }
  if (dose < 0) {
    stop("Dose cannot be negative.")
  }
  #Elimination rate constant
  k <- CL / V
  #concentration at time t
  C <- (dose / V) * exp(-k * t)
  
  return(C)
}

stopifnot(abs(conc_iv_bolus(0, 500, 5, 50) - 10) < 0.005)

stopifnot(abs(conc_iv_bolus(6, 500, 5, 50) - 5.488) < 0.005)

stopifnot(abs(conc_iv_bolus(12, 500, 5, 50) - 3.012) < 0.005)

stopifnot(abs(conc_iv_bolus(24, 500, 5, 50) - 0.907) < 0.005)

#generate a fine time grid
time <- seq(0, 48, by = 0.1)

#calculate concentrations
conc <- conc_iv_bolus(time, 500, 5, 50)

#linear plot
plot(time, conc,
     type = "l",
     xlab = "Time (hours)",
     ylab = "Concentration (mg/L)",
     main = "IV Bolus: Linear Scale")

#Semi-log plot
plot(time, conc,
     type = "l",
     log = "y",
     xlab = "Time (hours)",
     ylab = "Concentration (mg/L",
     main = "IV Bolus: Semi-log scale")

model <- lm(log(conc) ~ time)
summary(model)

#extract slope
slope <- coef(model)[2]
print(slope)

#Oral Absorption + Flip - flop kinetics model

conc_oral_1cmt <- function(t, dose, Fbio, CL, V, ka) {
  
  #input validation
  if (CL <= 0) stop("CL must be greater than zero.")
  if (V <= 0) stop("V must be greater than zero.")
  if (dose < 0) stop("dose cannot be negative.")
  if (Fbio < 0 || Fbio > 1) stop("Fbio must be between 0 and 1.")
  if (ka <= 0) stop("ka must be greater than zero.")
  
  #calculating elimination rate constant
  
  k <- CL / V
  
  #check for equal absorption and elimination rates
  if (isTRUE(all.equal(ka, k))) {
    C <- (Fbio * dose * k / V) * t * exp(-k * t)
  } else {
    C <- (Fbio * dose * ka / (V * (ka -k))) *
      (exp(-k * t) - exp(-ka * t))
  }
  
  return(C)
  
}

# Tests for oral absorption model

# Equal absorption and elimination rates
stopifnot(
  abs(conc_oral_1cmt(0, 200, 0.8, 4, 40, 0.1)) < 0.001
)

stopifnot(
  abs(conc_oral_1cmt(10, 200, 0.8, 4, 40, 0.1) - 1.471518) < 0.001
)

# Different absorption and elimination rates
stopifnot(
  abs(conc_oral_1cmt(0, 200, 0.8, 4, 40, 1)) < 0.001
)

#calculated C at different time intervals

conc_oral_1cmt(
  t = c(0, 1 , 2, 3, 4, 6, 8),
  dose = 200,
  Fbio = 0.8,
  CL = 4,
  V = 40,
  ka = 1
)

#calculating Tmax
CL <- 4
V <- 40
ka <- 1
k <- CL / V

tmax <- log(ka / k) / (ka - k)
print(tmax)

#calculating Cmax

dose <- 200
Fbio <- 0.8

Cmax <- (Fbio * dose * ka / (V * (ka - k))) *
  (exp(-k * tmax) - exp(-ka * tmax))
print(Cmax)

#Calculating AUC 

AUC <- (Fbio * dose) / CL

print(AUC)

#comparing analytical and numerical tmax and cmax
time_grid <- seq(0, 24, by = 0.01)

conc_grid <- conc_oral_1cmt(
  t = time_grid,
  dose = 200,
  V = 40,
  Fbio = 0.8,
  CL = 4,
  ka = 1
)
i_max <- which.max(conc_grid)
tmax_numeric <- time_grid[i_max]
Cmax_numeric <- conc_grid[i_max]

print(tmax_numeric)
print(Cmax_numeric)

#varying ka values
# Comparing the effect of different absorption rates (ka)
# on Tmax, Cmax and AUC
ka_values <- c(0.25, 0.5, 1, 2, 4)
results <- data.frame(
  ka = ka_values,
  tmax = NA,
  Cmax = NA,
  AUC = NA
)

for (i in seq_along(ka_values)) {
  
  k <- 4/40
  
  results$tmax[i] <- log(ka_values[i]/k) /
    (ka_values[i] - k)
  
  results$Cmax[i] <- conc_oral_1cmt(
    t = results$tmax[i],
    dose = 200,
    Fbio = 0.8,
    V = 40,
    CL = 4,
    ka = ka_values[i]
    
  )
  
  results$AUC[i] <- (0.8 * 200)/4
}

print(results)

# Visualizing concentration-time profiles at different
# absorption rates to compare their effects on drug absorption

time <- seq(0, 24, by = 0.1)

plot(
  time,
  conc_oral_1cmt(time, 200, 0.8, 4, 40, ka_values[1]),
  type = "l",
  lwd = "2",
  xlab = "Time (hours)",
  ylab = "Concentration (mg/L)",
  ylim = c(0, 4),
  main = "Effect of absorption rate on concentration."
)

for (i in 2:length(ka_values)) {
  lines(
    time,
    conc_oral_1cmt(time, 200, 0.8, 4, 40, ka_values[i]),
    col = i,
    lty = i,
    lwd = 2
  )
}

legend(
  "topright",
  legend = paste("ka =", ka_values),
  col = 1:5,
  lty = 1:5,
  lwd = 2
)

#comparison for flip-flop kinetics

#original concentration-time profile
time <- seq(0, 24, by = 0.1)

C_original <- conc_oral_1cmt(
  t = time,
  Fbio = 0.8,
  dose = 200,
  ka = 1,
  V = 40,
  CL = 4
)

#swapped absorption rates and elimination rates
C_flipped <- conc_oral_1cmt(
  t = time,
  dose = 200,
  ka = 0.1,
  CL = 4,
  V = 4,
  Fbio = 0.8
)

# Compare the two profiles
max(abs(C_original - C_flipped))


