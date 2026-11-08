library(dplyr)
library(ggplot2)

data("Theoph")
head(Theoph)
str(Theoph)

#(a) spaghetti plot - linear scale
p1 <- ggplot(Theoph, aes(x = Time, y = conc, group = Subject, color = Subject)) +
  geom_line(linewidth = 0.8) +
  labs(
    title = "Theophylline Concentration-Time Profiles",
    x = "Time (hours)",
    y = "Concentration (mg/L)"
  ) +
  theme_minimal()

ggsave(
  "Week 01/figures/theoph_linear.png",
  plot = p1,
  width = 8,
  height = 5,
  dpi = 300
)

# spaghetti plot - log10 scale

sum(Theoph$conc <= 0)

p2 <- ggplot(filter(Theoph, conc > 0),
       aes(x = Time, y = conc, group = Subject, color = Subject)) +
  geom_line(linewidth = 0.8) +
  scale_y_log10() +
  labs(
  title = "Theophylline Concentration-Time Profiles",
  x = "Time (hours)",
  y = "Concentration (mg/L)"
  ) +
  theme_minimal()

ggsave(
  "Week 01/figures/theoph_logscale.png",
  plot = p2,
  width = 8,
  height = 5,
  dpi = 300
)

# (b) Cmax and Tmax for each subject
pk_summary <- Theoph %>%
  group_by(Subject) %>%
  summarise(
    Cmax = max(conc),
    Tmax = Time[which.max(conc)]
  )

print(pk_summary)

# (c) calculate total dose and dose-normalized dose
pk_summary <- pk_summary %>%
  left_join(
    Theoph %>%
      group_by(Subject) %>%
      summarise(
        Total_Dose = first(Dose * Wt)
      ),
    by = "Subject"
  ) %>%
  mutate(
    Dose_Normalized_Cmax = Cmax / Total_Dose
  )

print(pk_summary)

# (d) Verify predictions
# Subject with latest Tmax
pk_summary %>%
  filter(Tmax == max(Tmax))

# Subject with highest dose-normalised Cmax
pk_summary %>%
  filter(Dose_Normalized_Cmax == max(Dose_Normalized_Cmax))