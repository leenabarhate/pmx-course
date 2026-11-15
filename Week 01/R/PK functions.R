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