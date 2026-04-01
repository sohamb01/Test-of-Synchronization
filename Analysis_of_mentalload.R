library(kcpRS); library(tidyverse)
source("Algorithm_3.R")
data("MentalLoad")
X_1<-MentalLoad[1:500, -1]
#X_2<-MentalLoad[451:900, -1]
X_2<-MentalLoad[(1393-500+1):1393, -1]
res<-list()
for(i in 1:2){
  res[[i]]<-SyncBootstage2(X=get(paste0("X_", i)), n=nrow(get(paste0("X_", i))), d=3)
}

distinct_dates<-res[[1]]$indiv_tau[c(3,2)]

common_dates3<-res[[2]]$common_tau+1393-500
common_date4 <- 332
#common_date5 <- 332+341
common_date5 <- 332+341+380 


df <-  cbind(date=1:500, MentalLoad[1:500,-1]) %>% gather(key = "variable", value = "value", -1)

p1<-ggplot(df, aes(x = date, y = value, color = variable)) +
  geom_rect(aes(xmin = common_date4, xmax = 500, ymin = -Inf, ymax = Inf), fill = "grey90", alpha = 0.2, inherit.aes = FALSE) +
  geom_line() +
  facet_grid(rows = vars(variable), , scales = "free_y") +
  geom_vline(data = subset(df, variable == "petCO2"), aes(xintercept = as.numeric(distinct_dates[1])), color = "black", linetype = "dashed") +
  geom_vline(data = subset(df, variable == "RR"), aes(xintercept = as.numeric(distinct_dates[2])), color = "black", linetype = "dashed") +
  #geom_vline(aes(xintercept = as.numeric(common_date4)), color = "black", linetype = "dashed")+
  labs(title = "",
       x = "Time",
       y = "Value") +
  theme_minimal()+
  theme(legend.position = "none", panel.grid = element_blank())+
geom_segment(data = subset(df, variable == "HR"), 
             aes(x = 0, xend = 500, 
                 y =mean(MentalLoad[1:500, 2]), yend = mean(MentalLoad[1:500, 2])),
             color = "grey10") +
  geom_segment(data = subset(df, variable == "petCO2"), 
               aes(x = 0, xend = distinct_dates[1], 
                   y =mean(MentalLoad[1:distinct_dates[1], 4]), yend = mean(MentalLoad[1:distinct_dates[1], 4])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "petCO2"), 
               aes(x = distinct_dates[1], xend = 500, 
                   y =mean(MentalLoad[distinct_dates[1]:500, 4]), yend = mean(MentalLoad[distinct_dates[1]:500, 4])),
               color = "grey10")  +
  geom_segment(data = subset(df, variable == "RR"), 
               aes(x = 0, xend = distinct_dates[2], 
                   y =mean(MentalLoad[1:distinct_dates[2], 3]), yend = mean(MentalLoad[1:distinct_dates[2], 3])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "RR"), 
               aes(x = distinct_dates[2], xend = 500, 
                   y =mean(MentalLoad[distinct_dates[2]:500, 3]), yend = mean(MentalLoad[distinct_dates[2]:500, 3])),
               color = "grey10") 

df <-  cbind(date=894:1393, MentalLoad[894:1393,-1]) %>% gather(key = "variable", value = "value", -1)

p2<-ggplot(df, aes(x = date, y = value, color = variable)) +
  geom_rect(aes(xmin = common_date5, xmax = 1393, ymin = -Inf, ymax = Inf), fill = "grey90", alpha = 0.2, inherit.aes = FALSE) +
  geom_line() +
  facet_grid(rows = vars(variable), , scales = "free_y") +
  #geom_vline(data = subset(df, variable == "petCO2"), aes(xintercept = as.numeric(distinct_dates[1])), color = "black", linetype = "dashed") +
  #geom_vline(data = subset(df, variable == "RR"), aes(xintercept = as.numeric(distinct_dates[2])), color = "black", linetype = "dashed") +
  geom_vline(aes(xintercept = as.numeric(common_date5)), color = "black", linetype = "dashed")+
  labs(title = "",
       x = "Time",
       y = "Value") +
  theme_minimal()+
  theme(legend.position = "none", panel.grid = element_blank())+
  geom_segment(data = subset(df, variable == "HR"), 
               aes(x = 894, xend = common_dates3, 
                   y =mean(MentalLoad[894:common_dates3, 2]), yend = mean(MentalLoad[894:common_dates3, 2])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "HR"), 
               aes(x = common_dates3+1, xend = 1393, 
                   y =mean(MentalLoad[(common_dates3+1):1393, 2]), yend = mean(MentalLoad[(common_dates3+1):1393, 2])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "petCO2"), 
               aes(x = 894, xend = common_dates3, 
                   y =mean(MentalLoad[894:common_dates3, 4]), yend = mean(MentalLoad[894:common_dates3, 4])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "petCO2"), 
               aes(x = common_dates3+1, xend = 1393, 
                   y =mean(MentalLoad[(common_dates3+1):1393, 4]), yend = mean(MentalLoad[(common_dates3+1):1393, 4])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "RR"), 
               aes(x = 894, xend = common_dates3, 
                   y =mean(MentalLoad[894:common_dates3, 3]), yend = mean(MentalLoad[894:common_dates3, 3])),
               color = "grey10") +
  geom_segment(data = subset(df, variable == "RR"), 
               aes(x = common_dates3+1, xend = 1393, 
                   y =mean(MentalLoad[(common_dates3+1):1393, 3]), yend = mean(MentalLoad[(common_dates3+1):1393, 3])),
               color = "grey10") 

p1
p2
