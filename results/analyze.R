# Run this first:
#
#    install.packages(c('RSQLite.extfuns', 'ggplot2', 'maps'))
#

library(RSQLite)
#library(ggplot2)
#library(RSQLite.extfuns)
db = dbConnect(
  dbDriver("SQLite")
  , dbname = '/opt/dcoleman/ros/misc/src/pr2_benchmarking/results/benchmark.db'
  , loadable.extensions = TRUE)

#dbGetQuery just returns a data frame
pods = dbGetQuery(db, "SELECT id, name, totaltime, timelimit
                       FROM experiments")

#WHERE lic_status = 'CURRENT'
  #AND quantity IS NOT NULL")

summary(pods)

#ggplot(data=pods) +
#  geom_point(aes(x=geox
#                 , y=geoy
#                 , color=category
#                 , size=quantity))