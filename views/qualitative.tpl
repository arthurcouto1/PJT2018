%include('header_init.tpl', heading='Manage your qualitative attributes')

<br />
<br />

<h2 style="display:inline-block; margin-right: 40px;">Delete all attributes: </h2>
<button type="button" class="btn btn-default del_simu">Delete</button>

<h2>List of current attributes:</h2>
<table class="table">
    <thead>
        <tr>
            <th style='width:50px;'>State</th>
            <th>Attribute name</th>
            <th>Values</th>
            <th>Method</th>
            <th>Mode</th>
            <th>Edit</th>
            <th><img src='/static/img/delete.ico' style='width:16px;' class="del_simu" /></th>
        </tr>
    </thead>
    <tbody id="table_attributes">
    </tbody>
</table>

<br /><br />

<div id="add_attribute">
    <h2> Add a new qualitative attribute: </h2>

    <div class="form-group">
        <label for="att_name">Name :</label>
        <input type="text" class="form-control" id="att_name" placeholder="Name">
    </div>

    <div class="form-group">
        <label for="att_value_min">Min value:</label>
        <input type="text" class="form-control" id="att_value_min" placeholder="Value">
    </div>
	
    <div class="form-group">
        <label for="att_value_max">Max value:</label>
        <input type="text" class="form-control" id="att_value_max" placeholder="Value">
    </div>
	
    <div class="form-group">
        <label for="att_method">Method:</label>
        <select class="form-control" id="att_method">
          <option value="PE">Probability Equivalence</option>
          <!-- <option value="CE_Constant_Prob">Certainty Equivalence - Constant Probability</option>
		  <option value="CE_Variable_Prob">Certainty Equivalence - Variable Probability</option>
          <option value="LE">Lottery Equivalence</option> -->
        </select>
    </div>
	
    <!-- 
	<div class="checkbox">
        <label><input name="mode" type="checkbox" id="att_mode" placeholder="Mode"> The min value is preferred (decreasing utility function)</label>
    </div>
	-->

    <button type="submit" class="btn btn-default" id="submit">Submit</button>

</div>

%include('header_end.tpl')
%include('js.tpl')

<script>
    $(function() {

        $('#edit_attribute').hide();

        $('.del_simu').click(function() {
            if (confirm("Are you sure ?") == false) {
                return
            };
            localStorage.clear();
            window.location.reload();
        });
        $('li.manage').addClass("active");

        var assess_session_QUALI = JSON.parse(localStorage.getItem("assess_session_QUALI"));
        var edit_mode = false;
        var edited_attribute=0;

        if (!assess_session_QUALI) {
            assess_session_QUALI = {
                "attributes": [],
                "k_calculus": [{
                    "method": "multiplicative",
                    "active": "false",
                    "k": [],
                    "GK": null,
                    "GU": null
                }, {
                    "method": "multilinear",
                    "active": "false",
                    "k": [],
                    "GK": null,
                    "GU": null
                }],
                "settings": {
                    "decimals_equations": 3,
                    "decimals_dpl": 8,
                    "proba_ce": 0.3,
                    "proba_le": 0.3,
                    "language": "english",
                    "display": "trees"
                }
            };
            localStorage.setItem("assess_session_QUALI", JSON.stringify(assess_session_QUALI));
        }

        function isAttribute(name) {
            for (var i = 0; i < assess_session_QUALI.attributes.length; i++) {
                if (assess_session_QUALI.attributes[i].name == name) {
                    return true;
                }
            }
            return false;
        }

        function checked_button_clicked(element) {
            var checked = $(element).prop("checked");
            var i = $(element).val();

            //we modify the propriety
            var assess_session_QUALI = JSON.parse(localStorage.getItem("assess_session_QUALI"));
            assess_session_QUALI.attributes[i].checked = checked;

            //we update the assess_session_QUALI storage
            localStorage.setItem("assess_session_QUALI", JSON.stringify(assess_session_QUALI));
        }

        function sync_table() {
            $('#table_attributes').empty();
            if (assess_session_QUALI) {
                for (var i = 0; i < assess_session_QUALI.attributes.length; i++) {
                    var attribute = assess_session_QUALI.attributes[i];
                    var text_table = "<tr>";
                    
					if (attribute.checked)
                        text_table += '<td><input type="checkbox" id="checkbox_' + i + '" value="' + i + '" name="' + attribute.name + '" checked></td>';
                    else
                        text_table += '<td><input type="checkbox" id="checkbox_' + i + '" value="' + i + '" name="' + attribute.name + '" ></td>';



                    text_table += '<td>' + attribute.name + '</td>' +
								  '<td><ul><li>' + attribute.val_min + '</li>'+
								  '<li>' + attribute.val_max + '</li></td>'+
								  '<td>' + attribute.method + '</td>'+
								  '<td>' + attribute.mode + '</td>';
								  
                    text_table += '<td><button type="button" id="edit_' + i + '" class="btn btn-default btn-xs">Edit</button></td>'+
								  '<td><img id="deleteK' + i + '" src="/static/img/delete.ico" style="width:16px;"/></td></tr>';

                    $('#table_attributes').append(text_table);

                    //we will define the action when we click on the check input
                    $('#checkbox_' + i).click(function() {
                        checked_button_clicked($(this))
                    });

                    (function(_i) {
                        $('#deleteK' + _i).click(function() {
                            if (confirm("Are you sure ?") == false) {
                                return
                            };
                            assess_session_QUALI.attributes.splice(_i, 1);
                            // backup local
                            localStorage.setItem("assess_session_QUALI", JSON.stringify(assess_session_QUALI));
                            //refresh the page
                            window.location.reload();
                        });
                    })(i);

                    (function(_i) {
                        $('#edit_' + _i).click(function() {
                          edit_mode=true;
                          edited_attribute=_i;
                          var attribute_edit = assess_session_QUALI.attributes[_i];
                          $('#add_attribute h2').text("Edit attribute "+attribute_edit.name);
                          $('#att_name').val(attribute_edit.name);
                          $('#att_unit').val(attribute_edit.unit);
                          $('#att_value_min').val(attribute_edit.val_min);
                          $('#att_value_max').val(attribute_edit.val_max);
                          $('#att_method option[value='+attribute_edit.method+']').prop('selected', true);
                          if (attribute_edit.mode=="normal") {
                            $('#att_mode').prop('checked', false);
                          } else {
                            $('#att_mode').prop('checked', true);
                          }
                        });
                    })(i);
                }

            }
        }
        sync_table();

        var name = $('#att_name').val();

        $('#submit').click(function() {
            var name = $('#att_name').val(),
				val_min = parseInt($('#att_value_min').val()),
				val_max = parseInt($('#att_value_max').val());

            var method = "PE";
            <!-- if ($("select option:selected").text() == "Probability Equivalence") { -->
                <!-- method = "PE"; -->
            <!-- } else if ($("select option:selected").text() == "Lottery Equivalence") { -->
                <!-- method = "LE"; -->
            <!-- } else if ($("select option:selected").text() == "Certainty Equivalence - Constant Probability") { -->
                <!-- method = "CE_Constant_Prob"; -->
            <!-- } else if ($("select option:selected").text() == "Certainty Equivalence - Variable Probability") { -->
                <!-- method = "CE_Variable_Prob"; -->
            <!-- } -->

            if ($('input[name=mode]').is(':checked')) {
                var mode = "reversed";
            } else {
                var mode = "normal";
            }

            if (!(name || unit || val_min || val_max) || isNaN(val_min) || isNaN(val_max)) {
                alert('Please fill correctly all the fields');
            }
            else if (isAttribute(name) && (edit_mode == false)) {
              alert ("An attribute with the same name already exists");
            }
            else if (val_min > val_max) {
              alert ("Minimum value must be inferior to maximum value");
            }

            else {
              if (edit_mode==false) {
                assess_session_QUALI.attributes.push({
                    "name": name,
                    'unit': unit,
                    'val_min': val_min,
                    'val_max': val_max,
                    'method': method,
                    'mode': mode,
                    'completed': 'False',
                    'checked': true,
                    'questionnaire': {
                        'number': 0,
                        'points': [],
                        'utility': {}
                    }
                });
              } else {
                if (confirm("Are you sure you want to edit this attribute? All assessements will be deleted") == true) {
                  assess_session_QUALI.attributes[edited_attribute]={
                    "name": name,
                    'unit': unit,
                    'val_min': val_min,
                    'val_max': val_max,
                    'method': method,
                    'mode': mode,
                    'completed': 'False',
                    'checked': true,
                    'questionnaire': {
                        'number': 0,
                        'points': [],
                        'utility': {}
                    }
                  };
                }
                edit_mode=false;
                $('#add_attribute h2').text("Add a new attribute");
              }
                sync_table();
                localStorage.setItem("assess_session_QUALI", JSON.stringify(assess_session_QUALI));
            }


        });

    });
</script>
</body>

</html>