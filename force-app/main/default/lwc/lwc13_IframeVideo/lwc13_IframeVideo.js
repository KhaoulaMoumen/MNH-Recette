import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Video__c'];

export default class Lwc13_IframeVideo extends LightningElement {
    @api recordId;
    iframeUrl;
	offreDetail;
    showVideo = true;

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
            this.offreDetail = data;
            this.iframeUrl = this.offreDetail.fields.Video__c.value;
            this.showVideo = this.iframeUrl != null;
        }
    }    
}