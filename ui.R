#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


shinyUI(dashboardPage(skin="green",
  dashboardHeader(title = "Tiny Shiny!"), 
    
  #### SIDEBAR ####
  dashboardSidebar(
    
    sidebarUserPanel("by Jonathan Presley", image = 'profesh_photo.jpg'),
    
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("leaf")),
      menuItem("Infographic", tabName = "infographic", icon = icon("image")),
      menuItem("Who's Going Tiny?", tabName = "demographics", icon = icon("users")),
      menuItem("Lifestyle Changes", icon = icon("random"),
        menuSubItem("House Features", tabName = "shelter", icon = icon("home")),
        menuSubItem("Eating", tabName = "food", icon = icon("utensils")),
        menuSubItem("Transportation", tabName = "trans", icon = icon("car-side")),
        menuSubItem("Recycling", tabName = "recycling", icon = icon("recycle")),
        menuSubItem("Purchasing", tabName = "goods", icon = icon("shopping-cart"))
      )
    )
  ), 
  
  #### BODY ####
  dashboardBody(
    tabItems(
      
      ### MAIN PAGE ###
      tabItem(tabName="overview",
              
              ## Description Box Top ##
              fluidRow(
                box(width = 12,
                  h2("Visualizing Ecological Effects of Going Tiny"),
                  tags$p(
                        "The data used in this Shiny web app was derrived from a study by",
                        tags$a(href = "https://biobuild.mlsoc.vt.edu/students/saxton", "Maria Saxton"),
                        ", a Ph.D. candidate in environmental design and planning at Virginia Tech.
                        The study included a survey from 80 participants who downsized to homes under
                        400 square feet and explored the environmental impact of downsizing."
                  ), 
                  tags$p("Environmental impact was measured by the change in the individual's 
                          Ecological Footprint (EF) in global hectares (gha's) as defined by The ",
                         tags$a(href = "https://www.footprintnetwork.org/faq/", "Global Footprint Network"),
                         ".  Saxton's study hopes to bridge gaps of scholarly knowledge on this topic to improve
                         the currently unsustainable building practices in the residential sector."
                  )
                )
              ), 
              
              ## Value Boxes ##
              fluidRow(valueBoxOutput("nBox")%>% 
                         withSpinner(color="#0dc5c1"),
                       valueBoxOutput("avgBox")%>% 
                         withSpinner(color="#0dc5c1"),
                       valueBoxOutput("pavgBox")%>% 
                         withSpinner(color="#0dc5c1")
                       ),
              
              ## Map with components by state ##
              fluidRow(
                box(width=12,
                    plotlyOutput("EFmap", width = "100%")%>% 
                      withSpinner(color="#0dc5c1")
                    )
              ),
              
              ## Boxplot of Components ##
              fluidRow(
                box(
                    plotOutput("boxplot_dc", width = "100%")%>% 
                      withSpinner(color="#0dc5c1"),
                    width = 12
                    )
              )
      ),
      
      
      ### INFOGRAPHIC PAGE ###
      tabItem(tabName="infographic",
              fluidRow(
                box(width=12,
                  h3("Researcher's Infographic of Key Study Findings"),
                  img(src="./Infographic.png", width="100%")
                )
              )
      ),
      
      ### DEMOGRAPHICS PAGE ###
      tabItem(tabName="demographics",
          tabsetPanel(type='tabs',
            
          ## Interactive Bar Chart of Demographics ##
            tabPanel('Demographics',
              # Widget Selection #
              fluidRow(
                box(width = 5,
                      varSelectInput("select_demo_x",
                                     "Select Demographic to Display",
                                     demo_box_2,
                                     width ='100%',
                                     selected = "Age")
                ),
                box(width = 5,
                      varSelectInput('select_demo_fill',
                                     'Subcategorized by',
                                     demo_box_2,
                                     width = '100%',
                                     selected = "Age")
                ),
                box(width = 2,
                    checkboxInput("checkbox", label = "Show as Percentages", value = FALSE)
                )
              ),
              # Bar Chart #
              fluidRow(
                box(width=12,
                    htmlOutput('demographics_bar'),
                    height = 500))),
            
            ## Relocation Visuals ##
            tabPanel('Relocation',
                     fluidRow(
                       tabBox(width=12,
                         # The id lets us use input$tabset1 on the server to find the current tab
                         id = "tabset1", height = "250px",
                         
                         # Sankey Diagram #
                         tabPanel("Sankey", 
                                  h3("Sankey Diagram of Relocations"),
                                  sankeyNetworkOutput("sankey_state", width = "100%", height = 1000) %>% 
                                                      withSpinner(color="#0dc5c1")
                          ),
                         # Map #
                         tabPanel("Map", 
                                  radioButtons("button_state", label = h3("House Location"),
                                             choices = list("Previous" = 1, "Current" = 2), 
                                             selected = 1),
                                  htmlOutput("state_change", width = "100%", height = 500)
                          )
                       )

                     )     
             ),
          
            ## REASON WHY THEY DOWNSIZED ##
            tabPanel('Reason',
                     h2('Why did they go tiny?'),
                     fluidRow(box(width = 12,
                                  plotOutput('reason_cloud', width = "100%")%>% 
                                    withSpinner(color="#0dc5c1"))
                     )
            ),
          
            ## JOBS WORD CLOUDS ##
            tabPanel('Job',
                     h2('Previous and Current Jobs'),
                     fluidRow(box(width = 6,
                                  title = 'Previous Jobs',
                                  plotOutput('jobs_b_cloud')%>% 
                                    withSpinner(color="#0dc5c1")
                                  ),
                              box(width = 6,
                                  title = 'Current Jobs',
                                  plotOutput('jobs_a_cloud')%>% 
                                    withSpinner(color="#0dc5c1"))
                              )
                      )
            )
      ),
      
      
      #### LIFESTYLE CHANGES ####
      tabItem(tabName="shelter",
              fluidRow(
                box(title="Under Construction")
              )
      ),
      
      tabItem(tabName="food",
              fluidRow(
                box(title="Under Construction")
              )
      ),
      
      tabItem(tabName="trans",
              fluidRow(
                box(title="Under Construction")
              )
      ),
      
      tabItem(tabName="recycling",
              fluidRow(
                box(title="Under Construction")
              )
      ),
      
      tabItem(tabName="goods",
              fluidRow(
                box(title="Under Construction")
              )
      )
    )
  )
 )
)

