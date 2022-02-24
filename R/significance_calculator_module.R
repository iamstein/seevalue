library(shiny)

significance_calculator_ui <- function(id) {
	ns <- NS(id)
	div(
      h3("Calculate Lineup Significance"),
      p("This module will calculate the 'see'-value of the lineup test performance of the team. This value is analogous to a p-value of a traditional lineup, representing the probability that you saw this many team members correctly pick out the data if it was generated under the null hypothesis."),
      numericInput(ns("total_participants"), "Total Participants Performing Lineup Test", 1, 1),
      numericInput(ns("correct_participants"), "# of Participants Correctly Identifying Data", 1, 1),
      uiOutput(ns("calculated_p_value")),
      uiOutput(ns("p_value_explanation"))
	)
}


get_significance <- function(total, correct, lineup_size = 20) {
	p_choosen <- 1 / lineup_size
	pbinom(correct, total, p_choosen, lower.tail = FALSE) + dbinom(correct, total, p_choosen)
}


get_significance_explanation <- function(total, correct) {
	div(
		br(),
		p(paste0("You indicated that ", total, " participants were shown a lineup, of which ", correct, " correctly identified your data. ",
			"If there was nothing special about your data, you would expect that any given participant would have a 5% chance of picking the data out of the lineup ",
			"(since under the null hypothesis, it is indistinguishable from 19 other generated plots). Thus, under the null hypothesis, the number of team members identifying ",
			"the data would be binomially distributed, with ", total, " trials and a probability of 0.05 of a correct response on each trial. Thus the 'see'-value is the probability ",
			"of a random variable X~Binom(",total,"0.05) taking on a value greater than ", correct, ":")),

		p(paste0("'see'-value = P(X >=", correct,")=",get_significance(total, correct))),
		br(),
		p("Based on your desired power, you can decide if this implies you have a significant result or not.")
	)
}

significance_calculator_server <- function(input, output, session) {
	output$calculated_p_value <- renderUI({h2(paste0("'See'-Value: ", get_significance(input$total_participants, input$correct_participants)))})
	output$p_value_explanation <- renderUI({get_significance_explanation(input$total_participants, input$correct_participants)})
}
	
