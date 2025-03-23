# you need to install.packages("httr") and install.packages("rjson") first
# Load the library
library(httr)
library(rjson)
set_config(config(ssl_verifypeer = 0L))

# Load the data
json_file <- "jabar_data.json"
resp_jabar <- fromJSON(paste(readLines(json_file), collapse=""))

# resp_jabar <- GET("https://storage.googleapis.com/dqlab-dataset/prov_detail_JAWA_BARAT.json")
cov_jabar_raw <- content(resp_jabar, as = "parsed", simplifyVector = TRUE)


names(cov_jabar_raw)
cov_jabar_raw$kasus_total
cov_jabar_raw$meninggal_persen
cov_jabar_raw$sembuh_persen

# Extract spesific data and check the data
cov_jabar <- cov_jabar_raw$list_perkembangan
str(cov_jabar)
head(cov_jabar)

# Data Cleaning
library(dplyr)
new_cov_jabar <-
  cov_jabar %>% 
  select(-contains("DIRAWAT_OR_ISOLASI")) %>% 
  select(-starts_with("AKUMULASI")) %>% 
  rename(
    kasus_baru = KASUS,
    meninggal = MENINGGAL,
    sembuh = SEMBUH
    ) %>% 
  mutate(
    tanggal = as.POSIXct( tanggal / 1000, origin = "1970-01-01"),
    tanggal = as.Date(tanggal)
  )
str(new_cov_jabar)

# Visualization
library(ggplot2)
library(hrbrthemes)
ggplot(data = new_cov_jabar, aes(x = tanggal, y = kasus_baru)) +
  geom_col()

# Detailed Visualization (for Kasus Harian Positif COVID-19 di Jawa Barat)
library(ggplot2)
library(hrbrthemes)
ggplot(new_cov_jabar, aes(tanggal, kasus_baru)) + geom_col(fill = "salmon") +
labs(x = NULL,y = "Jumlah Kasus",title = "Kasus Harian Positif COVID-19 di Jawa Barat",
subtitle = "Terjadi pelonjakan kasus di awal bulan Juli akibat klaster Secapa AD Bandung",caption = "Sumber data: covid.19.go.id") 
+ theme_ipsum(base_size = 13, plot_title_size = 21, grid = "Y", ticks = TRUE) + theme(plot.title.position = "plot")

# Detailed Visualization (for Kasus Harian Sembuh COVID-19 di Jawa Barat)
library(ggplot2)
library(hrbrthemes)
ggplot(new_cov_jabar, aes(tanggal, sembuh)) +
  geom_col(fill = "olivedrab2") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Sembuh Dari COVID-19 di Jawa Barat",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13, 
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

# Detailed Visualization (for Kasus Harian Meninggal COVID-19 di Jawa Barat)
library(ggplot2)
library(hrbrthemes)
ggplot(new_cov_jabar, aes(tanggal, meninggal)) +
  geom_col(fill = "darkslategray4") +
  labs(
    x = NULL,
    y = "Jumlah kasus",
    title = "Kasus Harian Meninggal Akibat COVID-19 di Jawa Barat",
    caption = "Sumber data: covid.19.go.id"
  ) +
  theme_ipsum(
    base_size = 13, 
    plot_title_size = 21,
    grid = "Y",
    ticks = TRUE
  ) +
  theme(plot.title.position = "plot")

  library(dplyr)
library(lubridate)