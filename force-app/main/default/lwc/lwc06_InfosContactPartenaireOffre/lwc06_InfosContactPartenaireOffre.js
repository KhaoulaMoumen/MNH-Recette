import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Nom_du_contact_partenaire__c',
                'Offre_et_service_partenaire__c.Telephone_du_contact_partenaire__c',
                'Offre_et_service_partenaire__c.Email_du_contact_partenaire__c',
                'Offre_et_service_partenaire__c.Comment_profiter_de_l_offre__c',
                'Offre_et_service_partenaire__c.Site_Web_du_contact_partenaire__c',
                'Offre_et_service_partenaire__c.Logo_partenaire__c'
                ];

export default class Lwc06_InfosContactPartenaireOffre extends LightningElement {
    @api recordId;
    
    offrePlusObj;
    descriptionOffre;
    nomContact;
    telContact;
    emailContact;
    linkEmailContact;
    linkTelContact;
    linkWebContact;
    logo;
    showInfoContact = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.log('recordid='+ this.recordId);
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log(message);
        } else if (data) {
            this.offrePlusObj = data;
            //console.log('data=' + JSON.stringify(this.offrePlusObj));
            this.nomContact = this.offrePlusObj.fields.Nom_du_contact_partenaire__c.value;
            this.telContact = this.offrePlusObj.fields.Telephone_du_contact_partenaire__c.value;
            this.emailContact = this.offrePlusObj.fields.Email_du_contact_partenaire__c.value;
            this.linkEmailContact = "mailto: " + this.emailContact;
            // on met le tel au format +33612345678, donc on enlève le 0 au début
            // pour que le lien fonctionne sur mobile
            if(this.telContact != null) {
               this.linkTelContact = "tel:+33" + this.telContact.substring(1);
            }
            this.linkWebContact = this.offrePlusObj.fields.Site_Web_du_contact_partenaire__c.value;
            this.logo = this.offrePlusObj.fields.Logo_partenaire__c.value;

            if(
                (this.nomContact != null && this.nomContact != '') ||
                (this.telContact != null && this.telContact != '') ||
                (this.emailContact != null && this.emailContact != '') ||
                (this.linkWebContact != null && this.linkWebContact != '')
            ) {
                this.showInfoContact = true;
            }
            this.descriptionOffre = this.offrePlusObj.fields.Comment_profiter_de_l_offre__c.value;
        }
    }
}