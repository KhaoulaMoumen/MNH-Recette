import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Titre_atouts__c',
                'Offre_et_service_partenaire__c.Description_atouts__c'];

export default class Lwc02_AtoutsOffre extends LightningElement {
    @api recordId;

    offrePlusObj;
    titreAtoutsOffre;
    descriptionAtoutsOffre;


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
            this.titreAtoutsOffre = this.offrePlusObj.fields.Titre_atouts__c.value;
            this.descriptionAtoutsOffre = this.offrePlusObj.fields.Description_atouts__c.value;
        }
    }
}