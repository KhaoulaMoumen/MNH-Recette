({
    
    doInit: function(component, event, helper) {
        helper.getMetier(component, event) ;
        
  },
   redirectfromMobile : function (component, event, helper){
         var myuserID=event.getSource().get("v.value");
         helper.redirect(component, event,myuserID);
     
    },
     redirectfromDesktop : function (component, event, helper){
         
            var myuserID=event.currentTarget.dataset.myid;
         helper.redirect(component, event,myuserID);
    },
    showFilterModal:function (component, event, helper) {
        window.scrollTo(0, 0);
        component.set("v.isOpen" ,true );
    },
    closeModel:function (component, event, helper) {
        component.set("v.isOpen" ,false );
    },
    
    appliquerFiltre : function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
         if (device === 'PHONE'){
             window.scrollTo(0, 0);}

        var name = component.find('name').get('v.value');
        var city = component.find('city').get('v.value');
        var departement =  component.find('departement').get('v.value');
        var societe = component.find('societe').get('v.value');
        var metier = component.find('metier').get('v.value');
        if ((Boolean(metier)) || (Boolean(name)) || (Boolean(city)) || (Boolean(societe)) || (Boolean(departement))){
            component.set("v.MessageEmpty", false);
            component.set("v.name" , name);
            component.set("v.city" ,city);
            component.set("v.departement" ,departement);
            component.set("v.societe" ,societe);
            component.set("v.metier" ,metier);
            helper.SearchHelper(component, event);
        }else{
            component.set("v.TotalNumberOfRecord", 0);
            component.set("v.searchResult",[]);
            component.set("v.Message", false);
            component.set("v.MessageEmpty", true);
        }             
                
        component.set("v.isOpen" ,false );
    }
    
    
})