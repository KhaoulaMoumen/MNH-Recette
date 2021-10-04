import { LightningElement , api , track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import interesserOffre from '@salesforce/apex/Lwc14_InteresserOffre.interesserOffre';


const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Titre_atouts__c',
                'Offre_et_service_partenaire__c.Tech_Titre_Composant_SC__c'
            ];

export default class Lwc14_InteresserOffre extends LightningElement {
    @api recordId;
    @track error ;
    @track record;
    @track loading = true;

    offrePlusObj;
    titreAtoutsOffre;
    url;
    textButtonOffre;
    recordTypeName;

     
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
            this.recordTypeName = this.offrePlusObj.fields.Tech_Titre_Composant_SC__c.value;
            this.url = '/s/contact-partenaire?recordId=' + this.offrePlusObj.fields.Id.value;
            console.log('RT'+this.recordTypeName);
            if (this.recordTypeName == 'Les + de Synerciel') {
                this.textButtonOffre = 'Je profite de l’offre';
            }
            else{
                this.textButtonOffre = 'Intéressé par l’offre';
            }
        }
    }
    
    clickEvent() {  
        if (this.recordTypeName !='Les + de Synerciel') {    
            interesserOffre({ offreName : this.offrePlusObj.fields.Titre_atouts__c.value})
            .then(result => {
                this.showToastMessage('success', 
                                        'Succès', 
                                        'Case créé', 
                                        '5000', 
                                        'dismissable')                                  
                this.closeQuickAction();
            })
            .catch(error => {
                console.error(error);
                this.loading = false;

                if(error.body.message != null) {
                    // on est dans une custom exception
                    var exception = JSON.parse(error.body.message);
                    if(exception.name == "PermissionException" && exception.code == 1) {
                        this.showToastMessage('error', 
                            'Erreur', 
                            'Erreur de permission', 
                            '50000', 
                            'sticky'); 
                    } 
                    else {
                        this.showToastMessage('error', 
                            'Erreur', 
                            exception.message, 
                            '50000', 
                            'sticky');
                    }
                } else {
                    // exception provenant de SF
                    console.error('Exception serveur SF'); 
                    // TODO comment attraper le message d'erreur de SF ???    
                }

                this.closeQuickAction();
            });
        }
    }

    showToastMessage(typeToast, titleToast, messageToDisplay, duration, mode) {
        const event = new ShowToastEvent({title: titleToast,
            message: messageToDisplay,
            duration: duration,
            key: 'info_alt',
            variant: typeToast,
            mode: mode});
        this.dispatchEvent(event);
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}