({
    initialize : function(component, event, helper) {
        console.log( component.get("v.username"));
        var action = component.get("c.getUserInfos");
        action.setParams({
            "username" : component.get("v.username")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentUser", result);
            } 
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        var actionLeadDepartment = component.get("c.getLeadDepartment");
        //var inputsel = component.find("leadDept");
        var opts=[];
        actionLeadDepartment.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                //console.log( a.getReturnValue()[i]);
                opts.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //inputsel.set("v.options", opts);
            component.set("v.options", opts)
    
        });
        $A.enqueueAction(actionLeadDepartment);        
    },
    
    validateForm : function(component, event, helper) {
        
        console.log( 'username'+component.get("v.username"));

        
        // VALIDATE EMAIL
		var isValidEmail = false; 
        var isEmptyEmail = true; 
        var emailField = component.find("leadEmail");
        var emailFieldValue = emailField.get("v.value");
        
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;  
        emailField.set("v.errors", null);
        
        if(!$A.util.isEmpty(emailFieldValue)){   
            if(emailFieldValue.match(regExpEmailformat)){
			  emailField.set("v.errors", null);
              //$A.util.removeClass(emailField, 'slds-has-error');
              isValidEmail = true;
              isEmptyEmail = false;
        }else{
             //$A.util.addClass(emailField, 'slds-has-error');
             emailField.set("v.errors", [{message: "Veuillez renseigner une adresse email valide."}]);
             isValidEmail = false;
             isEmptyEmail = false;
        }
        } else {
            isEmptyEmail = true;
            isValidEmail = false;
        }
       
       // VALIDATE PHONE 
        var isValidPhone = false;
        var isEmptyPhone = true; 
        var phoneField = component.find("leadPhone");
        var phoneFieldValue = phoneField.get("v.value");

        var regExpPhoneformat = /^0[^0]\d{8}$/;  
        phoneField.set("v.errors", null);
        
        if(!$A.util.isEmpty(phoneFieldValue)){   
             
            console.log('phone '+phoneFieldValue);
            console.log('space '+phoneFieldValue.includes(' '));

            if(phoneFieldValue.match(regExpPhoneformat) && !phoneFieldValue.includes(' ')){
                console.log('1234567890');
			  phoneField.set("v.errors", null);
              //$A.util.removeClass(phoneField, 'slds-has-error');
              isValidPhone = true;
              isEmptyPhone = false;
        } else {
             //$A.util.addClass(phoneField, 'slds-has-error');
             phoneField.set("v.errors", [{message: "Veuillez renseigner un numéro de téléphone valide au format 0XXXXXXXXX."}]);
             isValidPhone = false;
			 isEmptyPhone = false;            
        }
        } else {
			isEmptyPhone = true; 
            isValidPhone = false;
            phoneField.set("v.errors", null);
           //$A.util.removeClass(phoneField, 'slds-has-error');
            if(isEmptyPhone && isEmptyEmail){
                //$A.util.addClass(phoneField, 'slds-has-error');
             	phoneField.set("v.errors", [{message: "Veuillez renseigner un numéro de téléphone ou un email."}]);
            }
        }
        
        // SALUTATION NOT BLANK
        var isEmptySalut = true; 
        var salutationField = component.find("leadSalutation");
        var salutationFieldValue = salutationField.get("v.value");
        console.log('salutationFieldValue'+salutationFieldValue);
        if(salutationFieldValue == undefined) {
            salutationFieldValue = 'M.';
            component.set("v.parrainage.leadSalutation__c", 'M.');
        }
        console.log('salutationFieldValue'+salutationFieldValue);
        
        if($A.util.isEmpty(salutationFieldValue)){
             //$A.util.addClass(salutationField, 'slds-has-error');
             salutationField.set("v.errors", [{message: "Le champ civilité est obligatoire."}]);
             isEmptySalut = true;
        } else {
			isEmptySalut = false; 
            salutationField.set("v.errors", null);
            //$A.util.removeClass(salutationField, 'slds-has-error');
        }
        
        // FIRSTNAME NOT BLANK
        var isEmptyFN = true; 
        var fnField = component.find("leadFN");
        var fnFieldValue = fnField.get("v.value");
		console.log('fnFieldValue'+fnFieldValue);
        fnField.set("v.errors", null);
        
        if($A.util.isEmpty(fnFieldValue)){
             //$A.util.addClass(fnField, 'slds-has-error');
             fnField.set("v.errors", [{message: "Le champ prénom est obligatoire."}]);
             isEmptyFN = true;
        } else {
			isEmptyFN = false; 
            //$A.util.removeClass(fnField, 'slds-has-error');
            fnField.set("v.errors", null);
            
        }
        
        // LASTNAME NOT BLANK
        var isEmptyLN = true; 
        var lnField = component.find("leadLN");
        var lnFieldValue = lnField.get("v.value");
        console.log('lnFieldValue'+lnFieldValue);
        lnField.set("v.errors", null);
        
        if($A.util.isEmpty(lnFieldValue)){
             //$A.util.addClass(lnField, 'slds-has-error');
             lnField.set("v.errors", [{message: "Le champ nom est obligatoire."}]);
             isEmptyLN = true;
        } else {
			isEmptyLN = false; 
            lnField.set("v.errors", null);
            //$A.util.removeClass(lnField, 'slds-has-error');
        }
        
        // GIFT NOT BLANK
        var isEmptygift = true; 
        var giftField = component.find("remerciements");
        var giftFieldValue = giftField.get("v.value");
        console.log('giftFieldValue'+giftFieldValue);
        
        if($A.util.isEmpty(giftFieldValue)){
             //$A.util.addClass(giftField, 'slds-has-error');
             giftField.set("v.errors", [{message: "Le champ cadeau remerciement est obligatoire."}]);
             isEmptygift = true;
        } else {
			isEmptygift = false;
            giftField.set("v.errors", null);
            //$A.util.removeClass(giftField, 'slds-has-error');
        }
        
        // COMPAny NOT BLANK
        var isEmptyCompany = true; 
        var companyField = component.find("leadCompany");
        var companyFieldValue = companyField.get("v.value");
        companyField.set("v.errors", null);
        
        if($A.util.isEmpty(companyFieldValue)){
             //$A.util.addClass(companyField, 'slds-has-error');
             companyField.set("v.errors", [{message: "Le champ société est obligatoire."}]);
             isEmptyCompany = true;
        } else {
			isEmptyCompany = false; 
            companyField.set("v.errors", null);
            //$A.util.removeClass(companyField, 'slds-has-error');
        }
        
        // departement NOT BLANK
        var isEmptyDepart = true; 
        var departField = component.find("leadDept");
        var departFieldValue = departField.get("v.value");
        departField.set("v.errors", null);
        console.log('departFieldValue'+departFieldValue);
        
        if($A.util.isEmpty(departFieldValue)){
             departField.set("v.errors", [{message: "Le champ Département du filleul est obligatoire."}]);
             isEmptyDepart = true;
        } else {
			isEmptyDepart = false; 
            departField.set("v.errors", null);
            //$A.util.removeClass(departField, 'slds-has-error');
        }
        
        console.log('isValidEmail'+isValidEmail);
        console.log('isEmptyEmail'+isEmptyEmail);
        console.log('isValidPhone'+isValidPhone);
        console.log('isEmptyPhone'+isEmptyPhone);
               
        if(!isEmptySalut && !isEmptyFN && !isEmptyLN && !isEmptygift && !isEmptyCompany && !isEmptyDepart && ((isValidEmail && !isEmptyEmail && isValidPhone && !isEmptyPhone)||(isValidPhone && !isEmptyPhone && isEmptyEmail)||(isValidEmail && !isEmptyEmail && isEmptyPhone))) {
            var parrain = component.get("v.currentUser.AccountId");
            var adminSyn = $A.get("$Label.c.Administratif_Synerciel_Id");
            
            console.log('i am here 2');
            
            component.set("v.parrainage.Parrain__c", parrain);
            component.set("v.parrainage.Statut__c", "En cours");
            component.set("v.parrainage.leadSource__c", "PARRAINAGE");
            component.set("v.parrainage.OwnerId", adminSyn);
            
            helper.launchFlow(component, event, helper);
        }       
	},
})