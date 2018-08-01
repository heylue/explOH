################################
# Shiny app pour afficher les objets selon le temps
# L. Nahassia, mai 2018
# UI pour explOH_11
################################
library(shiny)
library(leaflet)


#define UI
shinyUI(
  
  dashboardPage(
    skin="black",
    
    #titre
    dashboardHeader(
      title=NULL,
      titleWidth = 0),
    
    dashboardSidebar(
      width=155,
      sidebarMenu(
        menuItem("exploration", tabName="explo_carte", icon = icon("search")),
        menuItem("analyse factorielle", tabName="afc", icon=icon("sort-by-attributes-alt", lib = "glyphicon")),
        menuItem("informations", tabName ="info", icon=icon("info"))
      )
    ),
    
    dashboardBody(
      
      tags$head(tags$link(rel="icon", type="image/png", href="favicon.png"),
                tags$link(rel="stylesheet", type="text/css", href="https://fonts.googleapis.com/css?family=Roboto"),
                tags$link(rel="stylesheet", type="text/css", href="https://fonts.googleapis.com/css?family=Josefin+Sans:400,600,700"),
                tags$script(src ="https://rawgit.com/rowanwins/leaflet-easyPrint/gh-pages/dist/bundle.js"),
                tags$title("explOH"),
                includeCSS("www/style.css")
                #attention pas d'accent dans le css > erreur utf
      ),
      
      useShinyjs(),
      
      tabItems(
        tabItem(tabName="explo_carte",
                #------------------------------- 1. exploration ------------------
                fluidRow(
                  #curseur années
                  box (
                    id="temps_play",
                    width=9,
                    height = 128,
                    # slide temps
                    sliderInput("limites", label="",
                                min=-25, max=2015, value=c(-25, -25), round = 1, step=10, sep=" ",
                                animate = animationOptions(interval=1500))
                  ),#fin curseur années
                  
                  
                  #bornes temporelles
                  box (
                    id="menu_temps",
                    width=3,
                    splitLayout(
                      textInput("borne_temps_1", label ="année min", value = NULL),
                      textInput("borne_temps_2", label="année max", value = NULL)
                    ),
                    actionButton("selec_bornes_temps", label="Appliquer les bornes")
                  )#fin menu bornes temps
                ),#fin fluidRow temps
                
                
                #carte et affichage
                fluidRow(
                  
                  #carte
                  column(
                    id="map_col",
                    width=9,
                    leafletOutput("map", height = "600px")
                  ),#fin carte
                  
                  
                  #affichage
                  box(
                    id="affichage_OH",
                    width=3,
                    title="affichage des OH",
                    #selection valeurs d'usage
                    tags$span("Affichage des différents types d'activités :"),
                    br(),br(),
                    # fonctions à afficher
                    lapply(1:6, function(i) {
                      pickerInput(
                        inputId = paste("picker_vurb", i, sep="_"),
                        # label = liste_vurb[i],
                        choices = liste_vusage[substring(liste_vusage,1,2) < i*10+10 & substring(liste_vusage,1,2) >= i*10],
                        selected = liste_vusage[substring(liste_vusage,1,2) < i*10+10 & substring(liste_vusage,1,2) >= i*10],
                        multiple = TRUE,
                        options = list(
                          `selected-text-format` = "count>-1",
                          `count-selected-text` = paste(liste_vurb[i],"[{0}/{1}]", sep=" "),
                          `actions-box` = TRUE,
                          `deselect-all-text` = "Aucune",
                          `select-all-text` = "Toutes",
                          # `none-Selected-Text` =paste(liste_vurb[i],"(0/{1} activités)", sep=" "),
                          `live-Search` = TRUE,
                          style = paste("btn-",i, sep="")
                        )
                      )
                    } ),#fin sélection valeurs d'usage
                    br(),
                    # couleurs selon fonction, portée ou durée d'existance
                    tags$span("différenciation des OH selon leur :"),
                    radioButtons("couleur_OH", label =NULL,
                                 choices = list("activité" = "v_urb", 
                                                "portée" = "portee",
                                                "fiabilité de l'apparition"="fiab"), 
                                 selected = "v_urb",
                                 inline = TRUE)
                  ), #fin affichage
                  
                  
                  #identification
                  box(
                    id="id_OH",
                    width=3,
                    title="identification des OH",
                    #trouver OF
                    searchInput("selec_OH", 
                                label=NULL,
                                placeholder= "Entrer un n° d'OH à trouver", 
                                btnSearch = icon("search"),
                                btnReset = icon("remove"))
                  )#fin identification
                  
                  
                  
                  
                ), #fin fluidrow carte, affichage, identification
                
                
                fluidRow(
                  #téléchargement
                  box( 
                    id="menu_dl",
                    width=2,
                    title ="téléchargement des OH",
                    downloadButton("downloadData", label="Télécharger les OH"),
                    selectInput("type_dl", "Type de fichier:", choices = c("geojson", "sqlite","csv"))
                  ),#fin téléchargement
                  
                  #tableau OH
                  box(
                    id="tableau_OH",
                    width=10,
                    title="tableau des OH sélectionnés",
                    collapsible = TRUE,
                    collapsed = TRUE,
                    dataTableOutput("tab_OH")
                  )
                )
                
        ),#fin exploration
        
        
        # tags$div(source.signature)
        
        
        #------------------------------ 2. AFC ------------------------
        tabItem(tabName="afc",
                fluidRow(
                  box(
                    id="info_AFC",
                    width=12,
                    solidHeader = TRUE,
                    tags$span("Cet onglet permet d'explorer la structure fonctionnelle et temporelle de l'espace urbain tourangeau à travers des Analyses Factorielles des Correspondances suivie de Classifications Ascendantes Hiérarchiques sur les périodes temporelles. Les AFC sont calculée à partir de tableaux de contingence dénombrant le nombre d'OH selon des périodes temporelles et des caractéristiques fonctionnelles variées. Un commentaire de ces analyses peut être consulté dans le Chapitre 6 de la thèse Nahassia, 2018."),
                    br(),
                    tags$span("Les AFC sont calculées sur toutes les OH disponibles y compris celles n'ayant pas de géométrie (1312 individus)."),
                    br(),br(),
                    tags$span("1. onglets bleus : Choix du tableau de contingence"),br(),
                    tags$span("2. onglets oranges : Résultats de l'AFC - inertie expliquée par chaque axe, graphiques des plans factoriels et tableau des contributions des variables aux axes "),br(),
                    tags$span("3. onglets rouges : CAH sur les périodes (lignes AFC) - dendrogramme, inertie et caractérisation des classes ")
                    
                  )
                ),#fin info AFC ligne 1
                #---- ligne 2 : tableau de contingence ----
                fluidRow( 
                  box(
                    id="choix_periodes",
                    width=4,
                    title= "choix du tableau de contingence",
                    status="primary",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    column(
                      width=6,
                      radioGroupButtons(
                        label="Découpage temporel",
                        inputId="select_periodes",
                        choices=c("tous les 25 ans"="25", 
                                  "tous les 50 ans"="50", 
                                  "tous les 100 ans"="100", 
                                  "par périodes historiques"="exp"),
                        direction="vertical",
                        status="primary",
                        size="sm"
                      )),#fin colonne temp
                    column(
                      width=6,
                      radioGroupButtons(
                        label="Caractéristiques fonctionnelles",
                        inputId="select_var",
                        choices=c("valeurs urbaines"="urb", 
                                  "valeurs d'usage"="usage", 
                                  "portées"="portee"),
                        direction="vertical",
                        status="primary",
                        size="sm"
                      )) #fin colonne var
                  ), #fin choix tableau
                  
                  box(
                    id="affichage_tab_contingence",
                    width=8,
                    title="tableau de contingence",
                    status="primary",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    dataTableOutput("tab_contingence")
                  )# fin tableau de contingence
                ), # fin ligne 2
                #---- ligne 3 : AFC ----
                fluidRow( #ligne 3 AFC
                  box(
                    id="afc",
                    width=12,
                    title="analyse en composante principale",
                    status="warning",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    fluidRow( #ligne 3.1 inertie
                      class="box_interne",
                      box(
                        id="inertie_axes",
                        width=8,
                        title="inertie des axes de l'AFC",
                        collapsible = TRUE,
                        tabBox(
                          id="tabbox_inertie",
                          side="left",
                          width=12,
                          tabPanel(
                            id="tab1",
                            title="Histogramme",
                            plotOutput("plot_inertie_axes",
                                       height = "200px")),
                          tabPanel(
                            id="tab2",
                            title="Tableau",
                            tableOutput("tab_inertie_axes"))
                        )),
                      box(
                        id="choix_axes_biplot",
                        width=4,
                        title="choix des axes à analyser",
                        collapsible = TRUE,
                        pickerInput(
                          inputId = "axe1",
                          label="Choix du premier axe",
                          choices=NULL
                        ),
                        pickerInput(
                          inputId = "axe2",
                          label="Choix du deuxième axe",
                          choices=NULL
                        )
                      )
                    ), #fin ligne 3.1
                    
                    fluidRow(#ligne 3.2 : biplot
                      class="box_interne",
                      box(
                        id="biplot",
                        width=12,
                        title="biplot des axes sélectionnés",
                        collapsible=TRUE,
                        column(
                          width=10,
                          class="plot_AFC",
                          scatterD3Output("plot_biplot",
                                          height = "600px")
                        ),
                        column(
                          width=2,
                          tags$span("Le bouton des paramètres à droite du graphique permet d'accéder aux options (zoom, enregistrement)."),
                          br(), br(),
                          pickerInput(
                            inputId = "masquer_biplot",
                            label="masquer les lignes ou les colonnes :",
                            choices = c("aucune","périodes","caractéristiques fonctionnelles"),
                            selected = "aucune",
                            multiple=FALSE
                          )
                        )
                        
                      )
                      
                    ),#fin ligne 3.2
                    
                    fluidRow( #ligne 3.3. : contributions aux axes
                      class="box_interne",
                      box(
                        id="contributions",
                        width=12,
                        title="contribution des variables aux axes de l'AFC",
                        collapsible=TRUE,
                        column(
                          width=6,
                          class="tab_contrib_AFC",
                          tags$span("Contribution des périodes temporelles"),
                          br(),br(),
                          dataTableOutput("contrib_periodes")
                        ),
                        column(
                          width=6,
                          class="tab_contrib_AFC",
                          tags$span("Contribution des variables fonctionnelles"),
                          br(),br(),
                          dataTableOutput("contrib_variables")
                        )
                      ) #fin box contributions     
                    ) #fin ligne 3.3.
                  )),#fin ligne 3
                #---- ligne 4 : CAH ----
                fluidRow( 
                  box(
                    id="cah",
                    width=12,
                    title="classification ascendante hiérarchique",
                    status="danger",
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    tags$span("Les CAH sont calculées sur les coordonnées des périodes (lignes) sur toutes les axes de l'AFC en distance euclidienne. Le critère d'aggrégation est fait selon la méthode de Ward qui maximise l'inertie interclasse pour chaque regroupement."),
                    br(),br(),
                    box(# ligne 4.2 visualisation dendrogramme et inertie des découpages
                      id="choix_nb_classes",
                      width=12,
                      title="Résultats de la CAH",
                      collapsible = TRUE,
                      plotOutput("plot_dendro"),
                      br(),
                      plotOutput("plot_in_cah",
                                 height = "200px")
                    ),#fin ligne 4.2
                    box(#ligne 4.3 caractérisation des classes
                      id="car_classes",
                      width=12,
                      title="caractérisation des classes chronologiques",
                      footer="Chaque classe chronologique est caractérisée par son profil fonctionnel (par valeurs urbaines), en écarts à l'indépendance (/développer/).",
                      collapsible = TRUE,
                      fluidRow(
                        column(#ligne 4.3.1 choix et frise
                          id="tab_periodes_classes",
                          width=2,
                          pickerInput(
                            inputId = "nombre_classes",
                            label="Nombre de classes à conserver :",
                            choices = NULL,
                            multiple=FALSE,
                            width="auto",
                            options=list(size=10)
                          )
                        ),
                        column(
                          id="graph_frise_classes",
                          width=10,
                          plotOutput("frise_classes",
                                     height = "110px")
                        )),#fin ligne 4.3.1
                      #ligne 4.3.2 plot des classes
                      plotOutput("plot_classes")  
                    )#fin ligne 4.3
                    
                  ))#fin ligne 4 
                
        ), #fin tabAFC
        
        #------------------------------- 3. INFO ------------------
        
        tabItem(tabName="info",
                fluidRow( 
                  column(6, source.info),
                  column (6, source.usage)
                )
        )
      ) #fin tabItems
      
    )
    
  )
  
)


