/* 

 * Copyright (C) EuraNov -- All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Catherine DELEGLISE <catherine@euranov.com>, July 2019

 */

trigger EUR12_MetierReferenceTrigger on Metier_de_reference__c (before insert, before update) {
    
    //on récupère les métiers de référence principaux déjà associés aux comptes et aux prospects
    List<Metier_de_reference__c> metierToCountAcc = [Select Compte__c, Name,Principal__c from Metier_de_reference__c where Compte__c != null AND Principal__c= true];
    List<Metier_de_reference__c> metierToCountLead = [Select Prospect__c, Name,Principal__c from Metier_de_reference__c where Prospect__c != null AND Principal__c= true];
    
    //on associe chaque métier à son compte/ son prospect
    
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            System.debug('Déclenchement du trigger insert EUR12_MetierReferenceTrigger');
            
            for(Metier_de_reference__c mTrig: trigger.new){
                if(mTrig.Principal__c== true){
                    //System.debug('MétierTrig'+ mTrig);
                    if (mTrig.Compte__c !=null){
                        Integer nboccurMetier = 0;
                        for (Metier_de_reference__c i : metierToCountAcc)
                            
                            if (i.Compte__c == mTrig.Compte__c){
                                //System.debug('Il existe un métier de référence principal :'+mTrig.Name + '  '+mTrig.Principal__c);
                                nboccurMetier = nboccurMetier + 1;
                            }
                        //System.debug('NbOccurmétier compte'+ nboccurMetier);
                        if(nboccurMetier >= 1){
                            mTrig.addError('Il existe déjà un métier de référence principal sur ce compte merci de décocher la case Principal pour ce métier');
                        }
                    }
                    if (mTrig.Prospect__c !=null){
                        Integer nboccurMetierProspect = 0;
                        for (Metier_de_reference__c j : metierToCountLead){
                            if (j.Prospect__c == mTrig.Prospect__c){
                                nboccurMetierProspect = nboccurMetierProspect + 1;
                            }
                            //System.debug('NbOccurmétier prospect'+ nboccurMetierProspect);
                            if(nboccurMetierProspect >= 1){
                                mTrig.addError('Il existe déjà un métier de référence principal sur ce prospect merci de décocher la case Principal pour ce métier');
                            }	
                        }
                    }
                }
            }
        }
        if (trigger.isUpdate) {
            System.debug('Déclenchement du trigger update EUR12_MetierReferenceTrigger');
            
            for(Metier_de_reference__c mTrig: trigger.new){
                if(mTrig.Principal__c== true){
                    if (mTrig.Compte__c !=null){
                        Integer nboccurMetier = 0;
                        for (Metier_de_reference__c i : metierToCountAcc){
                            system.debug('Métier existant'+i.Name);
                            if (i.Compte__c == mTrig.Compte__c){
                                System.debug('Il existe un métier de référence principal :'+i.Name + '  '+i.Principal__c);
                                nboccurMetier = nboccurMetier + 1;
                            }
                            System.debug('NbOccurmétier compte'+ nboccurMetier);
                            if(nboccurMetier > 1){
                                mTrig.addError('Il existe déjà un métier de référence principal sur ce compte merci de décocher la case Principal pour ce métier');
                            }
                        }
                    }
                    if (mTrig.Prospect__c !=null){
                        System.debug('MétierTrigcompte '+ mTrig.Compte__c + 'MétierTrigprospect '+ mTrig.Prospect__c + 'MétiertocountLeadsize'+ metierToCountLead.size() );
                        Integer nboccurMetierProspect = 0;
                        for (Metier_de_reference__c j : metierToCountLead){
                            system.debug('Métier existant'+j.Name);
                            if (j.Prospect__c == mTrig.Prospect__c){
                                System.debug('Il existe un métier de référence principal :'+j.Name + '  '+j.Principal__c);
                                nboccurMetierProspect = nboccurMetierProspect + 1;
                            }
                            System.debug('NbOccurmétier prospect'+ nboccurMetierProspect);
                            if(nboccurMetierProspect > 1){
                                mTrig.addError('Il existe déjà un métier de référence principal sur ce prospect merci de décocher la case Principal pour ce métier');
                            }
                        }
                    }
                }
            }
        }
    }
}