# Run this first:
#
#    install.packages(c('RSQLite.extfuns', 'ggplot2', 'maps'))
#

library(RSQLite)
#library(ggplot2)
#library(RSQLite.extfuns)
db = dbConnect(
  dbDriver("SQLite")
  , dbname = '/home/dave/ros/misc/src/pr2_benchmarking/results/benchmark.db'
  , loadable.extensions = TRUE)

#dbGetQuery just returns a data frame
#data = dbGetQuery(db, "SELECT id, name, totaltime, timelimit FROM experiments")
data = data = dbGetQuery(db, "SELECT experimentid, plannerid, total_time, solved FROM `planner_OMPL_right_arm[SBLkConfigDefault]`")

#WHERE lic_status = 'CURRENT'
  #AND quantity IS NOT NULL")

summary(data)

#ggplot(data=data) +
#  geom_point(aes(x=geox
#                 , y=geoy
#                 , color=category
#                 , size=quantity))