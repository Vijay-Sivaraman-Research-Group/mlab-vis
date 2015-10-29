#!/usr/bin/Rscript
########################################################################################################################################################
# 
# <IP_nonfacet_raw_MonthVsSpeed.R>
#
# Description:
#   This script creates raw speed plots, facet by (month,day) and (month,hour), for single ip_address for a specific year,month
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
#   1. Raw speed scatter plot facet by (month,day) for a particular year,month (user input) with line representing median aggregated by hour
#   2. Raw speed scatter plot facet by (month,hour) for a particular year,month (user input) with line representing median aggregated by hour
#
##########################################################################################################################################################



rm(list=ls())

require(foreign)
require(nnet)
require(ggplot2)
require(reshape2)
require(effects)
require(cluster)
library(plyr)
library(scales)

source("function.R")

#User input
ncol = 6
nrow = 6

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
}else if(colour == 'congestion_signals'){
  unit = ''
  colour_manual <- c("red","green","blue","red" )
}


#--------------------------------------------------------Ploting data Facet (month,day)-------------------------------------------------------------------#


  
  #--------------------------------- facet(month,day)-----------------------------------#
sub_house_range <- dataCluster(house_total_month,colour, unit)
sub_house_range$hour <- as.POSIXct(strptime(sub_house_range$hour, format = "%H"), format = "%y/%m/%d %H:%M:%S")
sub_house_range$MonthYear <- paste( sub_house_range$year, sub_house_range$month, sep="-" )
sub_house_range$MonthYear <- strptime(paste(sub_house_range$MonthYear, "1", sep="-"), format = "%Y-%m-%d")
sub_house_range$month_txt <- format(sub_house_range$MonthYear,"%b")

graph_name = paste("plot__",sub_house_range$year,"_",sub_house_range$month, "__","raw__facet(month,day)_day_speed_", colour,"__", sub_house_range$ISP,"__", sub_house_range$IP_address , sep="")

graphobj_hour  = ggplot(sub_house_range, aes(x= hour, y = download_speed, color = range, shape = range)) + 
  geom_point() + 
  facet_wrap(month_txt ~day,  ncol = ncol, nrow = nrow) +  
  scale_color_manual(values=colour_manual, name= colour)+
  scale_shape_discrete(name=colour) +
  stat_summary(aes(y = download_speed,group = 1), fun.y="median", colour="grey68", geom="line", size=0.5)+
  ylab("Download speed (mbps)") +
  scale_x_datetime(breaks = seq(min(sub_house_range$hour),max(sub_house_range$hour),"12 hour"),labels = date_format("%H:%M", tz="Australia/Sydney"))+
  expand_limits(y = 0)+
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle(graph_name)+
  theme_bw()

savefileName = paste("plot__",sub_house_range$year,"_",sub_house_range$month, "__","raw__facet(month,day)_day_speed_", colour,"__", sub_house_range$ISP,"__", sub_house_range$IP_address,".png" , sep="")
ggsave(filename=savefileName, plot=graphobj_hour, path = dest_path, width = 12, height = 6)



#--------------------------------- facet(month,hour)-----------------------------------#
sub_house_range <- dataCluster(house_total_month,colour, unit)
sub_house_range$hour <- as.POSIXct(strptime(sub_house_range$hour, format = "%H"), format = "%y/%m/%d %H:%M:%S")
sub_house_range$hour <- format(sub_house_range$hour,"%H:%M")
sub_house_range$MonthYear <- paste( sub_house_range$year, sub_house_range$month, sep="-" )
sub_house_range$MonthYear <- strptime(paste(sub_house_range$MonthYear, "1", sep="-"), format = "%Y-%m-%d")
sub_house_range$month_txt <- format(sub_house_range$MonthYear,"%b")


graph_name = paste("plot__",sub_house_range$year,"_",sub_house_range$month, "__","raw__facet(month,hour)_day_speed_", colour,"__", sub_house_range$ISP,"__", sub_house_range$IP_address , sep="")

graphobj_hour  = ggplot(sub_house_range, aes(x= day, y = download_speed, color = range, shape = range)) + 
  geom_point() + 
  facet_wrap(month_txt ~ hour,  ncol = ncol, nrow = nrow) +  
  scale_color_manual(values=colour_manual, name= colour)+
  scale_shape_discrete(name=colour) +
  stat_summary(aes(y = download_speed,group = 1), fun.y="median", colour="grey68", geom="line", size=0.5)+
  ylab("Download speed (mbps)") +
  expand_limits(y = 0)+
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle(graph_name)+
  theme_bw()

savefileName = paste("plot__",sub_house_range$year,"_",sub_house_range$month, "__","raw__facet(month,hour)_day_speed_", colour,"__", sub_house_range$ISP,"__", sub_house_range$IP_address,".png" , sep="")
ggsave(filename=savefileName, plot=graphobj_hour, path = dest_path, width = 12, height = 6)



  

 