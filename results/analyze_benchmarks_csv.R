# Reads in experimental data from MoveIt using csv files
rm(list=ls(all=TRUE))  # clear all vars
setwd("/home/dave/ros/misc/src/pr2_benchmarking/results/r_results")

data <- read.csv("/home/dave/ros/misc/src/pr2_benchmarking/results/benchmark.csv",header=T) 
good_data = data #[data$solved==1,]

# Filter the data ---------------------------------------------------------------------------
path_plan_lengths = suppressWarnings(as.numeric(levels(good_data$path_plan_length))[good_data$path_plan_length])
path_plan_times = suppressWarnings(as.numeric(levels(good_data$path_plan_time))[good_data$path_plan_time])
fitness_values =  path_plan_lengths + path_plan_times
fitness_values[is.na(fitness_values)] = 50

simple_data=data.frame(temp_change = factor(good_data$param_temp_change_factor), max_failed= factor(good_data$param_max_states_failed),
                       fitness = fitness_values)


#data$planner_type= factor(data$planner_type)
#summary(data$total_time)

# Stats on benchmark -------------------------------------------------------------------------------------
failed_attempts=nrow(data[data$solved==0,])
total_attemps = nrow(data)
cat("Number of failed planning attempts:",failed_attempts,"out of",total_attemps," - ",failed_attempts/total_attemps*100,"%")

# Total planning time vs different tests ---------------------------------------------------------------------------
if(FALSE)
{
  library(lattice)
  #jpeg("total_planning_time_vs_tests.jpg")
  myplot = plot(data$goal_name, data$total_time, main="Total Planning time of Unoptimized RRT\nOn MoveIt Benchmarking Set 1.0", 
                xaxt = "n",  xlab = "", ylab="Total Planning Time")
  ## Increase bottom margin to make room for rotated labels
  #par(mar = c(7, 4, 4, 4) + 1.0)
  par(mar = c(7, 4, 4, 2) + 1.1)
  ## Set up x axis with tick marks alone
  axis(1, labels = FALSE)
  ## Create some text labels
  labels = myplot$names
  ## Plot x axis labels at default tick marks
  text(1:length(labels), par("usr")[3] - 0.15, srt = 45, adj = 1, labels = labels, xpd = TRUE)
  ## Plot x axis label at line 6 (of 7)
  mtext(1, text = "Scene + Goal Query", line = 7)
  #dev.off()
}


# 2-Factor Design of Experiements ---------------------------------------------------------------------------
if(TRUE)
{
  simple_data$temp_change = factor(simple_data$temp_change)
  simple_data$max_failed = factor(simple_data$max_failed)

  # Linear Model
  model = lm(formula = fitness ~ temp_change + max_failed,data=simple_data)
  summary(model)
  
  # % Variation Attributable to each factor
  an = anova(model)
  print(an)
  an[[2]]/sum(an[[2]])*100
  
  # 95% conf interval for max_failed factor
  confint(aov(model))
  
  # diagnostic plot
  plot(aov(model))
}





