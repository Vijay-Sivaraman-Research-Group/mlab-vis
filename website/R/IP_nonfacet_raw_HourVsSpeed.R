########################################################################################################################################################
# 
# <IP_nonfacet_raw_HourVsSpeed.R>
#
# Description:
#   This script creates raw speed plot as a function of hour for single ip_address in a specific month,year
#
# Instructions: **To be changed
#   1. Change source_path to the location of flat file
#   2. Change dest_path to location to save plots
#   3. Make sure that name of the flat file is "NDT_data.csv", otherwise, change accordingly
#   4. input parameters --> ISP, year
#   5. Run the script
#
# Input:
#   1. year
#   2. month
#   3. IP_address
#   4. metric to be represented by colour (download_speed, AveRTT, or congestion_signals)
#
# Output:
#   1. Raw speed scatter plot as a function of hour for a particular month,year (user input) with line representing median aggregated by hour over a month
#   
#
##########################################################################################################################################################


rm(list=ls())

require(foreign)
require(nnet)
require(ggplot2)
require(reshape2)
require(effects)
require(cluster)
library(scales)


source("function.R")

#User input
args <- commandArgs(trailingOnly = TRUE)
year <- as.integer(args[1])
month <- as.integer(args[2])
IP_address <- as.character(args[3])
colour <- as.character(args[4])


#--------------------------------------------------------Binding data-------------------------------------------------------------------#

source_path <- file.path("Data/")
dest_path <- file.path("Plot/")

flat_file <- read.csv("Data/NDT_data.csv")

house_total <- flat_file[which(flat_file$IP_address == IP_address),]
house_total_year <- house_total[house_total$year == year ,]
house_total_month <- house_total_year[house_total_year$month == month ,]

#--------------------------------------------------------Ploting data-------------------------------------------------------------------#
# Assign unit to cluster function
if(colour == 'download_speed'){
  unit = 'mbps'
  colour_manual <- c("green","red","blue","green" )
}else if(colour == 'AveRTT'){
  unit = 'ms'
  colour_manual <- c("red","green","blue","red" )
}else if(colour == 'Congestion_signals'){
  unit = ''
  colour_manual <- c("red","green","blue","red" )
}



#--------------------------------- Colour by speed-----------------------------------#

sub_house_range <- dataCluster(house_total_month,colour, unit)
sub_house_range$hour <- as.POSIXct(strptime(sub_house_range$hour, format = "%H"), format = "%y/%m/%d %H:%M:%S")

graph_name = paste("plot__",sub_house_range$year, "_", sub_house_range$month, "__","raw__hour_speed_", colour,"__", sub_house_range$ISP,"__", sub_house_range$IP_address , sep="")

IP_Plot_Speed <- ggplot(sub_house_range, aes(x = hour, y = download_speed, color = range, shape = range)) +
  geom_point()+
  scale_color_manual(values=colour_manual, name= colour)+
  scale_shape_discrete(name=colour) +
  stat_summary(aes(y = download_speed,group = 1), fun.y="median", colour="grey68", geom="line", size=1)+
  ylab("Download speed (mbps)") +
  scale_x_datetime(breaks = seq(min(sub_house_range$hour),max(sub_house_range$hour),"3 hour"),labels = date_format("%H:%M", tz="Australia/Sydney"))+
  expand_limits(y = 0)+
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle(graph_name)+
  theme_bw()



savefileName = paste("plot__",sub_house_range$year, "_", sub_house_range$month, "__","raw__hour_speed_", colour,"__", sub_house_range$ISP,"__", sub_house_range$IP_address ,".png", sep="")
ggsave(filename=savefileName, plot=IP_Plot_Speed, path = dest_path, width = 10, height = 6)







