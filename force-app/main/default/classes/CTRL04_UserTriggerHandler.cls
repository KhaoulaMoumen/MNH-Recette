public class CTRL04_UserTriggerHandler {
    
    @future
    public static void Meth01_afterDisablingPartners(Set<ID> accountIDs){
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        
        List<Account> accounts = [SELECT Id, Profil__c FROM Account WHERE Id IN :accountIDs];
        for(Account a : accounts) mapAccounts.put(a.Id, a);
        
        List<Account> accountsToUpdate = new List<Account>();        
        for(Id accID : accountIDs){
            if(mapAccounts.get(accID).Profil__c == 'Partenaire')  accountsToUpdate.add(new Account(Id=accID,Profil__c='Ancien Partenaire'));
            //else if(mapAccounts.get(accID).Profil__c == 'Adhérent')  accountsToUpdate.add(new Account(Id=accID,Profil__c='Ancien Adhérent'));
        }
        
        if(accountsToUpdate.size() > 0){
            if(!Test.isRunningTest()) update accountsToUpdate;
        }
    }
    
    // METHODS THAT CHECKS IF NICKNAME IS UNIQUE 
    public static void Meth02_checkNickname(List<User> users){
        Map<Id,Contact> ConSiretMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<Id>();
        
        for(User u : users){ 
            contactIds.add(u.ContactId);            
        }
        
        List<Contact> contacts = [SELECT Id, Account.sirenSiret__c, Account.Profil__c FROM Contact WHERE Id IN :contactIds];
        for(Contact c : contacts){
            ConSiretMap.put(c.Id, c);
        }
        
        for(User u : users){
            String uniqueNickname = u.firstName+'.'+u.lastName;
            Integer nbOccurences = findMatches(uniqueNickname);
            Contact relatedContact = ConSiretMap.get(u.ContactId);
            if(nbOccurences > 0) {
                system.debug('nbOccurences'+nbOccurences);
                if(relatedContact.Account.Profil__c == 'Adhérent' || relatedContact.Account.Profil__c == 'Client')
                {
                    system.debug('nickname adherent');
                    String siretAcc = (relatedContact.Account.sirenSiret__c).right(6);
                    uniqueNickname = u.firstName.left(1)+'.'+ u.LastName+siretAcc;
                    u.CommunityNickname = uniqueNickname;
                    system.debug('nickname adherent'+u.CommunityNickname );
                } 
                else if(relatedContact.Account.Profil__c == 'Partenaire') 
                {
                    system.debug('nickname partenaire');
                    u.CommunityNickname = uniqueNickname+nbOccurences;
                    system.debug('nickname partenaire'+u.CommunityNickname );
                }
            }
        }
    }
    
    // METHODS THAT CHECKS IF CONTACT IS ATTACHED TO MULTIPLE ACCOUNTS
    public static void Meth03_checkUsername(List<User> users){
        List<String> lstEmails = new List<String>();
        Map<String,User> usersMap = new Map<String, User>();
        Map<Id,Contact> ConSiretMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<Id>();
        
        for(User u : users){ 
            lstEmails.add(u.Email);
            usersMap.put(u.Email, u);
            contactIds.add(u.ContactId);            
        }
        
        List<Contact> contacts = [SELECT Id, AccountId, Account.sirenSiret__c, Account.Profil__c FROM Contact WHERE Id IN :contactIds];
        for(Contact c : contacts){
            ConSiretMap.put(c.Id, c);
        }
        List<AggregateResult> lstContacts = [SELECT count(Id) recordCount, Email, AccountId FROM Contact WHERE Email IN :lstEmails GROUP BY Email,AccountId];
        
        for(String currUserEmail : lstEmails){
            User currentUser = usersMap.get(currUserEmail);
            Contact relatedCon = ConSiretMap.get(currentUser.ContactId);
            Integer nbrOccu =  0;
            
            for (AggregateResult ar : lstContacts) {
                System.debug('Count of email ' + ar.get('Email') + ' is ' + ar.get('recordCount'));
                
                String userEmail = (String)ar.get('Email');
                String userAccId = (String)ar.get('AccountID');
                Integer recordCount = (Integer)ar.get('recordCount');
                
                system.debug('relatedCon.AccountId'+relatedCon.AccountId);
                system.debug('userAccId'+userAccId);
                
                if(relatedCon.AccountId != userAccId && currentUser.Email == userEmail) nbrOccu += recordCount;
            }
            
            System.debug('Count of duplications ' + nbrOccu);
            
            if(nbrOccu > 0){
                
                system.debug('duplicatedUser'+currentUser);
                system.debug('relatedCon'+relatedCon);
                
                String leftPart = (currentUser.Email).substringBefore('@');
                String rightPart = (currentUser.Email).substringAfter('@');
                
                system.debug('siret'+relatedCon.Account.sirenSiret__c);
                system.debug('profil'+relatedCon.Account.Profil__c);
                
                if(relatedCon.Account.Profil__c == 'Adhérent' || relatedCon.Account.Profil__c == 'Client')
                {
                    String siretAcc = (relatedCon.Account.sirenSiret__c).right(6);
                    currentUser.Username = leftPart + siretAcc +'@'+ rightPart;
                } 
                else if(relatedCon.Account.Profil__c == 'Partenaire') 
                {
                    currentUser.Username = leftPart +nbrOccu +'@'+ rightPart;
                }
            }
        }        
    }
    
    // METHODS that returns the number of users that have the same nickname 
    public static Integer findMatches(String uniqueNkn){
        return [SELECT Count() FROM User WHERE uniqueNickname__c =: uniqueNkn];
    }
}