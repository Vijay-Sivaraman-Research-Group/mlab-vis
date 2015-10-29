#Aim:
#This file contains all the functions that will be used regarding the M-lab project


#Instruction:
#1. In R-file which the function is to be called, use >source("function.R")
#2. Functions within this file will be able to call


###############################################################################################################

dataCluster <- function(mydata, data_field, unit){
  require(foreign)
  require(nnet)
  require(reshape2)
  require(effects)
  require(cluster)
 
  mydata.sort <- mydata[order(mydata[[data_field]]),]
  mydata.field <- data.frame(mydata.sort[,data_field])
  mydata.field <- na.omit(mydata.field)
  
  #Assigning maximum number of cluster centers
  if(nrow(unique(mydata.field)) < 10){
    a <- nrow(unique(mydata.field))
  }else {
    a <- 10
  }
  if(a>=nrow(mydata.field)){
    a <- a-1
  }
  
  if(a==0){
    a <- 1
  }
  
  if(a==2){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
    mydata.field$range[mydata.field$mydata.sort...data_field. == max(mydata.field$mydata.sort...data_field.)] <- "MEDIUM"
  }else if(a==1){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
  }else{
    wss <- (nrow(mydata.field)-1)*sum(apply(mydata.field,2,var))
    for (j in 2:a) {
      wss[j] <- sum(kmeans(mydata.field,centers=j)$withinss)
    }
    
    #identifying the knee
    slope <- 1:(length(wss)-1)
    change<-  1:(length(slope)-1)
    change_percent<-  1:(length(slope)-1)
    change[1:length(change)] <- 0
    change_percent[1:length(change)] <- 0
    
    for (j in 1:(length(wss)-1)){
      slope[j] = wss[j+1] - wss[j]
      slope[j] = abs(slope[j])
      
      if(j!=1){
        change[j] = slope[j-1]-slope[j]
        change_percent[j] = (slope[j-1]-slope[j])/slope[j-1]
      }
    }
    
    if(a==3){
      cluster_solution <- a
    }else{
    index = which(change == max(change))
    cluster_solution = index+1
    }
    
    # K-Means Cluster Analysis
    fit <- kmeans(mydata.field, cluster_solution, iter.max = 50)
    # get cluster means 
    aggregate(mydata.field,by=list(fit$cluster),FUN=mean)
    # append cluster assignment
    mydata.field <- data.frame(mydata.field, fit$cluster)
    mydata.field <- na.omit( mydata.field)
    mydata.field$range <- 0

    for(j in 1:nrow(mydata.field)) {
      
      if(j ==1){
        index <- mydata.field$fit.cluster[j]
        mydata.field$range[j] =paste("LOW",round(fit$centers[index],digits=1))
      }
      else{
        if(mydata.field$range[j-1]==paste("LOW",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("LOW",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("MEDIUM",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("HIGH",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("HIGH",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] =  paste("HIGH",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
          }
        }
        else{
          mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
        }
      }
    }
    
  }
  
  #--------------------------Save dataframe----------------------------------#
  
  
  mydata.sort$range <-  mydata.field$range

  
  #Find max/min value for each group
  
  for(j in unique(mydata.sort$range)){
  
    sub_range<- subset(mydata.sort,mydata.sort$range == j)
    mydata.sort$range[mydata.sort$range ==j] <- paste(j, "(",round(min(sub_range[[data_field]]),digits=2), "-", round(max(sub_range[[data_field]]),digits = 2),unit,")")
 
  }
  
  #Output is mydata.sort
  return(mydata.sort)
}

###############################################################################################################
###############################################################################################################
#Using another method of finding elbow (max d)
dataCluster_2 <- function(mydata, data_field, unit){
  require(foreign)
  require(nnet)
  require(reshape2)
  require(effects)
  require(cluster)
  
  mydata.sort <- mydata[order(mydata[[data_field]]),]
  mydata.field <- data.frame(mydata.sort[,data_field])
  mydata.field <- na.omit(mydata.field)
  
  #Assigning maximum number of cluster centers
  if(nrow(unique(mydata.field)) < 7){
    a <- nrow(unique(mydata.field))
  }else {
    a <- 7
  }
  if(a>=nrow(mydata.field)){
    a <- a-1
  }
  
  if(a==2){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
    mydata.field$range[mydata.field$mydata.sort...data_field. == max(mydata.field$mydata.sort...data_field.)] <- "MEDIUM"
  }else if(a==1){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
  }else{
    wss <- (nrow(mydata.field)-1)*sum(apply(mydata.field,2,var))
    for (j in 2:a) {
      wss[j] <- sum(kmeans(mydata.field,centers=j)$withinss)
    }
    
    require("GMD")
    dist.obj <- dist(mydata.field)
    hclust.obj <- hclust(dist.obj)
    css.obj <- css.hclust(dist.obj,hclust.obj)
    elbow.obj <- elbow.batch(css.obj)
    print(elbow.obj)
    
    
    
    
    
    
    
    
    
    
    # K-Means Cluster Analysis
    fit <- kmeans(mydata.field, cluster_solution) # 4 cluster solution
    # get cluster means 
    aggregate(mydata.field,by=list(fit$cluster),FUN=mean)
    # append cluster assignment
    mydata.field <- data.frame(mydata.field, fit$cluster)
    mydata.field <- na.omit( mydata.field)
    mydata.field$range <- 0
    
    for(j in 1:nrow(mydata.field)) {
      
      if(j ==1){
        index <- mydata.field$fit.cluster[j]
        mydata.field$range[j] =paste("LOW",round(fit$centers[index],digits=1))
      }
      else{
        if(mydata.field$range[j-1]==paste("LOW",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("LOW",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("MEDIUM",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("HIGH",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("HIGH",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] =  paste("HIGH",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
          }
        }
        else{
          mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
        }
      }
    }
    
  }
  
  #--------------------------Save dataframe----------------------------------#
  
  
  mydata.sort$range <-  mydata.field$range
  
  
  #Find max/min value for each group
  
  for(j in unique(mydata.sort$range)){
    
    sub_range<- subset(mydata.sort,mydata.sort$range == j)
    mydata.sort$range[mydata.sort$range ==j] <- paste(j, "(",round(min(sub_range[[data_field]]),digits=2), "-", round(max(sub_range[[data_field]]),digits = 2),unit,")")
    
  }
  
  #Output is mydata.sort
  return(mydata.sort)
}

###############################################################################################################
###############################################################################################################
#Partitioning around medoids to estimate the number of clusters using the pamk function in the fpc package.

dataCluster_pam <- function(mydata, data_field, unit){
  require(foreign)
  require(nnet)
  require(reshape2)
  require(effects)
  require(cluster)
  
  mydata.sort <- mydata[order(mydata[[data_field]]),]
  mydata.field <- data.frame(mydata.sort[,data_field])
  mydata.field <- na.omit(mydata.field)
  
  #Assigning maximum number of cluster centers
  if(nrow(unique(mydata.field)) < 7){
    a <- nrow(unique(mydata.field))
  }else {
    a <- 7
  }
  if(a>=nrow(mydata.field)){
    a <- a-1
  }
  
  if(a==2){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
    mydata.field$range[mydata.field$mydata.sort...data_field. == max(mydata.field$mydata.sort...data_field.)] <- "MEDIUM"
  }else if(a==1){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
  }else{
    library(fpc)
    asw <- numeric(20)
    for (k in 2:20)
      asw[[k]] <- pam(mydata.field, k) $ silinfo $ avg.width
    cluster_solution <- which.max(asw)
    
    # K-Means Cluster Analysis
    fit <- kmeans(mydata.field, cluster_solution) # 4 cluster solution
    # get cluster means 
    aggregate(mydata.field,by=list(fit$cluster),FUN=mean)
    # append cluster assignment
    mydata.field <- data.frame(mydata.field, fit$cluster)
    mydata.field <- na.omit( mydata.field)
    mydata.field$range <- 0
    
    for(j in 1:nrow(mydata.field)) {
      
      if(j ==1){
        index <- mydata.field$fit.cluster[j]
        mydata.field$range[j] =paste("LOW",round(fit$centers[index],digits=1))
      }
      else{
        if(mydata.field$range[j-1]==paste("LOW",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("LOW",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("MEDIUM",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("HIGH",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("HIGH",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] =  paste("HIGH",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
          }
        }
        else{
          mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
        }
      }
    }
    
  }
  
  #--------------------------Save dataframe----------------------------------#
  
  
  mydata.sort$range <-  mydata.field$range
  
  
  #Find max/min value for each group
  
  for(j in unique(mydata.sort$range)){
    
    sub_range<- subset(mydata.sort,mydata.sort$range == j)
    mydata.sort$range[mydata.sort$range ==j] <- paste(j, "(",round(min(sub_range[[data_field]]),digits=2), "-", round(max(sub_range[[data_field]]),digits = 2),unit,")")
    
  }
  
  #Output is mydata.sort
  return(mydata.sort)
}

###############################################################################################################
###############################################################################################################
#Using NBCluster

dataCluster_nbclust <- function(mydata, data_field, unit){
  require(foreign)
  require(nnet)
  require(reshape2)
  require(effects)
  require(cluster)
  
  mydata.sort <- mydata[order(mydata[[data_field]]),]
  mydata.field <- data.frame(mydata.sort[,data_field])
  mydata.field <- na.omit(mydata.field)
  
  #Assigning maximum number of cluster centers
  if(nrow(unique(mydata.field)) < 7){
    a <- nrow(unique(mydata.field))
  }else {
    a <- 7
  }
  if(a>=nrow(mydata.field)){
    a <- a-1
  }
  
  if(a==2){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
    mydata.field$range[mydata.field$mydata.sort...data_field. == max(mydata.field$mydata.sort...data_field.)] <- "MEDIUM"
  }else if(a==1){
    mydata.field$range[mydata.field$mydata.sort...data_field. == min(mydata.field$mydata.sort...data_field.)] <- "LOW"
  }else{
    require(NbClust)
    res<-NbClust(mydata.field, distance = "euclidean", min.nc=2, max.nc=8, 
                 method = "complete", index = "ch")
    
    res$All.index
    res$Best.nc
    res$Best.partition
    
    
    
    
    
    
    # K-Means Cluster Analysis
    fit <- kmeans(mydata.field, cluster_solution) # 4 cluster solution
    # get cluster means 
    aggregate(mydata.field,by=list(fit$cluster),FUN=mean)
    # append cluster assignment
    mydata.field <- data.frame(mydata.field, fit$cluster)
    mydata.field <- na.omit( mydata.field)
    mydata.field$range <- 0
    
    for(j in 1:nrow(mydata.field)) {
      
      if(j ==1){
        index <- mydata.field$fit.cluster[j]
        mydata.field$range[j] =paste("LOW",round(fit$centers[index],digits=1))
      }
      else{
        if(mydata.field$range[j-1]==paste("LOW",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("LOW",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("MEDIUM",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] = paste("MEDIUM",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("HIGH",round(fit$centers[index],digits=1))
          }
        }
        else if( mydata.field$range[j-1]==paste("HIGH",round(fit$centers[index],digits=1))){
          if( mydata.field$fit.cluster[j] ==  mydata.field$fit.cluster[j-1]){
            mydata.field$range[j] =  paste("HIGH",round(fit$centers[index],digits=1))
          }
          else{
            index <- mydata.field$fit.cluster[j]
            mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
          }
        }
        else{
          mydata.field$range[j] = paste("VERY HIGH",round(fit$centers[index],digits=1))
        }
      }
    }
    
  }
  
  #--------------------------Save dataframe----------------------------------#
  
  
  mydata.sort$range <-  mydata.field$range
  
  
  #Find max/min value for each group
  
  for(j in unique(mydata.sort$range)){
    
    sub_range<- subset(mydata.sort,mydata.sort$range == j)
    mydata.sort$range[mydata.sort$range ==j] <- paste(j, "(",round(min(sub_range[[data_field]]),digits=2), "-", round(max(sub_range[[data_field]]),digits = 2),unit,")")
    
  }
  
  #Output is mydata.sort
  return(mydata.sort)
}

###############################################################################################################
###############################################################################################################
#Multi-variables cluster

dataCluster_multiVar <- function(mydata, data_field1, data_field2){
  require(foreign)
  require(nnet)
  require(reshape2)
  require(effects)
  require(cluster)
  library(plyr)
  
  mydata.sort <- mydata[order(mydata[[data_field1]],mydata[[data_field2]]),]
  mydata.field <- data.frame(data_field1 =mydata.sort[,data_field1], data_field2 =mydata.sort[,data_field2])
  mydata.field <- na.omit(mydata.field)
  
  #Assigning maximum number of cluster centers
  if(nrow(unique(mydata.field)) < 10){
    a <- nrow(unique(mydata.field))
  }else {
    a <- 10
  }
  if(a>=nrow(mydata.field)){
    a <- a-1
  }
  
 
  wss <- (nrow(mydata.field)-1)*sum(apply(mydata.field,2,var))
  for (j in 2:a) {
    wss[j] <- sum(kmeans(mydata.field,centers=j)$withinss)
  }
    
  #identifying the knee
  slope <- 1:(length(wss)-1)
  change<-  1:(length(slope)-1)
  change_percent<-  1:(length(slope)-1)
  change[1:length(change)] <- 0
  change_percent[1:length(change)] <- 0
  
  for (j in 1:(length(wss)-1)){
    slope[j] = wss[j+1] - wss[j]
    slope[j] = abs(slope[j])
    
    if(j!=1){
      change[j] = slope[j-1]-slope[j]
      change_percent[j] = (slope[j-1]-slope[j])/slope[j-1]
    }
  }
  
  if(a==3){
    cluster_solution <- a
  }else{
    index = which(change == max(change))
    cluster_solution = index+1
  }
    
  # K-Means Cluster Analysis
  fit <- kmeans(mydata.field, cluster_solution, iter.max = 50)
  # get cluster means 
  aggregate(mydata.field,by=list(fit$cluster),FUN=mean)
  # append cluster assignment
  mydata.field <- data.frame(mydata.field, fit$cluster)
  mydata.field <- na.omit( mydata.field)
  
  #Assigning value to groups
  cluster_centers <- data.frame(fit$centers)
  cluster_centers <- data.frame(fit.cluster = row.names(cluster_centers),data_field1=cluster_centers$data_field1, data_field2=cluster_centers$data_field2)
  cluster_centers <- cluster_centers[order(cluster_centers$data_field1),]
  cluster_centers$range <- 0
  range <- c("LOW","MEDIUM","HIGH","VERY HIGH")
  for(i in 1:nrow(cluster_centers)){
    cluster_centers$range[i] <- paste(range[i], "(", round(cluster_centers$data_field1[i],digits = 2),",", round(cluster_centers$data_field2[i],digits = 2),")")
  }

 
  cluster_centers <- data.frame(fit.cluster = cluster_centers$fit.cluster,cluster_centers$range)
  plyr1 <- join(mydata.field, cluster_centers, by = "fit.cluster")
  
    
  
  
  #--------------------------Save dataframe----------------------------------#
  
  
  mydata.sort$range <-  plyr1$cluster_centers.range

  #Output is mydata.sort
  return(mydata.sort)
}

###############################################################################################################