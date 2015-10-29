########################################################################################################################################################
# 
# <ISP_nonfacet_norm_HourVsSpeed.R>
#
# Description:
#   This script creates norm speed plots as a function of hour for all input ISPs
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
#   3. month --> either one month or '*' for all months in a particular year
#
# Output:
#   1. Norm speed plot as a function of hour for a particular year,month (user input), aggregated by median
#
##########################################################################################################################################################

rm(list=ls())

require(foreign)
require(nnet)
require(ggplot2)
require(reshape2)
require(effects)
require(cluster)
require(scales)

#User input
args <- commandArgs(trailingOnly = TRUE)
year <- as.integer(args[1])
month <- as.character(args[2])
ISP1 <- as.character(args[3])
ISP2 <- as.character(args[4])
ISP3 <- as.character(args[5])
ISP4 <- as.character(args[6])
ISP5 <- as.character(args[7])
ISP6 <- as.character(args[8])

source_path <- file.path("Data/")
dest_path <- file.path("Plot/")

flat_file <- read.csv("Data/NDT_data.csv")


#--------------------------------------------------------Binding data-------------------------------------------------------------------#


house_total <- flat_file[which(flat_file$ISP == ISP1 | flat_file$ISP == ISP2 | flat_file$ISP == ISP3 | flat_file$ISP == ISP4 | flat_file$ISP == ISP5 | flat_file$ISP == ISP6),]
if(month == 'all'){
  house_total_month <- house_total[which(house_total$year == year)  ,]
  month = 'all'
}else{
  house_total_month <- house_total[which(house_total$year == year & house_total$month == month)  ,]
}
house_total_filtered <- house_total_month[which(house_total_month$IP_test_count_month >10),]
house_total_filtered <- house_total_filtered[order(house_total_filtered$ISP, house_total_filtered$hour),]

  
#--------------------------------- Colour by ISP (median)-----------------------------------#

Average_value_median <- aggregate(download_speed_normalised_month ~ year+ISP+hour, house_total_filtered, median)
Average_value_median$hour <- as.POSIXct(strptime(Average_value_median$hour, format = "%H"), format = "%y/%m/%d %H:%M:%S")

#For plot file name
ISPs <- c(ISP1, ISP2,ISP3, ISP4, ISP5, ISP6)
ISPs <- sort(ISPs[ISPs != ""])
ISPs_list <- ""
for(i in unique(ISPs)){
  ISPs_add <- paste(i,"_",sep = "")
  ISPs_list <- paste(ISPs_list,ISPs_add,sep = "")
}


graph_name = paste("plot__",Average_value_median$year,"_", month, "__","norm__hour_speed_ISPs__", ISPs_list,"___", sep="")
SpeedHour_Plot <- ggplot(Average_value_median, aes(x = hour, y = download_speed_normalised_month, color = ISP, shape = ISP, color=supp)) +
  geom_point(size=2.5)+
  geom_line(size=1)+
  ylab("Normalised Download speed") +
  scale_x_datetime(breaks = seq(min(Average_value_median$hour),max(Average_value_median$hour),"3 hour"),labels = date_format("%H:%M", tz="Australia/Sydney"))+
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +  
  ggtitle(graph_name)+
  theme_bw()
savefileName =paste("plot__",Average_value_median$year,"_", month, "__","norm__hour_speed_ISPs__", ISPs_list,"___",".png", sep="")
ggsave(filename=savefileName, plot=SpeedHour_Plot, path = dest_path, width = 10, height = 6)



#--------------------------------- Colour by ISP (mean)-----------------------------------#
# 
# Average_value_mean <- aggregate(download_speed_normalised_month ~ year+ISP+hour, house_total_filtered, mean)
# Average_value_mean$hour <- as.POSIXct(strptime(Average_value_mean$hour, format = "%H"), format = "%y/%m/%d %H:%M:%S")
# 
# graph_name = paste(Average_value_mean$year[1]," Normalised speed by hour plot (mean) ")
# SpeedHour_Plot <- ggplot(Average_value_mean, aes(x = hour, y = download_speed_normalised_month, color = ISP, shape = ISP, color=supp)) +
#   geom_point(size=2.5)+
#   geom_line(size=1)+
#   ylab("Normalised Download speed") +
#   scale_x_datetime(breaks = seq(min(Average_value_mean$hour),max(Average_value_mean$hour),"3 hour"),labels = date_format("%H:%M", tz="Australia/Sydney"))+
#   scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
#   ggtitle(graph_name)+
#   theme_bw()
# savefileName = paste(Average_value_mean$year[1],"_",Average_value_mean$month[1],"_","norm_HourVsSpeed_ISP_mean_nonfacet.png", sep="")
# ggsave(filename=savefileName, plot=SpeedHour_Plot, path = dest_path, width = 10, height = 6)
# 
# 


