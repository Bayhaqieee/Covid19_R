# Load packages

library(httr)       # CRAN v1.4.2
library(dplyr)      # CRAN v1.0.1
library(lubridate)  # CRAN v1.7.9
library(tidyr)      # CRAN v1.1.1
library(zoo)        # CRAN v1.8-8
library(ggplot2)    # CRAN v3.3.2
library(hrbrthemes) # CRAN v0.8.0

# Fetch COVID-19 data in regional level

data <- GET ("https://data.covid19.go.id/public/api/update.json")
data

#' In this example we will inspect Jawa Barat data. Please pick one province according to your interest, other than Jawa Barat, to be used as case study :)

resp <- GET("https://data.covid19.go.id/public/api/prov_detail_SUMATERA_BARAT.json")
status_code(resp)

cov_prov_raw <- content(resp, as = "parsed", simplifyVector = TRUE)
str(cov_prov_raw, max.level = 2, vec.len = 3)

# Inspect the daily cases, pre-process data if necessary

cov_prov_raw$kasus_total

cov_prov_raw$meninggal_persen

cov_prov_raw$sembuh_persen

cov_prov <- cov_prov_raw$list_perkembangan
str(cov_prov)

cov_prov_daily <-
  cov_prov_raw$list_perkembangan %>%
  transmute(
    date = as.POSIXct(tanggal / 1000, origin = "1970-01-01") %>%
      as.Date(),
    newcase = KASUS,
    recovered = SEMBUH,
    death = MENINGGAL
  )

glimpse(cov_prov_daily)
summary(cov_prov_daily)

# Turn table into graph!

# Kasus Harian Positif COVID-19 di Sumatera Barat
cov_prov_daily %>%
  ggplot(aes(date, newcase)) +
  geom_col(fill = "firebrick3") +
  scale_x_date(
    breaks = "2 weeks",
    guide = guide_axis(check.overlap = TRUE, n.dodge = 2),
    labels = scales::label_date(format = "%e %b"),
    expand = c(0.005, 0.005)
  ) +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Positif COVID-19 di Jawa Barat",
    subtitle = "Terjadi pelonjakan kasus di awal bulan Juli akibat klaster Secapa AD Bandung",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum_tw(
    base_size = 13,
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

#' Please continue with your own for the other variables! Do not forget to draw some conclusion about them :)

# Kasus Harian Sembuh COVID-19 di Sumatera Barat
ggplot(cov_prov_daily, aes(date, recovered)) +
  geom_col(fill = "olivedrab2") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Sembuh Dari COVID-19 di Sumatera Barat",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13, 
    plot_title_size = 16,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

# Kasus Harian Meninggal COVID-19 di Sumatera Barat
ggplot(cov_prov_daily, aes(date, death)) +
  geom_col(fill = "darkslategray4") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Meninggal Akibat COVID-19 di Sumatera Barat",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13, 
    plot_title_size = 16,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

# Daily cases, rolling 3-day average

#' This is a bonus section for you! Please forgive me for giving you such a lengthy code below :p

cov_prov_daily %>%
  mutate(
    across(newcase:death, ~ rollmean(.x, k = 3, fill = NA))
  ) %>%
  pivot_longer(
    cols = newcase:death,
    names_to = "status",
    values_to = "rollmean3day"
  ) %>%
  mutate(
    status = factor(status, levels = c("newcase", "recovered", "death"), labels = c("Positif", "Sembuh", "Meninggal"))
  ) %>%
  ggplot(aes(date, rollmean3day, colour = status)) +
  facet_wrap(~status, ncol = 1, scales = "free_y") +
  geom_line(size = 1.1, show.legend = FALSE) +
  scale_x_date(
    breaks = "10 days",
    guide = guide_axis(check.overlap = TRUE, n.dodge = 2),
    labels = scales::label_date(format = "%e %b"),
    expand = c(0.005, 0.005)
  ) +
  scale_y_continuous(position = "right") +
  scale_colour_manual(
    values = c("firebrick3", "seagreen2", "darkslategray4")
  ) +
  labs(
    x = NULL,
    y = NULL,
    title = "Kasus Harian COVID-19 di Jawa Barat Menggunakan Rerata Bergerak 3 hari",
    subtitle = "Jumlah kasus pada sumbu-y tidak dibuat seragam antar panel status kasus",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum_tw(
    base_size = 13,
    plot_title_size = 21,
    strip_text_face = "italic",
    grid = FALSE,
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

#' What can you learn from the graph above? Also, do not hesitate to ping me at Telegram if you want to confirm some code snippets (please find my username at the very end of this document).

# Transform daily cases into weekly cases

cov_prov_weekly <-
  cov_prov_daily %>%
  group_by(
    year = year(date),
    week = week(date)
  ) %>%
  summarise(
    across(c(newcase:death), ~ sum(.x, na.rm = TRUE))
  ) %>%
  ungroup()

glimpse(cov_prov_weekly)


# [Again] turn table into graph! 

#' You can go wild with your creativity here, tell me what you learn from the graphs!

# Is this week is better than last week?

cov_prov_weekly_comparison <-
  cov_prov_weekly %>%
  transmute(
    year,
    week,
    newcase,
    newcase_lastweek = dplyr::lag(newcase, 1), # can you explain why we use of `::` operator here?
    newcase_lastweek = replace_na(newcase_lastweek, 0),
    is_better = newcase < newcase_lastweek
  )
glimpse(cov_prov_weekly_comparison)

cov_prov_weekly_comparison %>%
  count(is_better)

#' Please put your thoughts into this graph!

cov_prov_weekly_comparison %>%
  ggplot(aes(week, newcase, fill = is_better)) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = c("TRUE" = "seagreen3", "FALSE" = "salmon")) +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Pekanan Positif COVID-19 di Jawa Barat",
    subtitle = "Kolom hijau menunjukan penambahan kasus baru lebih sedikit dibandingkan satu pekan sebelumnya",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum_tw(
    base_size = 13,
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

#' I challenge you to make the similar graph for the recovered and death cases :)

# The Seventh-day Amplification Factor

cov_prov_daily %>%
    mutate(
        cumulative_cases = cumsum(newcase),
        rolling_avg_3day = rollmean(newcase, k = 3, fill = NA),
        lag_7day = lag(cumulative_cases, 7),
        amplification_factor = cumulative_cases / lag_7day
    ) %>%
    filter(!is.na(amplification_factor)) %>%
    ggplot(aes(date, amplification_factor)) +
    geom_line(color = "steelblue", size = 1) +
    labs(
        x = NULL,
        y = "Amplification Factor",
        title = "Seventh-day Amplification Factor for COVID-19 Cases",
        subtitle = "Tracking the amplification factor over time",
        caption = "Sumber data: covid.19.go.id"
    ) +
    theme_ipsum(
        base_size = 13,
        plot_title_size = 16,
        grid = "Y",
        ticks = TRUE
    ) +
    theme(plot.title.position = "plot")


#' Please consult to these documents:
#' * https://www.bangkokpost.com/opinion/opinion/1902320/taking-the-fight-to-covid-19-using-simple-mathematics
#' * https://towardsdatascience.com/how-the-seventh-day-amplification-factor-can-gauge-the-existence-of-corona-silent-carriers-b9414ef3df62
#'
#' Again, using the similar approach as in the previous section and from what you've learn from DQLab project, I believe that you can calculate the Seventh-day Amplification Factor easily!
#' Here are some clues that I have for you (in no particular order):
#' * cov_prov_daily
#' * cumsum()
#' * 3-day rolling average
#' * lag()
#' Please take those hints to calculate the Seventh-day Amplification Factor for your province of interest!