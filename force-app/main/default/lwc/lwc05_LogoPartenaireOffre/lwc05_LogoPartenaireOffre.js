import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Logo_partenaire__c'];

export default class Lwc05_LogoPartenaireOffre extends LightningElement {
    @api recordId;
    @api isMap;

    offrePlusObj;
    logo;
    showLogo = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
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
            this.logo = this.offrePlusObj.fields.Logo_partenaire__c.value;
            this.showLogo = this.logo != null;
        }
    }
}