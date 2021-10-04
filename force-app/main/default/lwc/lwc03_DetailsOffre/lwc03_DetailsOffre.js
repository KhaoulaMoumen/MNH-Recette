import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Titre_details_offre_partenaire__c',
                'Offre_et_service_partenaire__c.Description_details_offre_partenaire__c'];

export default class Lwc03_DetailsOffre extends LightningElement {
    @api recordId;

    offrePlusObj;
    titreDetailsOffre;
    descriptionDetailsOffre;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log(message);
        } else if (data) {
            this.offrePlusObj = data;
            this.titreDetailsOffre = this.offrePlusObj.fields.Titre_details_offre_partenaire__c.value;
            this.descriptionDetailsOffre = this.offrePlusObj.fields.Description_details_offre_partenaire__c.value;
        }
    }
}