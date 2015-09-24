# library(shinyIncubator)

meth_data_notes <- '<pre>Data Processing Notes:<br>Methylation probes with variation &gt; .01 across all samples were choosen from the normalized data matrix(<a href="https://www.synapse.org/#!Synapse:syn2233188" target="_blank">syn223318</a>). The probes were selected based on genes using a mapping file.(<a href="https://www.synapse.org/#!Synapse:syn2324928" target="_blank">syn2324928</span></a>). Hierarchical clustering was used to cluster rows and columns.</pre>'

#2. mRNA data notes
mRNA_data_notes  <- 'Data Processing Notes:<br>Using mRNA normalized data matrix from <a href="https://www.synapse.org/#!Synapse:syn2701943" target="_blank">syn2701943</a> and metadata from <a href="https://www.synapse.org/#!Synapse:syn2731147" target="_blank">syn2731147</a>. Hierarchical clustering was used to cluster rows and columns.'

#3. miRNA data notes
miRNA_data_notes <- 'Data Processing Notes:<br>Using miRNA normalized data matrix from <a href="https://www.synapse.org/#!Synapse:syn2701942" target="_blank">syn2701942</a> and metadata from <a href="https://www.synapse.org/#!Synapse:syn2731149" target="_blank">syn2731149</a>. The miRNAs were selected based on target genes using a mapping file <a href="https://www.synapse.org/#!Synapse:syn2246991" target="_blank">syn2246991</a>. Hierarchical clustering was used to cluster rows and columns.'

#main UI code

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

myHeader <- dashboardHeader(title="PCBC Data Explorer", disable=TRUE)

mySidebar <- dashboardSidebar(disable=TRUE)

myBody <-dashboardBody(
  fluidRow(
    
    column(width = 9,
           
           # Sample filtering
           fluidRow(height=3,
                    column(width = 9,
                           box(width=NULL, solidHeader=TRUE, status="primary",
                               title = tagList(shiny::icon("filter", lib = "glyphicon"), "Sample filters"),
                               tags$table(class="table table-condensed",
                                          tags$tr(
#                                             tags$td(selectInput('Cell_Line', h6('Cell Line'),
#                                                                 choices=unique(combined_metadata$Cell.line),
#                                                                 selectize=T, multiple=T)),
                                            tags$td(selectInput('Sample_Tissue', h6('Tissue'),
                                                                choices=unique(combined_metadata$Sample.Tissue),
                                                                selectize=T, multiple=T))
#                                             tags$td(selectInput('Blood', h6('Blood'),
#                                                                 choices=unique(combined_metadata$Blood.non.blood),
#                                                                 selectize=T, multiple=T))
                                          ),
                                           tags$tr(
                                             tags$td(selectInput('Sample.Subtissue.location', h6('Subtissue location'),
                                                                 choices=unique(combined_metadata$Sample.Subtissue.location),
                                                                 selectize=T, multiple=T))#,
#                                             tags$td(selectInput('Gender', h6('Gender'),
#                                                                 choices=unique(combined_metadata$Patient.Gender),
#                                                                 selectize=T, multiple=T)),
#                                             tags$td(selectInput('Platform', h6('Platform'),
#                                                                 choices=unique(combined_metadata$Platform),
#                                                                 selectize=T, multiple=T))
                                           )
                               )
                           )
                    ),
                                          
                    column(width = 3,
                           

                           
                           # Information on number of features/samples selected
                           infoBoxOutput("featxsamples", width=NULL)
                    )                
           ),

           

           # Main plot area
          box(width = NULL, solidHeader = TRUE,
               #conditionalPanel("input.show_dt",
                #                DT::dataTableOutput('infotbl')),
               

              plotOutput("heatmap",height=650)
                               
          )
           
    ),
    
    column(width = 3,
           # Choose sample labels
           box(width=NULL, status='primary', collapsible=TRUE, 
               collapsed=TRUE, solidHeader=TRUE,
               title = tagList(shiny::icon("th-list", lib="glyphicon"),
                               "Sample labels"),               
               selectInput('heatmap_annotation_labels',
                           'Annotate Samples by:',
                           # -1 to remove the first value "Sample"
                           #choices=colnames(combined_metadata)[colnames(combined_metadata)!=c("Sample","Sample.ID")],
                           choices=c("Tissue"="Sample.Tissue", "Subtissue Location"="Sample.Subtissue.location"),
                           selected='Sample.Tissue')
           ),
           # Plot selection box
#            box(width = NULL, status = "primary", solidHeader=TRUE,
#                title="Select data to display",
#                selectInput("plotdisplay",
#                            label=NULL, #h6(""),
#                            choices=c("mRNA"),
#                            selectize=T, multiple=F, selected="mRNA"),
#                
#                #checkboxInput('show_dt', 'Show data values instead of heatmap', value = FALSE),
#                
#                uiOutput("plotHelp")               
#            ),
           
           # Searching box
           tabBox(width=NULL, status="info",
                  id="custom_search",
                  # Title can include an icon
                  title = tagList(shiny::icon("search")),
                  tabPanel("Gene",
                           tags$textarea(paste0(sample_gene_list, collapse="\n"),
                                         rows=5, id="custom_input_list", style="width: 100%"),
                           p(class = "text-muted",
                             "Gene symbol (e.g., POU5F1), Ensembl (e.g., ENSG00000204531), or Entrez (e.g., 5460) IDs."),
                           actionButton("refreshGene", "Refresh")),
                  tabPanel("Pathway", 
                           selectInput("selected_pathways", label=NULL,
                                       choices = names(pathways_list),
                                       selectize=T, multiple=F))
                  #tabPanel("miRNA", 
                   #        tags$textarea(paste0(sample_miRNAs, collapse="\n"),
                    #                     rows=5, id="custom_mirna_list", style="width: 100%"),
                     #      p(class = "text-muted",
                      #       "This is an example note in a muted text color."),
                       #    
                        #   actionButton("refreshmiRNA", "Refresh")),
                  
                #  tabPanel("Methylation", 
                 #          tags$textarea(paste0(sample_methyl, collapse="\n"),
                  #                       rows=5, id="custom_methyl_list", style="width: 100%"),
                   #        p(class = "text-muted",
                    #         "This is an example note in a muted text color."),
                     #      actionButton("refreshMethyl", "Refresh"))
           ),
           
           # Correlation box
#           box(width = NULL, status = "warning", solidHeader=TRUE, 
#               collapsible=TRUE, collapsed=TRUE,
#               title = tagList(shiny::icon("plus-sign", lib="glyphicon"), "Correlation"),               
#               conditionalPanel('input.plotdisplay != "mRNA"',
#                                "Not available."),
#                
#               conditionalPanel('input.plotdisplay == "mRNA"',
#                                checkboxInput('incl_corr_genes', 
#                                              'also include correlated genes', 
#                                              value = FALSE),
#                                 
#                                 conditionalPanel(
#                                  condition="input.incl_corr_genes",
#                                  sliderInput('corr_threshold', label=h6('Correlation Threshold'),
#                                              min=0.5, max=1.0, value=0.9, step=0.05),
#                                   correlation direction
#                                  selectInput("correlation_direction",
#                                              label=h6("Correlation Direction"),
#                                              choices=c("both", "positive", "negative"),
#                                              selectize=T, multiple=F, selected="both"),
#                                  p(class = "text-muted",
#                                    br(),
#                                    "This is an example note in a muted text color."
#                                  )
#                                )
#               )
#            ),
           
           # Clustering box
           box(width = NULL, status = "warning", solidHeader=TRUE, 
               collapsible=TRUE, collapsed=TRUE,
               title = tagList(shiny::icon("wrench", lib="glyphicon"), "Clustering"),
               #distance metric
               selectInput("clustering_distance", "Distance Calculation",
                           choices=c("correlation", "euclidean", "maximum", 
                                     "manhattan", "canberra", "binary", "minkowski"),
                           selectize=T, multiple=F, selected="euclidean"),
               
               # set the clustering method
               selectInput("clustering_method", "Clustering Method",
                           choices=c("ward", "single", "complete", "average", 
                                     "mcquitty", "median", "centroid"),
                           selectize=T, multiple=F, selected="average"),
               
               checkboxInput('cluster_cols', 'Cluster the columns', value = TRUE),
               
               checkboxInput('cluster_rows', 'Cluster the rows', value = TRUE)
               
           ),
           
          # Coloring box
#           box(width = NULL, status = "warning", solidHeader=TRUE, 
#               collapsible=TRUE, collapsed=TRUE,
#               title = tagList(shiny::icon("wrench", lib="glyphicon"), "Colors"),
              # select quantiles
#               selectInput("quantile_number", "Quantiles",
#                           choices=c("0-100%"=100,"10-90%"=90,"20-80%"=80,"30-70%"=70,"40-60%"=60,"50-50%"=50),
#                           selectize=T, multiple=F, selected=100),
#                
#               selectInput("color_scheme", "Colors",
#                           choices=c("Red/Yellow/Blue" = "RdYlBu","Spectral",
#                                     "Red/Blue" = "RdBu","Purple/Green"="PRGn","Red/Grey"="RdGy"),
#                           selectize=T, multiple=F, selected="Red/Yellow/Blue"),
              
#               checkboxInput('to_scale', 'Scale', value=FALSE),
#               conditionalPanel(
#                 condition="input.to_scale",
#                 selectInput("scale_by", "Scale by",
#                             choices=c("row","column"),
#                             selectize=T, multiple=F))
#                
#             ),
           
           # Download box
           box(width=NULL, status = 'info', solidHeader=TRUE,
               collapsible=TRUE, collapsed=TRUE,
               title = tagList(shiny::icon("save", lib = "glyphicon"), "Download"),
               selectInput("savetype",
                           label=h6("Save as:"),
                           choices=c("comma separated (CSV)", "tab separated (TSV)"),
                           selectize=F, multiple=F, selected="comma separated (CSV)"),
               downloadButton(outputId='download_data', label='Download')
           )
    )
  )
)

dashboardPage(header=myHeader, sidebar=mySidebar, body=myBody,
              skin = "blue")



# tags$textarea(id="custom_gene_list",
#               rows=8, cols=50,
#               paste0(sample_gene_list, collapse=', ')),
# 
# 
# h5('1.b. Add miRNA Targets (mirbase ids):'),
# tags$textarea(id="custom_miRNA_list",rows=4,cols=50),                 
# 
# actionButton("custom_search", h4("Update")),
# value='custom_gene_list'
#         
# # TAB PANEL 2 : select a pathway
# selectInput("selected_pathways",
#             h5("1.a. Select Pathway/s"),
#             choices = names(pathways_list),
#             selectize=T, multiple=T, width='400px',
#             selected = names(pathways_list)[c(1:2)])
#       
# #Main shiny panel
# plotOutput("mRNA_heatMap",height="700px",width="auto",hoverId=NULL),
# htmlOutput("topgene_linkOut"),
# downloadButton('download_mRNAData','Download mRNA expression data'),
# HTML(mRNA_data_notes)
# plotOutput("microRNA_heatMap",height="700px",width="auto",hoverId=NULL),
# downloadButton('download_miRNAData','Download microRNA expression data'),
# HTML(miRNA_data_notes)
# 
# plotOutput("methylation_heatMap",height="700px",width="auto",hoverId=NULL),
# downloadButton('download_methylationData','Download methylation data'),
# HTML(meth_data_notes)
