# Reads in experimental data from MoveIt using csv files
rm(list=ls(all=TRUE))  # clear all vars

data <- read.csv("/home/dave/ros/misc/src/pr2_benchmarking/results/benchmark.csv",header=T) 

data$planner_type= factor(data$planner_type)

summary(data)

plot(data$planner_type ~ data$total_time)