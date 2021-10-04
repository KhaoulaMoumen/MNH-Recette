({
    onInit : function(component,event,helper){
        // Setting column information.To make a column sortable,set sortable as true on component load
        component.set("v.groupColumns",[
            {
                "targets" : 6 ,
                "data": "img",
                "render" : function ( url, type, full) {
                    return '<img height="75%" width="75%" src="'+full[7]+'"/>';}
                },
                {
                label : 'Nom',
                type:  'button',
                typeAttributes: 
                {
                    label: {fieldName: 'Name'}, 
                    name: 'goToGroup', 
                    disabled: false,
                    variant : 'base'
                }
            },
            
            {
                label : 'Dernière activité',
                fieldName : 'LastFeedModifiedDate',
                type : 'date',
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                },
                sortable : true
            },
            {
                label : 'Membres',
                fieldName : 'membres',
                type : 'text',
                sortable : true
            },
            {
                label : 'Surnom',
                fieldName : 'ownerName',
                type : 'text',
                sortable : true
            },
            
            
        ]);
            // call helper function to fetch account data from apex
            helper.getGroupData(component,event);
            },
            
            //Method gets called by onsort action,
            handleSort : function(component,event,helper){
            //Returns the field which has to be sorted
            var sortBy = event.getParam("fieldName");
            //returns the direction of sorting like asc or desc
            var sortDirection = event.getParam("sortDirection");
            //Set the sortBy and SortDirection attributes
            component.set("v.sortBy",sortBy);
            component.set("v.sortDirection",sortDirection);
            // call sortData helper function
            helper.sortData(component,sortBy,sortDirection);
            },
            handleRowAction: function (component,event,helper) {
            var row = event.getSource().get('v.value');
            helper.goToGroup(component, event, helper,row);
            }
            })