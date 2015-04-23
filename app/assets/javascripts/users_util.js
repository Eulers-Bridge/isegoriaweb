  $(document).ready(function() {
        $('#slInstitutionCountry').change(function(event){
            //console.log('Seleccionado: ' + $('#slInstitutionCountry option:selected').val());
            selected_country = $('#slInstitutionCountry option:selected').val();
            myFunction(selected_country);
        });
        function myFunction(selected_country) {
            console.log(selected_country);
            var country = countries[selected_country];
            var html = '<option value="' + 0 + '">' + select_one_text + '</option>'
            for (institution in country) {
                if (country.hasOwnProperty(institution)  &&        // These are explained
                /^0$|^[1-9]\d*$/.test(institution) &&    // and then hidden
                institution <= 4294967294)                // away below
                {
                    console.log('*'+country[institution]["name"]);
                    html = html.concat(' '+ '<option value="' + country[institution]["id"] + '">' + country[institution]["name"] + '</option>')
                }
            };
            $('#slInstitution').html(html)
            }
    });