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
library(modelr)

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
    
    
    modelValues <- reactiveValues(building = "none",
                                  numExplanatory = 0,
                                  model = NULL)
    
    
    observeEvent(input$generate, {
        # Save building data
        modelValues$building <- demandData[,input$building]
        
        # Number of explanatory variables(between 1 and 3)
        modelValues$numExplanatory <- length(input$explanatory)
        
        # We always have at least the first explanatory variable
        modelValues$explanatory1 <- demandData[,input$explanatory[1]]
        
        # If there's only one explanatory variable...
        if(modelValues$numExplanatory == 1) {
            # Create the model
            modelValues$model <- lm(modelValues$building[[1]] ~ modelValues$explanatory1[[1]], 
                                   data = demandData, na.action = na.exclude)
            model <- lm(modelValues$building[[1]] ~ modelValues$explanatory1[[1]], 
                        data = demandData, na.action = na.exclude)
            
        # If there's exactly two explanatory variables...
        } else if(modelValues$numExplanatory == 2) {
            # Save the data for the second variable and create the model
            modelValues$explanatory2 <- demandData[,input$explanatory[2]]
            modelValues$model <- lm(modelValues$building[[1]] ~ modelValues$explanatory1[[1]] + modelValues$explanatory2[[1]], 
                                   data = demandData, na.action = na.exclude)
            
        # If there's exactly three explanatory variables...
        } else {
            # Save the data for the other two explanatory variables and create the model
            modelValues$explanatory2 <- demandData[,input$explanatory[2]]
            modelValues$explanatory3 <- demandData[,input$explanatory[3]]
            modelValues$model <- lm(modelValues$building[[1]] ~ modelValues$explanatory1[[1]] + modelValues$explanatory2[[1]] + modelValues$explanatory3[[1]],
                                   data = demandData, na.action = na.exclude)
        }
        
        modelValues$residualData <- as.data.frame(demandData$Date) %>%
            mutate(residualValues = residuals(modelValues$model))
    })
    
    
    # Print the summary of the model
    output$modelPrint <- renderPrint({
        
        summary(modelValues$model)
        
    })
    
    
    output$distPlot <- renderPlot({

        plot(x=modelValues$explanatory1[!is.na(modelValues$building)],
             modelValues$building[!is.na(modelValues$building)])

    })
    
    
    output$residualPlot <- renderPlot({

        ggplot(modelValues$residualData, aes(demandData$Date, residualValues)) +
            geom_ref_line(h=0) +
            geom_line() +
            labs(x="Date", y="Residuals", title="Residual Plot of Model")
        
    })

})
