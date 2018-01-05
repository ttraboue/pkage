#' Creates a button group component
#'
#' @param inputId id for the button group component. The selected groups will be returned to input$inputId
#' @param lstItems list with all items to display in the buttun group
#' @param selectedItems items which will be initialy selected in the button group
#' @param activeColor color for selected items
#' @param inactiveColor color for inactive items
#' @param impliedColor color for the special status 'implied' This status is uesfull in the context of the filter app.
#'        In the filter app there will be multiple button groups and certain selections can imply the absence of items on other groups.
#'
#' @return A button group input control that can be added to a UI definition.
#'
#' @family buttongroup
#'
#' @examples buttonGroup('btnGroup',list('A','B','C'),selectedItems=list('A','B'))
#'
#' @export
buttonGroup <- function(inputId,lstItems,selectedItems=list(),activeColor='green',inactiveColor='light gray',impliedColor='orange',label="",implied.items=list()) {

  addResourcePath(
    prefix = 'wwwBtnGrp',
    directoryPath = system.file('www', package='FrissButtonGroup'))

  nItems <- length(lstItems)

  strHtml <- paste0('<div id="',inputId,'" class="groupContainer">
                    <h5><b>',label,':</b></h5>
                    <div class="btn-group Friss" data-toggle="buttons", style="max-width:100%;border: 1px solid #cccccc;
                    padding: 6px 12px;
                    border-radius: 4px;">')


  for(i in 1:nItems){

      strClass <- '"btn-xs"'

      if(lstItems[i] %in% selectedItems){
        strClass <- '"btn-xs selected"'
      }

      if(lstItems[i] %in% implied.items){
        strClass <- '"btn-xs implied"'
      }

      if(lstItems[i] %in% implied.items && lstItems[i] %in% selectedItems){
        strClass <- '"btn-xs selected implied"'
      }

      strHtml <- paste0(strHtml,
                      '<button type="button" class=',strClass,' onclick="if(!$(this).hasClass(\'implied\')){ $(this).toggleClass(\'selected\')};
                      updateColor(',inputId,');">',lstItems[i],'</button>')
  }

  strHtml <- paste0(strHtml,'</div></div>')

  ###
  ### Change colors dynamically when buttongroup is clicked
  ### This function is called from buttonGroupbinding.js from getValue
  ###
  strHtml <- paste0(strHtml,'<script>

                    function updateColor(inputId) {

                    //$( "#"+inputId + ".groupContainer .btn-group.Friss .btn-xs" ).css( "background-color", "',inactiveColor,'" );
                    //$( "#"+inputId + ".groupContainer .btn-group.Friss .btn-xs.selected" ).css( "background-color", "',activeColor,'" );
                    $( "#"+inputId + ".groupContainer .btn-group.Friss .btn-xs.implied" ).css( "background-color", "',impliedColor,'" );
                    };
                    </script>')

  tagList(
    singleton(tags$head(
      tags$script(src="wwwBtnGrp/buttonGroupBinding.js"),
      tags$link(rel="stylesheet", type="text/css", href="wwwBtnGrp/buttongroupstyle.css"))),
    tags$html(HTML(strHtml))
  )
}

#' Send an update message to a URL input on the client.
#' This update message can change the value and/or label.
#'
#' @param session shiny session object
#' @param inputId Id of the buttongroup to update
#' @param selectedItems items to set the selected status for
#' @param impiedItems items to set the implied status for
#'
#' @family buttongroup
#'
#' @examples updateButtonGroup(session,'btnGroup',selectedItems=list('C'),impliedItems=list('A','B'))
#'
#' @export
updateButtonGroup <- function(session, inputId,
                             selectedItems = NULL,impliedItems=NULL) {

  message <- dropNulls(list(selectedItems = selectedItems,impliedItems = impliedItems))
  session$sendInputMessage(inputId, message)
}

#' Resets a button group to a state where all buttons are selected and non are in implied state
#'
#' @param session shiny session object
#' @param inputId id of the buttongroup
#'
#' @family buttongroup
#'
#' @examples resetButtonGroup(session,'btnGroup')
#'
#' @export
resetButtonGroup <- function(session,inputId){
  message <- dropNulls(list(reset=TRUE))
  session$sendInputMessage(inputId, message)
}

#' Given a vector or list, drop all the NULL items in it
dropNulls <- function(x) {
  x[!vapply(x, is.null, FUN.VALUE=logical(1))]
}
