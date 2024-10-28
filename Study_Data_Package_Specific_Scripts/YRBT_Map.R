# ==============================================================================
#
# Make maps for ERsed manuscript 
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# This code is modified from code written by Peter Regier 
# 7 June 2023
#
# ==============================================================================

require(pacman)

p_load(tidyverse, #keep it tidy
       raster, # work with rasters, NOTE: masks dplyr::select
       janitor, # clean_names()
       ggthemes, # theme_map()
       ggsflabel, # add labels to sf objects
       ggnewscale, # set multiple color scales
       ggspatial, # add north arrow and scale bar
       nhdplusTools, # get watershed boundary/flowlines
       elevatr, # pull elevation maps
       sf) # tidy spatial

rm(list=ls(all=T))

# ================================= User inputs ================================

fire_dir <- 'C:/Users/forb086/OneDrive - PNNL/Shared Documents - RC-3, River Corridor SFA/Field Logistics/Shapefiles, Coordinates, and Maps/Evans_Canyon_Burn_Severity_ShapeFiles/mtbs/'

common_crs = 4326

out_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/Wenas_Data_Package/'

# ================================ format sf objects ===========================

fire_boundary <- read_sf(paste0(fire_dir, 'wa4685412079920200831/wa4685412079920200831_20200830_20200909_burn_bndy.shp')) %>% 
  st_transform(common_crs)

w10 <- tibble(lat = 46.867459, long = -120.774414, site_id = "W10") %>% 
  st_as_sf(coords = c("long", "lat"), crs = common_crs)

w20 <- tibble(lat = 46.832848, long = -120.710887, site_id = "W20") %>% 
  st_as_sf(coords = c("long", "lat"), crs = common_crs)

# ================================= get flowlines ==============================

wenas_huc10 <- get_huc(AOI = w10, 
                       type = "huc10")

wenas_flowlines <- get_nhdplus(AOI = wenas_huc10)

# ============================= get burn severity ==============================

severity_raw <-  raster::raster(paste0(fire_dir, "wa4685412079920200831/wa4685412079920200831_20200830_20200909_dnbr6.tif"))

severity_reproject <- projectRaster(severity_raw ,crs = common_crs)

severity_crop <- mask(severity_reproject, fire_boundary)

severity <- as.data.frame(severity_crop, xy = T) %>% 
  as_tibble() %>% 
  rename("long" = x, 
         "lat" = y, 
         "severity" = Layer_1) %>% 
  filter(!is.na(severity)) %>% 
  mutate(f_severity = as.factor(round(severity, 0)))

# ================================= make map ===================================

## Set up severity color scheme
fire_colors <- c("#54A266", "#F5F54F", "#F8B75B", "#FA8B63", "#FC543D", "#FF0F0F")

ggplot() + 
  geom_sf(data = wenas_huc10, fill = "grey92", color = "black") +
  geom_raster(data = severity, 
              aes(long, lat, fill = f_severity), alpha = 0.95) + 
  geom_sf(data = fire_boundary, fill = NA, color = "red", lwd = 0.5) + 
  scale_fill_manual(values = fire_colors) + 
  geom_sf(data = wenas_flowlines, color = "blue", alpha = 0.5) +
  theme_map() + 
  labs(x = "", y = "", fill = "Severity \n (dNBR)")+
  geom_sf(data = w10, size = 2)+
  geom_sf(data = w20, size = 2)+
  geom_sf_label(data = w10, aes(label = site_id), nudge_x = -0.025)+
  geom_sf_label(data = w20, aes(label = site_id), nudge_x = -0.025)+ 
  ggspatial::annotation_scale(
    location = "bl",
    pad_x = unit(0.8, "in"),
    bar_cols = c("black", "white")) +
  ggspatial::annotation_north_arrow(
    location = "bl", which_north = "true",
    pad_x = unit(1.1, "in"), pad_y = unit(0.4, "in"),
    style = ggspatial::north_arrow_nautical(
      fill = c("black", "white"),
      line_col = "grey20"))


ggsave(paste0(out_dir, "Wenas_data_package_map.png"),  width = 7, height = 6)
