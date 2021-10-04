({
	getmetiers : function(component,event){
        
        //Load the Account data from apex
        console.log(component.get("v.userId"));
       var action = component.get("c.getmetiers");
         action.setParams({
            'userId': component.get("v.userId"),
        });
       
         action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.metiers",result);
                } 
        });
        $A.enqueueAction(action);
        
    },
})