#!/usr/bin/Rscript
########################################################################################################################################################
# 
# <ISP_facet_raw.R>
#
# Description:
#   This script creates raw speed plots, facet by (month,day) and (month,hour), colour represent top ten households for a specific year,month for one ISP
#   Metrics to be represent by colour will be optional by user at a later stage
#
# Instructions: **To be changed
#   1. Change source_path to the location of flat file
#   2. Change dest_path to location to save plots
#   3. Make sure that name of the flat file is "NDT_data.csv", otherwise, change accordingly
#   4. input parameters --> ISP, year
#   5. Run the script
#
# Input:
#   1. ISP
#   2. year
#   3. month
#   4. metric to be represented by colour (IP_address)
#
# Output:
#   1. Raw speed scatter plot facet by (month,day) for a particular year,month (user input) with line representing median aggregated by month
#   2. Raw speed scatter plot facet by (month,hour) for a particular year,month (user input) with line representing median aggregated by month
#
##########################################################################################################################################################


rm(list=ls())

require(foreign)
require(nnet)
require(ggplot2)
require(reshape2)
require(effects)
require(plyr)
require(scales)

#User input
nrow = 6
ncol = 6

args <- commandArgs(trailingOnly = TRUE)
year <- as.integer(args[1])
month <- as.integer(args[2])
ISP <- as.character(args[3])


source_path <- file.path("Data/")
dest_path <- file.path("Plot/")

flat_file <- read.csv("Data/NDT_data.csv")

  

#--------------------------------------------------------Binding data-------------------------------------------------------------------#





house_total <- flat_file[which(flat_file$ISP == ISP),]
house_total_yearmonth <- house_total[house_total$year == year & house_total$month == month,]


house_total_filtered <- house_total_yearmonth[with(house_total_yearmonth, order(IP_test_count_month, decreasing = TRUE)), ]
top_ten_list <- data.frame(unique(house_total_filtered$IP_address))
top_ten_list <- data.frame(top_ten_list = top_ten_list[1:10,])
top_ten_households <- house_total_yearmonth[house_total_yearmonth$IP_address %in% top_ten_list$top_ten_list,]

  
top_ten_households$hour <- as.POSIXct(strptime(top_ten_households$hour, format = "%H"), format = "%y/%m/%d %H:%M:%S")
top_ten_households$MonthYear <- paste( top_ten_households$year, top_ten_households$month, sep="-" )
top_ten_households$MonthYear <- strptime(paste(top_ten_households$MonthYear, "1", sep="-"), format = "%Y-%m-%d")
top_ten_households$month_txt <- format(top_ten_households$MonthYear,"%b")

#----------------------------------------Facet by (month,day)--------------------------------------------------#


  
graph_name = paste("plot__",top_ten_households$year,"_",top_ten_households$month, "__","raw__facet(month,day)_hour_speed_IPaddress","__", top_ten_households$ISP,"____" , sep="")
ggplot_ISP  <- ggplot(top_ten_households, aes(x= hour, y = download_speed, color = IP_address, shape = IP_address)) + 
    geom_point() + 
    facet_wrap(month_txt ~day,  ncol = ncol, nrow = nrow) +
    scale_color_manual(values=c("green", "red", "darkgreen", "blue","purple", "green", "red", "darkgreen", "blue","purple"), name="IP address") + 
    scale_shape_manual(name="IP address", values=c(7,7,7,7,7,8,8,8,8,8)) +
    #stat_summary(aes(y = download_speed,group = 1), fun.y="median", colour="grey68", geom="line", size=0.5)+
    ylab("Download speed (mbps)") +
    scale_x_datetime(breaks = seq(min(top_ten_households$hour),max(top_ten_households$hour),"12 hour"),labels = date_format("%H:%M", tz="Australia/Sydney"))+
    expand_limits(y = 0)+
    scale_y_continuous(expand = c(0, 0)) +
    ggtitle(graph_name)+
    theme_bw()
savefileName = paste("plot__",top_ten_households$year,"_",top_ten_households$month, "__","raw__facet(month,day)_hour_speed_IPaddress","__", top_ten_households$ISP,"____",".png" , sep="")
ggsave(filename=savefileName, plot=ggplot_ISP, path = dest_path, width = 10, height = 6)






#----------------------------------------Facet by (month,hour)--------------------------------------------------#
top_ten_households$hour <- format(top_ten_households$hour,"%H:%M")

graph_name = paste("plot__",top_ten_households$year,"_",top_ten_households$month, "__","raw__facet(month,hour)_day_speed_IPaddress","__", top_ten_households$ISP,"____" , sep="")
ggplot_ISP  <- ggplot(top_ten_households, aes(x= day, y = download_speed, color = IP_address, shape = IP_address)) + 
  geom_point() + 
  facet_wrap(month_txt ~ hour,  ncol = ncol, nrow = nrow) +
  scale_color_manual(values=c("green", "red", "darkgreen", "blue","purple", "green", "red", "darkgreen", "blue","purple"), name="IP address") + 
  scale_shape_manual(name="IP address", values=c(7,7,7,7,7,8,8,8,8,8)) +
  #stat_summary(aes(y = download_speed,group = 1), fun.y="median", colour="grey68", geom="line", size=0.5)+
  ylab("Download speed (mbps)") +
  expand_limits(y = 0)+
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle(graph_name)+
  theme_bw()
savefileName = paste("plot__",top_ten_households$year,"_",top_ten_households$month, "__","raw__facet(month,hour)_day_speed_IPaddress","__", top_ten_households$ISP,"____",".png" , sep="")
ggsave(filename=savefileName, plot=ggplot_ISP, path = dest_path, width = 10, height = 6)

