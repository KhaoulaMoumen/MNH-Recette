public class CTRL07_AccountAdhesionClubs {
    public static void cocher_club_PEE(list<Account> lstAccount){
        Map<String,list<Offre_PSH__c>> PEEs = new Map<String,list<Offre_PSH__c>>();
        for(Account acc : lstAccount){
            PEEs.put(acc.id, acc.Offres_PSH__r);
        }
        for(Account myAcc : lstAccount){
            if(PEEs.get(myAcc.id).size()>0){
                myAcc.ClubPEE__c = true;
            }else {
                myAcc.ClubPEE__c = false;
            }
        }
        update lstAccount;

        
    }
    public static void cocher_club_CCH(list<Account> lstAccount){
        Map<String,list<Cercle_confort_habitat_adh_rent__c>> CCHs = new Map<String,list<Cercle_confort_habitat_adh_rent__c>>();
        for(Account acc : lstAccount){
            
            CCHs.put(acc.id, acc.Cercles_Confort_Habitat__r);
        }
        for(Account myAcc : lstAccount){
            if(CCHs.get(myAcc.id).size()>0){
                myAcc.Club_CCH__c = true;
            }else{
                myAcc.Club_CCH__c = false;
            }
        }
        update lstAccount;

        
    }
    public static void cocher_club_CME(list<Account> lstAccount){
        Map<String,list<Club_Mobilite_Electrique__c>> CMEs = new Map<String,list<Club_Mobilite_Electrique__c>>();
        for(Account acc : lstAccount){
            CMEs.put(acc.id, acc.Clubs_Mobilite_Electrique__r);
        }
        for(Account myAcc : lstAccount){
            if(CMEs.get(myAcc.id).size()>0){
                myAcc.ClubCME__c = true;
            }else{
                myAcc.ClubCME__c = false;
            }
        }
        update lstAccount;

        
    }
    public static void cocher_club(list<Account> lstAccount){
        cocher_club_PEE(lstAccount);
        cocher_club_CME(lstAccount);
        cocher_club_CCH(lstAccount);

        
    }
}