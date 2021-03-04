# Load packages -----------------------------------------------------------

library(here)
library(tidyverse)
library(lvmisc)
library(ggsci)
library(patchwork)
library(ragg)

# Load data ---------------------------------------------------------------

load(here("output", "loocv_data.rda"))
cv_res_GRF_models <- map(
  cv_res_GRF_models,
  ~ mutate(
    .x, activity = as.factor(ifelse(speed %in% 1:6, "walking", "running"))
  )
)
cv_res_LR_models <- map(
  cv_res_LR_models,
  ~ mutate(
    .x, activity = as.factor(ifelse(speed %in% 1:6, "walking", "running"))
  )
)

# Hip pRGRF Bland-Altman plot ---------------------------------------------

BA_GRF_res_hip <- cv_res_GRF_models$hip %>%
  plot_bland_altman(color = BMI_cat, shape = activity) +
  guides(shape = FALSE) +
  scale_color_nejm() +
  scale_y_continuous(
    limits = c(-600, 600),
    expand = c(0, 0),
    breaks = seq(-600, 600, 200)
  ) +
  theme_light() +
  theme(
    plot.title = element_text(size = 15, hjust = 0.5),
    legend.title = element_blank(),
    legend.text = element_text(size = 13),
    axis.title.y = element_text(size = 13),
    axis.title.x = element_text(size = 13),
    axis.text.y = element_text(size = 13),
    axis.text.x = element_text(size = 13)
  ) +
  labs(
    title = "Hip",
    x = "Mean of Actual and Predicted pRGRF (N)",
    y = "Actual - Predicted pRGRF (N)"
  )

# Back pRLR Bland-Altman plot ---------------------------------------------

BA_LR_res_back <- cv_res_LR_models$lower_back %>%
  plot_bland_altman(color = BMI_cat, shape = activity) +
  guides(shape = FALSE) +
  scale_color_nejm() +
  scale_y_continuous(
    labels = scales::label_number(),
    limits = c(-20000, 20000),
    expand = c(0, 0),
    breaks = seq(-20000, 20000, 10000)
  ) +
  scale_x_continuous(
    limits = c(2500, 27500),
    expand = c(0, 0),
    breaks = seq(5000, 25000, 5000)
  ) +
  theme_light() +
  theme(
    plot.title = element_text(size = 15, hjust = 0.5),
    legend.title = element_blank(),
    legend.text = element_text(size = 13),
    axis.title.y = element_text(size = 13),
    axis.title.x = element_text(size = 13),
    axis.text.y = element_text(size = 13),
    axis.text.x = element_text(size = 13)
  ) +
  labs(
    title = "Lower Back",
    x = quote("Mean of Actual and Predicted pRLR" ~ (N %.% s^-1)),
    y = quote("Actual - Predicted pRLR" ~ (N %.% s^-1))
  )

# Combine and save plots --------------------------------------------------

fig3 <- BA_GRF_res_hip +
  BA_LR_res_back +
  plot_annotation(tag_levels = "A") +
  plot_layout(guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.tag = element_text(size = 16)
  )
agg_tiff(
  here("figures", "fig3.tiff"),
  width = 80,
  height = 25,
  units = "cm",
  res = 100,
  scaling = 2
)
plot(fig3)
dev.off()