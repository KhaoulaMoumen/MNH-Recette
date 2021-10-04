import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Titre_offre_service__c',
                'Offre_et_service_partenaire__c.Sous_titre__c',
                'Offre_et_service_partenaire__c.Banniere__c'
            ];

export default class Lwc04_BandeauEnteteOffre extends LightningElement {
    @api recordId;

    offrePlusObj;
    titreOffre;
    sousTitreOffre;
    backgroundURL;
    backgroundStyle;


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
            this.titreOffre = this.offrePlusObj.fields.Titre_offre_service__c.value;
            this.sousTitreOffre = this.offrePlusObj.fields.Sous_titre__c.value;
            this.backgroundURL = this.offrePlusObj.fields.Banniere__c.value;
            this.backgroundStyle = "background-image: url('" + this.backgroundURL + "');";
        }
    }
}