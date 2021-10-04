/**
 * @description       : 
 * @author            : TALAN
 * @group             : 
 * @last modified on  : 05-18-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date           Author          Modification
 * 1.1  04-29-2021      Alexis Ly       Redmine 2625 // line 43 && 50 : exclusion TDR et Holdings
 * 1.1  18-05-2021      Alexis Ly       Redmine 2625 // line 28 && 46 : exclusion de la gestion d'entreprises de la liste des metiers
**/
public without sharing class CTRL07_SearchController {
    @AuraEnabled
       public static list<String> getMetierList(){
           list<String> finalList = new list <String> ();
           set <String> allOpts = new set <String> ();
         /*  list<Metier_de_reference__c> metiers = [select metier__c from Metier_de_reference__c];
           for(Metier_de_reference__c m : metiers){
               allOpts.add(m.metier__c);
           }*/
       Schema.DescribeFieldResult fieldResult = Metier_de_reference__c.Metier__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
           for (Schema.PicklistEntry a: ple) {
                    allOpts.add(a.getValue());
           }
           system.debug('allOpts ---->' + allOpts.size());
           allOpts.remove('Gestion d\'entreprises');
           finalList.addAll(allOpts);
           finalList.sort();
           return finalList;
       }
       
       
       @AuraEnabled
    public static list < User > fetchUsers(String connectedUserUsername, String name,String city
                                          ,String departement,String societe,String metier) {
      
          String profileAdherent = 'Adhérent';
          String profileAdherentPlus = 'Adhérent Plus';
          String gestionEntreprises = 'Gestion d\'entreprises';
                  list<String> nameKeyList = new list<String>();
                  list<String> cityKeyList = new list<String>();
                  list<String> societeKeyList = new list<String>();
        List<User> lstOfUsers = new List<User>();
        String query='SELECT Id,Portail_RGPD__c, contact.account.referenceTrade__c, FirstName, LastName,Contact.Phone,Contact.MobilePhone,Contact.Account.Phone, Contact.Account.ClubCME__c,Contact.Account.Club_CCH__c,Contact.Account.ClubPEE__c,Contact.Account.Name,Contact.Account.Name2__c,Contact.AccountId,Contact.Account.Metier_de_reference_principal__c, Contact.Account.BillingCity,Contact.Account.BillingPostalCode,Contact.Account.Departement__c,Contact.Account.billingState' + 
                    ' FROM User WHERE contactid != null and IsActive=true and (NOT(contact.account.referenceTrade__c LIKE: gestionEntreprises)) and (profile.name like: profileAdherent or profile.name like: profileAdherentPlus) and IsTalan__c = false';
          
       if(!(String.isBlank(metier))){
            list <Account> accs = [Select Id, Name From Account Where Id IN (Select Compte__c From Metier_de_reference__c where Metier__c like: metier)];
           query=query+' and Contact.Accountid IN : accs ';
            //query=query+' and Contact.Account.Metier_de_reference_principal__c LIKE : metier ';
           }
       if(!(String.isBlank(name))){
            name='%'+name+'%';
             
             nameKeyList.add(name) ;
             if(name.contains(' ')) {
                String s1 = name.replaceAll(' ','-');
                String s2 = name.replaceAll(' ','\'');
                nameKeyList.add(s1);
                nameKeyList.add(s2);
           }
            if (name.contains('-')){
                
                     String s3 = name.replaceAll('-',' ');
                nameKeyList.add(s3);
                
                }
            if (name.contains('\'')){
                String s4 = name.replaceAll('\'',' '); 
                nameKeyList.add(s4);
                                              }
            query=query+' and (name LIKE : nameKeyList or firstName like : nameKeyList or lastName like : nameKeyList) ';
            
        }
        if(!(String.isBlank(city))){
            city='%'+city+'%';
                   cityKeyList.add(city) ;
             if(city.contains(' ')) {
                String s1 = city.replaceAll(' ','-');
                String s2 = city.replaceAll(' ','\'');
                cityKeyList.add(s1);
                cityKeyList.add(s2);
   
           }
            if (city.contains('-')){
                
                     String s3 = city.replaceAll('-',' ');
                cityKeyList.add(s3);
             
                }
            if (city.contains('\'')){
                String s4 = city.replaceAll('\'',' '); 
                cityKeyList.add(s4);
                                              }
            query=query+' and Contact.Account.BillingCity LIKE: cityKeyList';
             
        }
        
        if(!(String.isBlank(societe))){
            societe='%'+societe+'%';
             
           societeKeyList.add(societe) ;
             if(societe.contains(' ')) {
                String s1 = societe.replaceAll(' ','-');
                String s2 = societe.replaceAll(' ','\'');
                societeKeyList.add(s1);
                societeKeyList.add(s2);
   
           }
            if (societe.contains('-')){
                
                     String s3 = societe.replaceAll('-',' ');
                societeKeyList.add(s3);
             
                }
            if (societe.contains('\'')){
                String s4 = societe.replaceAll('\'',' '); 
                societeKeyList.add(s4);
                                              }
            query=query+' and Contact.Account.name LIKE: societeKeyList';
             
        }
        if(!(String.isBlank(departement))){
            departement=departement+'%';
            query=query+' and Contact.Account.Departement__c LIKE: departement';
            
        }
        //if (!((String.isBlank(metier)) && (String.isBlank(name)) && (String.isBlank(city)) && (String.isBlank(societe)) && (String.isBlank(departement)))){
           lstOfUsers = Database.query(query);
         
        //}                     
     return lstOfUsers;
    }
   }