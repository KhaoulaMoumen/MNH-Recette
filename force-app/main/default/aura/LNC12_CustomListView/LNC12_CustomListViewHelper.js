({
    getGroupData : function(component,event){
        //Load the Account data from apex
        console.log(component.get("v.username"));
       var action = component.get("c.getGroups");
         action.setParams({
            'username': component.get("v.username"),
        });
       // var toastReference = $A.get("e.force:showToast");
       
         action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if(state === "SUCCESS"){
                var groupWrapper = response.getReturnValue();
                
                console.log(groupWrapper);
                if(groupWrapper.success){
                    //Setting data to be displayed in table
                     groupWrapper.groupList.forEach(function(group){
          try{
            group['ownerName'] = group.Owner.Name;
              if(group.MemberCount ===0){
                  group['membres'] = group.MemberCount;
              }
              else if(group.MemberCount ===1){
                  group['membres'] = group.MemberCount+' membre';}
              else 
                  group['membres'] = group.MemberCount+' membres';
          }catch(e){}
        });
                    component.set("v.groupData",groupWrapper.groupList);
                    
                } // handel server side erroes, display error msg from response 
                else{
                   
                }
            } // handel callback error 
            else{
               
            }
            //toastReference.fire();
        });
        $A.enqueueAction(action);
        
    },
    
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.groupData");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'NumberOfEmployees'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        component.set("v.groupData",data);
    },
    goToGroup : function(component, event, helper,row) {
        var rowId = row.Id;
        console.log('hi'+rowId);
        var navEvt;
        if(rowId) {
            navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParam("recordId", rowId);
        }
        navEvt.fire();
    }
})