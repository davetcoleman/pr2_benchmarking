cat(rep("\n",100)) #Clear console

setwd("/home/dave/ros/misc/src/pr2_benchmarking/results/") # Linux Machine
#setwd("/Users/dave/2013/5753_Comp_Perf_Modeling/Final Project/pr2_benchmarking/results") #MacBook Pro

# Read in fresh data  -------------------------------------------------------------------------------------
if(TRUE)
{
  # Reads in experimental data from MoveIt using csv files
  rm(list=ls(all=TRUE))  # clear all vars
  data <- read.csv("benchmark.csv",header=T) 
  #data <- read.csv("archived_csv/7_factor_all_complete.csv",header=T) 
  
  
  # Remove unsolved?  -------------------------------------------------------------------------------------
  #data = data[data$solved==1,]
  good_data = data
  #good_data = data[ grep(" industrial.top_bin_right_01", data$goal_name),]
  
  # Stats on benchmark -------------------------------------------------------------------------------------
  failed_attempts=nrow(data[data$solved==0,])
  total_attempts = nrow(data)
  percent_failed = failed_attempts/total_attempts*100
  
  # Plot planning time of solved problems  -------------------------------------------------------------------------------------
  #data$goal_name = factor(data$goal_name)
  #plot(data$goal_name,data$total_time)
  #plot(data$total_time)
  
  # Create the fitness function ---------------------------------------------------------------------------
  path_plan_lengths = suppressWarnings(as.numeric(levels(good_data$path_plan_length))[good_data$path_plan_length])
  path_plan_times = suppressWarnings(as.numeric(levels(good_data$path_plan_time))[good_data$path_plan_time])
  #fitness_values =  (path_plan_lengths^2)*path_plan_times/100
  fitness_values = path_plan_times*path_plan_lengths
  # Set all NA values to the max value
  fitness_values[is.na(fitness_values)] = max(fitness_values,na.rm = TRUE)
  
  simple_data=data.frame(temp_change     = factor(good_data$param_temp_change_factor), 
                         max_failed      = factor(good_data$param_max_states_failed),
                         range           = factor(good_data$param_range),
                         min_temp        = factor(good_data$param_min_temperature),
                         max_state_fail  = factor(good_data$param_max_states_failed),
                         k_constant      = factor(good_data$param_k_constant),
                         front_threshold = factor(good_data$param_frontier_threshold),
                         front_ratio     = factor(good_data$param_frontier_node_ratio),
                         goal_name       = factor(good_data$goal_name),
                         fitness         = fitness_values);
  
  #hist(simple_data$fitness,breaks=20,main="Fitness Function Analysis")
  summary(simple_data)
  
  # Get list of all goal_names
  goal_names = unique(simple_data$goal_name)
  
  cat("\n----------------------------------------\nStandardization of Fitness Function\n")
  cat(" goal name            \t mean \t std dev \n")
  for(name in goal_names)
  {
    # Get arithmetic? mean and std. dev of this goal type
    subset_data = simple_data$fitness[grep(name,simple_data$goal_name)]
    goal_mean = mean( subset_data )
    goal_sd = sd( subset_data )
    cat(name," \t ", goal_mean, " \t ", goal_sd, "\n")
    
    # standardize (normalize) the data in this goal name
    simple_data$fitness[simple_data$goal_name == name] = ( simple_data$fitness[simple_data$goal_name == name] - goal_mean ) / goal_sd
  }
  
  # Scale fitness value to be all positives
  min_fitness = min(simple_data$fitness,na.rm = TRUE)
  simple_data$fitness[] = simple_data$fitness[] + abs(min_fitness)
}
cat("\n")
print(summary(simple_data$fitness))

# Fitness function among various benchmarks  ---------------------------------------------------------------------------
if(TRUE)
{
  par(mfrow = c(2, 2)) 
  plot(simple_data$goal_name,simple_data$fitness,log="",main="Fitness function distribution between different benchmarks",
       xlab='Benchmarking Problem',ylab='Fitness Function Value')
  plot(simple_data$fitness, simple_data$goal_name,main="Fitness vs Goal Problem")
  hist(simple_data$fitness,breaks=20,main="Fitness Function Analysis")
  #plot(simple_data$temp_change,simple_data$fitness,main="Fitness vs Temp Change",xlab="Temp Change",ylab="Normalized Fitness Function")
  plot(simple_data$max_failed,simple_data$fitness,main="Fitness vs Max Failed",xlab="Max Failed",ylab="Normalized Fitness Function")
}

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

# Fractional-Factor Design of Experiements ---------------------------------------------------------------------------
if(TRUE)
{
  # Linear Model
  model = lm(formula = fitness ~ temp_change+max_failed+range+min_temp+max_state_fail+k_constant+front_threshold+front_ratio,data=simple_data)
  #model = lm(formula = fitness ~ temp_change*max_failed*range*min_temp*max_state_fail*k_constant*front_threshold*front_ratio,data=simple_data)
  #model = lm(formula = fitness ~ temp_change*max_failed,data=simple_data)
  #lines(fitted(model),col="blue") 
  
  cat("\n----------------------------------------\nSummary of Linear Model\n")
  print(summary(model))
  cat("----------------------------------------\n")
  
  # % Variation Attributable to each factor
  an = anova(model)
  print(an)
  percent_of_variation = an[[2]]/sum(an[[2]])*100
  percent_of_variation = format(round(percent_of_variation, 2), nsmall = 2)
  
  # 95% conf interval for max_failed factor
  cat("\n----------------------------------------\nConfidence Intervals:\n")
  print(confint(aov(model)))
  
  cat("\n----------------------------------------\nPercent of Variation:\n")
  variation_table = data.frame(name = row.names(an), percent_variation=percent_of_variation)
  print(variation_table)
  
  # diagnostic plot
  #plot(aov(model))
}



# 3D Plot Relation -----------------------------------------------------------------------------------------
if(FALSE)
{
  library(lattice)
  p = wireframe(fitness ~ temp_change * max_failed, data=simple_data,main="2 Parameter Sweeping - Temp vs Max Change")
  #p <- wireframe(z ~ x * y, data=data)
  npanel <- c(4, 2)
  rotx <- c(-50, -80)
  rotz <- seq(30, 300, length = npanel[1]+1)
  update(p[rep(1, prod(npanel))], layout = npanel,
         panel = function(..., screen) {
           panel.wireframe(..., screen = list(z = rotz[current.column()],
                                              x = rotx[current.row()]))
         })
}




# Final Data Results  ---------------------------------------------------------------------------------------
cat("\nNumber of failed planning attempts:",failed_attempts,"out of",total_attempts," - ",percent_failed,"%\n")