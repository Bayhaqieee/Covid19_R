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


# Weekly Data Aggregation (Data Analysis)
library(dplyr)
library(lubridate)

cov_jabar_pekanan <- new_cov_jabar %>% 
  count(
    tahun = year(tanggal),
    pekan_ke = week(tanggal),
    wt = kasus_baru,
    name = "jumlah"
  )

glimpse(cov_jabar_pekanan)

# Case Comparison
library(dplyr)
cov_jabar_pekanan <-
  cov_jabar_pekanan %>% 
  mutate(
    jumlah_pekanlalu = dplyr::lag(jumlah, 1),
    jumlah_pekanlalu = ifelse(is.na(jumlah_pekanlalu), 0, jumlah_pekanlalu),
    lebih_baik = jumlah < jumlah_pekanlalu
  )
glimpse(cov_jabar_pekanan)

library(ggplot2)
library(hrbrthemes)

# Weekly Case Comparison with Color Highlight
ggplot(cov_jabar_pekanan[cov_jabar_pekanan$tahun==2020,],aes(pekan_ke, jumlah, fill=lebih_baik)) + geom_col(show.legend = FALSE) + scale_x_continuous(breaks = 9:29, expand = c(0, 0)) + scale_fill_manual(values = c("TRUE" = "seagreen3", "FALSE" = "salmon")) + labs(
x = NULL,
y = "Jumlah kasus",
title = "Kasus Pekanan Positif COVID-19 di Jawa Barat",
subtitle = "Kolom hijau menunjukan penambahan kasus baru lebih sedikit dibandingkan satu pekan sebelumnya",
caption = "Sumber data: covid.19.go.id") +
theme_ipsum(
base_size = 13,
plot_title_size = 21,
grid = "Y",
ticks = TRUE) +
theme(plot.title.position = "plot")


# Data Conclusion and Accumulated Data
library(dplyr)
cov_jabar_akumulasi <- 
  new_cov_jabar %>% 
  transmute(
    tanggal,
    akumulasi_aktif = cumsum(kasus_baru) - cumsum(sembuh) - cumsum(meninggal),
    akumulasi_sembuh = cumsum(sembuh),
    akumulasi_meninggal = cumsum(meninggal)
  )

tail(cov_jabar_akumulasi)

# Data Visualization
library(ggplot2)
ggplot(data = cov_jabar_akumulasi, aes(x = tanggal, y = akumulasi_aktif)) +
  geom_line()