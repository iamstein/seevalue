
logy <- function(plot) {
	plot + xgx_scale_y_log10(breaks= NULL)
}

logx <- function(plot) {
	plot + xgx_scale_x_log10(breaks = NULL) 
}

overlay_logistic_binary <- function(plot) {
	plot +  geom_smooth(method = "glm", method.args = list(family=binomial(link = logit)), color = "black")
}

add_line <- function(plot){
  plot + geom_smooth(method = "lm", formula = "y~x")
}