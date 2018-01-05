var buttonGroupBinding = new Shiny.InputBinding();

$.extend(buttonGroupBinding, {
  // Finds all elements with class groupContainer
  find: function(scope) {
  return $(scope).find(".groupContainer");
  },

  // Returns list with selected values. This function will be called on initialisation and when the callback is triggered via       the event bound in subscribe
  getValue: function(el) {

	var inputs      = $(el).find('button');
	var selected    = [];
	var implied     = [];
    var notSelected = [];

	inputs.each(function(){

		var StateSelected     = $(this).hasClass('selected');
		var StateImplied      = $(this).hasClass('implied');
		var SateNotSelected   = !$(this).hasClass('selected') && !$(this).hasClass('implied');
		var Value = $(this).html();

		if(StateSelected){
			selected.push(Value);
		}

		if(StateImplied){
		  implied.push(Value);
		}

		if(SateNotSelected){
		   notSelected.push(Value);
		}

	});

  ID = el.id;

	updateColor(el.id);

	return {selected : selected, implied : implied, notSelected:notSelected};
  },

  // Not implemented by shiny
  setValue: function(el, value) {
    $(el).attr(value);
  },

  // Bind "click" event of the groupContainer control to the shiny callback function
  // This will let shiny server know when a value has changed
  subscribe: function(el, callback) {

  $(el).on("click", function(e) {
      callback();
    });
  },

  // Unbind
  unsubscribe: function(el) {
    $(el).off("buttonGroupBinding");
  },

  // Receive messages from the server.
  // Messages sent by updateMultiSlider() are received by this function.
  receiveMessage: function(el, data) {

  var inputs = $(el).find('button');

  // Reset state of buttongroup
  if(data.reset===true){
    	var values = [];

    	inputs.each(function(){

			var CurrentState        = $(this).hasClass('selected');
			var CurrentImpliedState = $(this).hasClass('implied');
			var Value               = $(this).html();

			// If the current state is not equal to the new state we need to update
			if(!CurrentState){
				console.log("Toggeling current state");
				$(this).toggleClass("selected");
			}

			if(CurrentImpliedState){
			  console.log("Toggeling implied state");
				$(this).toggleClass("implied");
			}

			values.push(Value);
		});

    // Explicitly signal shiny new cleared state
		Shiny.onInputChange(el.id, {selected : values, implied : null});
		updateColor(el.id);
		return;
  }

  // Make sure all items are strings, if the buttongroup happens to only consist of numeric values
  // the class of the data will be numeirc and this will be a problem when comparing to the value of a button
  // as retrieved by Jqeury because this will be a string
  if(typeof(data.selectedItems)=="object"){
    data.selectedItems = data.selectedItems.map(String);
  }else{
    data.selectedItems = "" + data.selectedItems;
  }

  if(typeof(data.impliedItems)=="object"){
    data.impliedItems  = data.impliedItems.map(String);
  }else{
    data.impliedItems = "" + data.impliedItems;
  }

  // Change selection if selected items were supplied
	if(data.selectedItems !== undefined){

			inputs.each(function(){

			var CurrentState = $(this).hasClass('selected');
			var Value = $(this).html();

      var ChangeState = false;

			// If the current state is not equal to the new state we need to update
		  if(typeof(data.selectedItems)==="string"){
		    ChangeState = data.selectedItems == Value != CurrentState;
		  }else{
		    ChangeState = data.selectedItems.indexOf(Value) >= 0 != CurrentState;
		  }

			if(ChangeState){
				$(this).toggleClass("selected");
			}

		});
	}

  // Change selection of implied items when they are supplied
	if(data.impliedItems !== undefined){

			inputs.each(function(){

			var CurrentState = $(this).hasClass('selected');
			var CurrentImpliedState = $(this).hasClass('implied');

			var Value = $(this).html();

      var isImplied = false;


      if(typeof(data.impliedItems)==="string"){
        isImplied = data.impliedItems == Value;
      }else{
        isImplied = data.impliedItems.indexOf(Value) >= 0;
      }

			// If the current state is not equal to the new state we need to update
			var ChangeState = (isImplied && !CurrentImpliedState) ||
							  (!isImplied && CurrentImpliedState) ;

			if(ChangeState){
				$(this).toggleClass("implied");
			}
		});
	}

	updateColor(el.id);

  }
});

Shiny.inputBindings.register(buttonGroupBinding);
