########################################################################################################################################################
# 
# <ISP_nonfacet_norm_MonthVsSpeed.R>
#
# Description:
#   This script creates raw speed plots as a function of month in a particular year for all input ISPs
#
# Instructions:
#   1. Change source_path to the location of flat file
#   2. Change dest_path to location to save plots
#   3. Make sure that name of the flat file is "NDT_data.csv", otherwise, change accordingly
#   4. input parameters --> ISP, year
#   5. Run the script
#
# Input:
#   1. ISP(s), maximum of 6 ISPs
#   2. year
#
# Output:
#   1. Raw speed plot as a function of month for a particular year (user input), aggregated by median
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

#User input
args <- commandArgs(trailingOnly = TRUE)
year <- as.integer(args[1])
ISP1 <- as.character(args[2])
ISP2 <- as.character(args[3])
ISP3 <- as.character(args[4])
ISP4 <- as.character(args[5])
ISP5 <- as.character(args[6])
ISP6 <- as.character(args[7])

source_path <- file.path("Data/")
dest_path <- file.path("Plot/")

flat_file <- read.csv("Data/NDT_data.csv")




#--------------------------------------------------------Binding data-------------------------------------------------------------------#


house_total <- flat_file[which(flat_file$ISP == ISP1 | flat_file$ISP == ISP2 | flat_file$ISP == ISP3 | flat_file$ISP == ISP4 | flat_file$ISP == ISP5 | flat_file$ISP == ISP6),]
house_total_year <- house_total[house_total$year == year ,]
house_total_filtered <- house_total_year[which(house_total_year$IP_test_count_month >10),]
house_total_filtered <- house_total_filtered[order(house_total_filtered$year, house_total_filtered$month),]
  
#--------------------------------- Colour by ISP (median)-----------------------------------#


#For plot file name
ISPs <- c(ISP1, ISP2,ISP3, ISP4, ISP5, ISP6)
ISPs <- sort(ISPs[ISPs != ""])
ISPs_list <- ""
for(i in unique(ISPs)){
  ISPs_add <- paste(i,"_",sep = "")
  ISPs_list <- paste(ISPs_list,ISPs_add,sep = "")
}

Average_value_median <- aggregate(download_speed ~ year+month+ISP, house_total_filtered, median)
Average_value_median$MonthYear <- paste( Average_value_median$year, Average_value_median$month, sep="-" )
Average_value_median$MonthYear <- strptime(paste(Average_value_median$MonthYear, "4", sep="-"), format = "%Y-%m-%d")

graph_name = paste("plot__",Average_value_median$year, "__","raw__month_speed_ISPs__", ISPs_list,"___", sep="")
SpeedMonth_Plot <- ggplot(Average_value_median, aes(x = MonthYear, y = download_speed, color = ISP, shape = ISP, color=supp)) +
  geom_point(size=2.5)+
  geom_line(size=1)+
  scale_x_datetime(labels = date_format("%b %Y", tz="Australia/Sydney"))+
  ylab("Download speed (mbps)") +
  xlab("month/year") +
  expand_limits(y = 0)+
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle(graph_name)+
  theme_bw()

savefileName = paste("plot__",Average_value_median$year, "__","raw__month_speed_ISPs__", ISPs_list,"___",".png", sep="")
ggsave(filename=savefileName, plot=SpeedMonth_Plot, path = dest_path, width = 10, height = 6)


#--------------------------------- Colour by ISP (mean)-----------------------------------#

# 
# Average_value_mean <- aggregate(download_speed ~ year+month+ISP, house_total_filtered, mean)
# Average_value_mean$MonthYear <- paste( Average_value_mean$year, Average_value_mean$month, sep="-" )
# Average_value_mean$MonthYear <- strptime(paste(Average_value_mean$MonthYear, "4", sep="-"), format = "%Y-%m-%d")
# 
# graph_name = paste(Average_value_mean$year[1]," Raw speed by month plot (mean) ")
# SpeedMonth_Plot <- ggplot(Average_value_mean, aes(x = MonthYear, y = download_speed, color = ISP, shape = ISP, color=supp)) +
#   geom_point(size=2.5)+
#   geom_line(size=1)+
#   scale_x_datetime(labels = date_format("%b %Y", tz="Australia/Sydney"))+
#   ylab("Download speed (mbps)") +
#   xlab("month/year") +
#   expand_limits(y = 0)+
#   scale_y_continuous(expand = c(0, 0)) +
#   ggtitle(graph_name)+
#   theme_bw()
# 
# savefileName = paste(Average_value_mean$year[1],"_","raw_MonthVsSpeed_ISP_mean_nonfacet.png", sep="")
# ggsave(filename=savefileName, plot=SpeedMonth_Plot, path = dest_path, width = 10, height = 6)

