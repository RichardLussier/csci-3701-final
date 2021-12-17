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
min_explanatory <- 1

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    observe({
        if(length(input$explanatory) > max_explanatory) {
            updateCheckboxGroupInput(session, "explanatory",
                                     selected=tail(input$explanatory,max_explanatory))
        }
        
        if(length(input$explanatory) < min_explanatory) {
            updateCheckboxGroupInput(session, "explanatory",
                                     selected="Dry_Bulb")
        }
    })
    
    
    modelValues <- reactiveValues(building = "MERC",
                                  numExplanatory = 1,
                                  explanatory = "Dry_Bulb")
    
    
    observeEvent(input$generate, {
        # Save building data
        modelValues$building <- demandData[,input$building]
        
        modelValues$explanatory <- input$explanatory
        
        modelValues$onlyCategorical <- input$explanatory[1] %in% c("Weekday", "Month", "preCOVID", "studentsOnBreak")
        
        # Number of explanatory variables(between 1 and 3)
        modelValues$numExplanatory <- length(input$explanatory)
        
        # We always have at least the first explanatory variable
        modelValues$explanatory1 <- demandData[,input$explanatory[1]]
        
        # Add first explanatory variable to data frame for plotting
        modelValues$plotData <- as.data.frame(modelValues$building) %>%
            mutate(explanatory1 = modelValues$explanatory1[[1]])
        
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
            
            # And add the second explanatory variable's data to data frame for plotting
            modelValues$plotData <- modelValues$plotData %>%
                mutate(explanatory2 = modelValues$explanatory2[[1]])
            
        # If there's exactly three explanatory variables...
        } else {
            # Save the data for the other two explanatory variables and create the model
            modelValues$explanatory2 <- demandData[,input$explanatory[2]]
            modelValues$explanatory3 <- demandData[,input$explanatory[3]]
            modelValues$model <- lm(modelValues$building[[1]] ~ modelValues$explanatory1[[1]] + modelValues$explanatory2[[1]] + modelValues$explanatory3[[1]],
                                   data = demandData, na.action = na.exclude)
            
            # And add the second/third explanatory variables' data to data frame for plotting
            modelValues$plotData <- modelValues$plotData %>%
                mutate(explanatory2 = modelValues$explanatory2[[1]]) %>%
                mutate(explanatory3 = modelValues$explanatory3[[1]])
        }
        
        modelValues$plotData <- modelValues$plotData %>%
            mutate(predictions = predict(modelValues$model))
        
        modelValues$residualData <- as.data.frame(demandData$Date) %>%
            mutate(residualValues = residuals(modelValues$model))
    })
    
    
    # Print the summary of the model
    output$modelPrint <- renderPrint({
        
        summary(modelValues$model)
        
    })
    
    
    output$distPlot <- renderPlot({
        
        ourPlot <- ggplot(modelValues$plotData, aes(x=explanatory1, y=modelValues$building[[1]])) +
            labs(x=input$explanatory[1], y=input$building, title="Plot of Model")
            
        if(modelValues$onlyCategorical) {
            
            if(modelValues$numExplanatory == 1) {
                
                ourPlot <- ourPlot +
                    geom_boxplot()
                
            } else if(modelValues$numExplanatory == 2) {
                
                ourPlot <- ourPlot +
                    geom_boxplot(aes(colour = explanatory2))
                
            } else if(modelValues$numExplanatory == 3) {
                
                ourPlot <- ourPlot +
                    geom_boxplot(aes(colour = factor(explanatory2), shape = factor(explanatory3)))
            }
            
        } else {
        
            if(modelValues$numExplanatory == 1) {
            
                ourPlot <- ourPlot +
                    geom_point() +
                    geom_smooth(method="lm", formula=y~x, se=FALSE)
                
            } else if(modelValues$numExplanatory == 2) {
                
                ourPlot <- ourPlot +
                    geom_point(aes(colour = explanatory2)) +
                    geom_line(aes(y=predictions, colour=explanatory2))
                
            } else if(modelValues$numExplanatory == 3) {
                
                ourPlot <- ourPlot +
                    geom_point(aes(colour = factor(explanatory2), shape = factor(explanatory3))) + 
                    geom_line(aes(y=predictions, colour=factor(explanatory2), linetype=explanatory3))
            }
            
        }

        ourPlot
    })
    
    
    output$residualPlot <- renderPlot({

        ggplot(modelValues$residualData, aes(demandData$Date, residualValues)) +
            geom_ref_line(h=0) +
            geom_line() +
            labs(x="Date", y="Residuals", title="Residual Plot of Model")
        
    })

})
