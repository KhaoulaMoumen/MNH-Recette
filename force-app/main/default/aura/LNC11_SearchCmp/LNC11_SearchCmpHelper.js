({
    SearchHelper: function(component, event) {
        // show spinner message
         component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchUsers");
        action.setParams({
            'connectedUserUsername': component.get("v.username"),
            'name':component.get("v.name"),
            'city':component.get("v.city"),
            'departement':component.get("v.departement"),
            'societe':component.get("v.societe"),
            'metier':component.get("v.metier")
        });
        action.setCallback(this, function(response) {
           // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);
                
                component.set("v.searchResult", storeResponse.sort(function(a, b){
                    var nameA=a.FirstName.toLowerCase(), nameB=b.FirstName.toLowerCase()
                    var LnameA=a.LastName.toLowerCase(), LnameB=b.LastName.toLowerCase()
                    if (nameA < nameB) //sort string ascending
                        return -1
                     if (nameA > nameB)
                         return 1
                     if (LnameA < LnameB) //sort string ascending
                        return -1
                     if (LnameA > LnameB)
                         return 1
                     return 0 //default return value (no sorting)
                })); 
                
            }else if (state === "INCOMPLETE") {
                console.log('Response is Incompleted');
            }else if (state === "ERROR") {
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
    },
    getMetier: function(component, event) {
        console.log('hello from helper');
        var action = component.get("c.getMetierList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var storeResponse = response.getReturnValue();
                component.set("v.listMetier", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
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
    },
     redirect : function (component, event,myuserID){
        
     
        //event.currentTarget.dataset.value;
        
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                //name: "User_Profile_Adherent__c",
                 name: "MySc_ADH_Profile_Adherent__c",
          
                
            },
            state: {
            recordId: myuserID
        }
        };
        var navService = component.find("navService");
         var defaultUrl = "#";
         var device = $A.get("$Browser.formFactor");
         if (device === 'PHONE'){
             navService.navigate(pageReference);
         }
         else {
             navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            component.set("v.url", url ? url : defaultUrl);
            window.open(url , '_blank');
        }), $A.getCallback(function(error) {
            component.set("v.url", defaultUrl);
            window.open(defaultUrl , '_blank');
        }));
         }
         
         
         
        
        
       /* component.set("v.redirect", true);
        console.log('this is my id');
        var myuserID = event.getSource().get('v.value');
        console.log('this is my id'+myuserID);
        component.set('v.userID', myuserID);*/
    },
})