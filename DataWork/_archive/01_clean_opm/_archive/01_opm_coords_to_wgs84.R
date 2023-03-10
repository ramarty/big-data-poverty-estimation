# OPM Coords to WGS84

# OPM coordinates not originally in WGS84; convert and save file with OPM UID and lat/lon.

# Load Data --------------------------------------------------------------------
bisp_coords <- read_dta(file.path(secure_dir, "Data", "OPM", "RawData - PII", "GPS_uid_crosswalk.dta"))
pak_adm0 <- readRDS(file.path(dropbox_dir, "Data", "GADM", "RawData", "gadm36_PAK_0_sp.rds"))

# Prep Data --------------------------------------------------------------------
bisp_coords <- bisp_coords %>%
  filter(!is.na(GPSN)) %>%
  
  mutate(latitude = get_lat_lon(GPSN),
         longitude = get_lat_lon(GPSE),
         uid = uid %>% as.numeric()) %>%
  
  dplyr::select(uid, latitude, longitude) %>%
  
  filter(latitude <= 100,
         longitude <= 100)

## Restrict to Coordinates in Pakistan & Tile ID
bisp_coords_sdf <- bisp_coords
coordinates(bisp_coords_sdf) <- ~longitude+latitude
crs(bisp_coords_sdf) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

dist_to_pak <- gDistance(bisp_coords_sdf, pak_adm0, byid=T) %>% as.vector()
bisp_coords <- bisp_coords[dist_to_pak == 0,]

# Export -----------------------------------------------------------------------
write.csv(bisp_coords, file.path(secure_dir, "Data", "OPM", "FinalData - PII", "GPS_uid_crosswalk.csv"), row.names = F)
saveRDS(bisp_coords, file.path(secure_dir, "Data", "OPM", "FinalData - PII", "GPS_uid_crosswalk.Rds"))

