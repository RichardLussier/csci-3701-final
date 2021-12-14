#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

load(file="Modified_Elec_Demand.rdata")

max_explanatory <- 3

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    observe({
        if(length(input$explanatory) > max_explanatory) {
            updateCheckboxGroupInput(session, "explanatory",
                                     selected=tail(input$explanatory,max_explanatory))
        }
    })
    
    
    modelValues  <- reactiveValues(building = "none",
                                   explanatory = NULL,
                                   numExplanatory = 0,
                                   model = NULL)
    
    observeEvent(input$generate, {
        modelValues$building <- demandData[,input$building]
        modelValues$numExplanatory <- length(input$explanatory)
        if(modelValues$numExplanatory == 1) {
            modelValues$explanatory <- demandData[,input$explanatory]
            modelValues$model = lm(input$building ~ input$explanatory, data = demandData)
        }
    })
    
    output$modelPrint <- renderPrint({
        
        summary(modelValues$model)
        
    })
    
    output$distPlot <- renderPlot({

        plot(x=modelValues$explanatory[!is.na(modelValues$building)],
             modelValues$building[!is.na(modelValues$building)])

    })

})
