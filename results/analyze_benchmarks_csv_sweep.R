setwd("/home/dave/ros/misc/src/pr2_benchmarking/results/r_results")

# Read in fresh data  -------------------------------------------------------------------------------------
if(TRUE)
{
  # Reads in experimental data from MoveIt using csv files
  rm(list=ls(all=TRUE))  # clear all vars
  data <- read.csv("/home/dave/ros/misc/src/pr2_benchmarking/results/benchmark.csv",header=T) 
  
  # Remove unsolved?  -------------------------------------------------------------------------------------
  #data = data[data$solved==1,]
  good_data = data
  #good_data = data[ grep("top_bin_right", data$goal_name),]
  
  # Stats on benchmark -------------------------------------------------------------------------------------
  failed_attempts=nrow(good_data[good_data$solved==0,])
  total_attempts = nrow(good_data)
  percent_failed = failed_attempts/total_attempts*100
  
  # Plot planning time of solved problems  -------------------------------------------------------------------------------------
  #data$goal_name = factor(data$goal_name)
  #plot(data$goal_name,data$total_time)
  #plot(data$total_time)
  
  # Filter the data ---------------------------------------------------------------------------
  path_plan_lengths = suppressWarnings(as.numeric(levels(good_data$path_plan_length))[good_data$path_plan_length])
  path_plan_times = suppressWarnings(as.numeric(levels(good_data$path_plan_time))[good_data$path_plan_time])
  fitness_values =  (path_plan_lengths^2)*path_plan_times  
  # Change NAs to max value
  fitness_values[is.na(fitness_values)] = max(fitness_values,na.rm = TRUE)
  #fitness_values[fitness_values > 18860] = 18860
  
  simple_data=data.frame(temp_change     = (good_data$param_temp_change_factor), 
                         max_failed      = factor(good_data$param_max_states_failed),
                         range           = (good_data$param_range),
                         min_temp        = factor(good_data$param_min_temperature),
                         max_state_fail  = factor(good_data$param_max_states_fail),
                         k_constant      = factor(good_data$param_k_constant),
                         front_threshold = factor(good_data$param_frontier_threshold),
                         front_ratio     = factor(good_data$param_frontier_node_ratio),
                         goal_name       = factor(good_data$goal_name),
                         fitness         = fitness_values);
  
  #hist(simple_data$fitness,breaks=20,main="Fitness Function Analysis")
  summary(simple_data)
}

# Fitness function among various benchmarks  ---------------------------------------------------------------------------
if(TRUE)
{
  par(mfrow = c(2, 2)) 
  plot(simple_data$goal_name,simple_data$fitness,log="y",main="Fitness function distribution between different benchmarks",
       xlab='Benchmarking Problem',ylab='Fitness Function Value')
  plot(simple_data$fitness, simple_data$max_state_fail,main="Fitness vs Factor")
  #plot(simple_data$fitness, simple_data$temp_change,main="Fitness vs Temp")
}

# Analyze kitchen data seperate  ---------------------------------------------------------------------------
if(FALSE)
{
  kitchen = data[ grep("kitchen.", data$goal_name),]
  summary(kitchen$solved)
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
  #model = lm(formula = fitness ~ temp_change*range,data=simple_data)
  #model = lm(formula = fitness ~ max_state_fail,data=simple_data)
  cat("\n----------------------------------------\nSummary of Linear Model\n")
  print(summary(model))
  cat("----------------------------------------\n")
  
  # % Variation Attributable to each factor
  an = anova(model)
  print(an)
  percent_of_variation = an[[2]]/sum(an[[2]])*100
  
  cat("\n----------------------------------------\nPercent of Variation:\n")
  variation_table = data.frame(name = row.names(an), percent_variation=percent_of_variation)
  print(variation_table)
  
  # 95% conf interval for max_failed factor
  cat("\n----------------------------------------\nConfidence Intervals:\n")
  conf_int = confint(aov(model))
  print(conf_int)
  
  # diagnostic plot
  #plot(aov(model))
}


# 3D Plot Relation -----------------------------------------------------------------------------------------
if(FALSE)
{
  library(lattice)
  p = wireframe(fitness ~ temp_change * range, data=simple_data,main="2 Parameter Sweeping - Temp vs Range")
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

# Testing 3d plot ---------------------------------------------------------------------------------------
if(FALSE)
{
  x = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) #simple_data$temp_change
  y = c(0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) #simple_data$range
  
  mat1 = matrix(seq(1:length(x)*length(y)),length(x),length(y),byrow = TRUE)
  
  for(xi in 1:length(x))
  {
    for(yi in 1:length(y))
    {
      id = (xi-1)*length(x) + yi
      #cat("id=",id," x=",xi," y=",yi," val=",simple_data$fitness[id],"\n")
      mat1[yi,xi] = simple_data$fitness[id]
    }
  }
  z = mat1*100
}
if(FALSE)
{
  library(rgl)
  #data(volcano)
  z <- 10000 * mat1 # Exaggerate the relief
  x <- 10 * (1:nrow(z)) # 10 meter spacing (S to N)
  y <- 10 * (1:ncol(z)) # 10 meter spacing (E to W)
  zlim <- range(y)
  zlen <- zlim[2] - zlim[1] + 1
  colorlut <- terrain.colors(zlen,alpha=0) # height color lookup table
  col <- colorlut[ z-zlim[1]+1 ] # assign colors to heights for each point
  open3d()
  rgl.surface(x, y, z, color=col, alpha=0.75, back="lines")
}


# Final Data Results  ---------------------------------------------------------------------------------------
cat("\nNumber of failed planning attempts:",failed_attempts,"out of",total_attempts," - ",percent_failed,"%\n")