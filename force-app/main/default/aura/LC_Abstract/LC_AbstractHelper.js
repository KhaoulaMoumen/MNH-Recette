({
    handleErrors: function(component, errors){

        var message = errors[0].message;

        if(errors[0].pageErrors !== undefined && errors[0].pageErrors[0] !== undefined){
            message = errors[0].pageErrors[0].statusCode + ' : ' + errors[0].pageErrors[0].message;
        }


        if(message === undefined){
            return ;
        }

        var ltToast = $A.get("e.force:showToast");
        if(ltToast){
            ltToast.setParams({
                "message": message,
                'type':'error'
            });
            ltToast.fire();
        }else{
            var toast = component.getSuper().find('toast');
            if(toast){
                toast.addToast(message, "error");
            }
        }
    },
    handleSaveSuccess: function(component, message){

        var msg = message || $A.get("$Label.c.Enregistrement_effectue_avec_succes");

        var ltToast = $A.get("e.force:showToast");
        if(ltToast){
            ltToast.setParams({
                "message": msg,
                'type':'success'
            });
            ltToast.fire();
        }else{
            var toast = component.getSuper().find('toast');
            if(toast){
                toast.addToast(msg, "success");
            }
        }
    }

});