# Run this first:
#
#    install.packages(c('RSQLite.extfuns', 'ggplot2', 'maps'))
#

library(RSQLite)
library(ggplot2)
library(RSQLite.extfuns)
db = dbConnect(
  dbDriver("SQLite")
  , dbname = 'watershed_database.db'
  , loadable.extensions = TRUE)

#dbGetQuery just returns a data frame
pods = dbGetQuery(db, "
SELECT category, subbasin_name, quantity, geox, geoy
FROM pods
WHERE lic_status = 'CURRENT'
  AND quantity IS NOT NULL")

summary(pods$quantity)

ggplot(data=pods) +
  geom_point(aes(x=geox
                 , y=geoy
                 , color=category
                 , size=quantity))