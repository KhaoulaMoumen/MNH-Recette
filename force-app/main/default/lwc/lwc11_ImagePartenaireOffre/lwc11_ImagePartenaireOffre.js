import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Image_partenaire__c'];

export default class Lwc11_ImagePartenaireOffre extends LightningElement {
    @api recordId;

    offrePlusObj;
    image;
    showImage = true;

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
            this.image = this.offrePlusObj.fields.Image_partenaire__c.value;
            this.showImage = this.image != null;
        }
    }
}