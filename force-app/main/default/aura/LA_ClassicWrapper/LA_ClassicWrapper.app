<aura:application access="global" extends="ltng:outApp" >
    <aura:dependency resource="c:LC_Configuration_Wrapper"/>
    <aura:dependency resource="IWS_ALTARES:LC_Recherche_Wrapper"/>
    <aura:handler name="init" value="{!this}" action="{!c.init}"/>
</aura:application>