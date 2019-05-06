#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



shinyServer(function(input, output, session){
  
  #### MAIN PAGE ITEMS ####
  ### VALUE BOXES
  output$nBox <- renderValueBox(
    valueBox(80,
            '# Participants',
            icon = icon("users"), 
            color = "green"
            )
  )
  
  output$avgBox <- renderValueBox(
    valueBox(paste(round(100*mean(as.numeric(tiny_data$footprint.delta)/mean(as.numeric(tiny_data$previous.ecological.footprint))), 2), "%"),
             "Average Total EF Reduction",
            icon = icon("arrow-down"),
            color = "green"
            )
  )

  output$pavgBox <- renderValueBox(
    valueBox(paste(round(mean(as.numeric(tiny_data$previous.ecological.footprint)), 2), "gha's"),
             "Previous Average Footprint (US avg = 8.4)",
             icon = icon("balance-scale"),
             color = "green"
            )
  )
  
    ### MAP USING PLOTLY
    output$EFmap <- renderPlotly({
      #add hover text column
      ef_by_state$hover <- with(ef_by_state, paste('Food:', round(food_delta_mean, 2), '<br>', 
                                                   'Shelter:', round(shelter_delta_mean, 2), '<br>',
                                                   'Transportation:', round(transportation_delta_mean, 2), '<br>', 
                                                   'Goods:', round(goods_delta_mean, 2), '<br>',
                                                   'Services:', round(services_delta_mean, 2), '<br>',
                                                   'n= ', cnt_participants))
      # give state boundaries a white border
      l <- list(color = toRGB("white"), width = 1)
      # specify some map projection/options
      g <- list(
        scope = 'usa',
        projection = list(type = 'albers usa'),
        showlakes = TRUE,
        lakecolor = toRGB('white')
      )
      #map object
      EFmap <- plot_geo(ef_by_state, locationmode = 'USA-states') %>%
        add_trace(
          z = ~footprint_delta_mean,
          text = ~hover,
          color = ~footprint_delta_mean,
          colors = 'Greens',
          locations = ~current.state,
          marker = list(line = l)) %>%
        colorbar(title = "(global hectares/person)", thickness = 20,
                 len = 0.5, x = 1) %>%
        layout(title = 'Average Ecological Footprint Reduction of Tiny Home Owners by State',
               geo = g)
    })
    
    
    ### OVERALL BOX PLOT
    output$boxplot_dc <- renderPlot(
      expr = ef_deltas %>%
        select(., food, shelter, transportation, goods, services) %>%
        gather(., key = 'Category', value = 'Change_in_Value', 1:5) %>%
        ggplot(., aes(x= reorder(Category, Change_in_Value), y = Change_in_Value, fill = Category)) +
        geom_boxplot(title = "Change in Ecological Footprint by Category") +
        xlab("Category") +
        ylab("Change in EF (gha's)") +
        ggtitle("Change in Ecological Footprint by Category") +
        theme_bw() +
        theme(legend.position = "none")
    )
    
      #### DEMOGRAPHICS ITEMS ####
      ### BAR GRAPH
      output$demographics_bar <- renderGvis({
       #googlevis bar chart chages depending on the variables chosen by user
         if(input$select_demo_x==input$select_demo_fill) {
            demo_box_1 %>%
               group_by(!!input$select_demo_x) %>%
               count() %>%
               gvisBarChart(., 
                            xvar =as.character(input$select_demo_x), 
                            options = list(isStacked = ifelse(input$checkbox == TRUE, "percent", TRUE),
                                           legend = "bottom", 
                                           height = 500))
         } else {
            demo_box_1 %>%
              group_by(!!input$select_demo_x, !!input$select_demo_fill) %>%
              count() %>%
              spread(., key = !!input$select_demo_fill, value = n) %>%
              gvisBarChart(., 
                           xvar = as.character(input$select_demo_x), 
                           options = list(isStacked = ifelse(input$checkbox == TRUE, "percent", TRUE),
                                          legend = "bottom",
                                          height = 500))
         }
    })
    
      ### WORD CLOUDS
      output$reason_cloud <- renderPlot({
       wordcloud(words = rc_d$word, freq = rc_d$freq, min.freq = 1,
                 max.words=200, random.order=FALSE, rot.per=0.35,
                 colors=brewer.pal(8, "Dark2"))
     })
      output$jobs_b_cloud <- renderPlot({
        wordcloud(words = jcp_d$word, freq = jcp_d$freq, min.freq = 1,
                  max.words=200, random.order=FALSE, rot.per=0.35, 
                  colors=brewer.pal(8, "Dark2"))
      })
      output$jobs_a_cloud <- renderPlot({
        wordcloud(words = jca_d$word, freq = jca_d$freq, min.freq = 1,
                  max.words=200, random.order=FALSE, rot.per=0.35, 
                  colors=brewer.pal(8, "Dark2"))
      })
      ### STATE CHANGE MAPS
      output$state_change <- renderGvis({
        if (as.character(input$button_state)== '1') {
          pstate_map <- gvisGeoChart(pstate, "previous.state", "count",
                                     options=list(region="US",
                                                  displayMode="regions", 
                                                  resolution="provinces",
                                                  width=600, height=400))
        } else {
          cstate_map <- gvisGeoChart(cstate, "current.state", "count",
                                     options=list(region="US",
                                                  displayMode="regions", 
                                                  resolution="provinces",
                                                  width=600, height=400)) 
        }
      })
      ### SANKEY DIAGRAM 
      output$sankey_state <- renderSankeyNetwork({
        sankeyNetwork(Links = links_state, Nodes = nodes_state,
                      Source = "IDsource", Target = "IDtarget",
                      Value = "value", NodeID = "name", 
                      sinksRight=TRUE)
      })
    
})
