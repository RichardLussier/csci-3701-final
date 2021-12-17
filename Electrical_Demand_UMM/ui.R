#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
load(file="Modified_Elec_Demand.rdata")

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Electrical Demand at UMM"),
    
    p("Explore Linear Models of Electrical demand of various UMM buildings during the years 2018-2021. 
      All data is from the University of Minnesota measured using the buildings modbus sensors and can be found ", 
      a(href="https://em-cof.energy.umn.edu/meterreport/", "here"), 
      "."),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("building", "Please select a building:",
                        list("MERC", "Spooner_Hall", "Camden_Hall", "Welcome_Center",
                             "Behmler_Hall", "Blakeley_Hall", "Imholte_Hall",
                             "Education", "Pine_Hall", "Transportation_Garage",
                             "Humanities", "Student_Center", "TMC", "Gay_Hall",
                             "Science_West_Wing", "Science_East_Wing",
                             "Briggs_Library", "Physical_Education",
                             "RFC_Juice_Bar", "Old_Heating_Plant",
                             "Biomass_Heating_Plant", "Heating_Plant_Addition",
                             "Indy_Hall", "Dining_Hall", "Campus_Apartments",
                             "Fine_Arts_Ph1", "Fine_Arts_Ph2", "Physical_Education_RFC",
                             "Transportation_Garage_Storage", "Big_Cat_Stadium",
                             "Transportation_Garage_Recycle_Center", "Green_Prairie"),
                        selected=FALSE),
        
            checkboxGroupInput("explanatory", "Choose up to three explanatory variables:",
                               list("Dry_Bulb", "Wet_Bulb", "Humidity", "Dewpoint",
                                    "Weekday", "Month", "preCOVID", "studentsOnBreak"),
                               selected=list("Dry_Bulb")),
            
            actionButton("generate", "Generate Model")
            ),

        # Show a plot of the generated distribution
        mainPanel(
            verbatimTextOutput("modelPrint"),
            
            plotOutput("distPlot"),
            
            plotOutput("residualPlot"),
            
            
            tags$style(type="text/css",
                       ".shiny-output-error {visibility:hidden;}",
                       ".shiny-output-error:before { visibility:hidden;}")
        )
        
    )
))
