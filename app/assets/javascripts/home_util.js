    $(document).ready(function() {
        $('[name="user[account_type]"]').change(function () {
    		if ($('[name="user[account_type]"]:checked').val() === "ind") {
        		//alert("it's Independent now");
        		$('#divPosition').toggle();
        		$('#divTicketName').toggle();
    			} 
    		else {
       			//alert("it's Ticket Manager now");
       			$('#divTicketName').toggle();
        		$('#divPosition').toggle();
    			}
			});
        });