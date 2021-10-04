({
    handleClick : function(cmp, event, helper) {
        var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
        analyticsInteraction.setParams({
            hitType : 'event',
            eventCategory : 'Button',
            eventAction : 'click',
            eventLabel : 'Winter Campaign Button',
            eventValue: 200
        });
        analyticsInteraction.fire();
    }    
})