import { LightningElement , api , track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import desactiverPartenaire from '@salesforce/apex/Lwc12_DesactiverPartenaireController.desactiverPartenaire';
import labelDesactivationNonPermise from '@salesforce/label/c.LABS_SF_MSG_DESACTIVATION_PARTENAIRE_NON_PERMISE';
import labelDesactivationOk from '@salesforce/label/c.LABS_SF_MSG_DESACTIVATION_PARTENAIRE_REUSSIE';

export default class Lwc12_DesactiverPartenaire extends LightningElement {
    @api recordId;
    @track error ;
    @track record;
    @track loading = true;

    label = {
        labelDesactivationNonPermise,
        labelDesactivationOk
    };

    connectedCallback() {
        desactiverPartenaire({ contactId : this.recordId})
            .then(result => {
                this.showToastMessage('success', 
                                    'Succès', 
                                    this.label.labelDesactivationOk, 
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
                    if(exception.name == "PermissionException" && exception.code == 2) {
                        this.showToastMessage('error', 
                            'Erreur', 
                            this.label.labelDesactivationNonPermise, 
                            '50000', 
                            'sticky'); 
                    } else {
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