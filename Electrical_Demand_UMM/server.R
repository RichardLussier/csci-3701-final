#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
load(file="Modified_Elec_Demand.rdata")

max_explanatory <- 3
min_explanatory <- 1

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    output$distPlot <- renderPlot({
        
        observe({
            if(length(input$explanatory) > max_explanatory) {
                updateCheckboxGroupInput(session, "explanatory",
                                         selected=tail(input$explanatory,max_explanatory))
            }
            #if(length(input$explanatory) < min_explanatory) {
#updateCheckboxGroupInput(session, "explanatory", selected="Weekday")
            #}
        })

        # generate bins based on input$bins from ui.R
        x    <- demandData[,input$building]

        # draw the histogram with the specified number of bins
        plot(x, y=demandData$Dry_Bulb)

    })

})
