# you need to install.packages("httr") and install.packages("rjson") first
# Load the library
library(httr)
library(rjson)
set_config(config(ssl_verifypeer = 0L))

# Load the data
json_file <- "data.json"
resp <- fromJSON(paste(readLines(json_file), collapse=""))
# resp <- GET ("https://storage.googleapis.com/dqlab-dataset/update.json")
resp

# Check the status code
status_code (resp)

# Check the headers
resp$status_code
identical(resp$status_code, status_code(resp))

# Check the headers
headers(resp)

# Extract the data
cov_id_raw <- content(resp, as = "parsed", simplifyVector = TRUE) 

# Check the data
length(cov_id_raw)
names(cov_id_raw)

# Extract the data
cov_id_update <- cov_id_raw$update

lapply(cov_id_update, names)
# Kapan tanggal pembaharuan data penambahan kasus?
cov_id_update$penambahan$tanggal  

# Berapa jumlah penambahan kasus sembuh?
cov_id_update$penambahan$jumlah_sembuh  

# Berapa jumlah penambahan kasus meninggal?
cov_id_update$penambahan$jumlah_meninggal  

# Berapa jumlah total kasus positif hingga saat ini?
cov_id_update$total$jumlah_positif  

# Berapa jumlah total kasus meninggal hingga saat ini?
cov_id_update$total$jumlah_meninggal 