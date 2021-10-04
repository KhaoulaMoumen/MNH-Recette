import { LightningElement, api, track, wire } from 'lwc';
import ICONE from '@salesforce/resourceUrl/icones_banniere_offre_plus';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Offre_et_service_partenaire__c.Id', 
                'Offre_et_service_partenaire__c.Offre_plus_1__c', 
                'Offre_et_service_partenaire__c.Icone_offre_plus_1__c',
                'Offre_et_service_partenaire__c.Offre_plus_2__c', 
                'Offre_et_service_partenaire__c.Icone_offre_plus_2__c',
                'Offre_et_service_partenaire__c.Offre_plus_3__c', 
                'Offre_et_service_partenaire__c.Icone_offre_plus_3__c',
                'Offre_et_service_partenaire__c.Offre_plus_4__c', 
                'Offre_et_service_partenaire__c.Icone_offre_plus_4__c',
                'Offre_et_service_partenaire__c.Offre_plus_5__c', 
                'Offre_et_service_partenaire__c.Icone_offre_plus_5__c',
                'Offre_et_service_partenaire__c.Offre_plus_6__c', 
                'Offre_et_service_partenaire__c.Icone_offre_plus_6__c',
                'Offre_et_service_partenaire__c.Tech_Titre_Composant_SC__c'
            ];

export default class Lwc01_OffrePlus extends LightningElement {
    @api recordId;
    @track show1stLine = false;
    @track show2ndLine = false;
    @track show3rdLine = false;
    @track show4thLine = false;
    @track show5thLine = false;
    @track show6thLine = false;

    offrePlusObj;
    offrePlusTxt1;
    offrePlusTxt2;
    offrePlusTxt3;
    offrePlusTxt4;
    offrePlusTxt5;
    offrePlusTxt6;
    offrePlusIcone1;
    offrePlusIcone2;
    offrePlusIcone3;
    offrePlusIcone4;
    offrePlusIcone5;
    offrePlusIcone6;
    Tech_Titre_Composant_SC;

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

            // 1ere ligne
            this.offrePlusTxt1 = this.offrePlusObj.fields.Offre_plus_1__c.value;
            this.show1stLine = (this.offrePlusTxt1 != null);
            this.offrePlusIcone1 = this.getIconeURL(this.offrePlusObj.fields.Icone_offre_plus_1__c.value);

            // 2e ligne
            this.offrePlusTxt2 = this.offrePlusObj.fields.Offre_plus_2__c.value;
            this.show2ndLine = (this.offrePlusTxt2 != null);
            this.offrePlusIcone2 = this.getIconeURL(this.offrePlusObj.fields.Icone_offre_plus_2__c.value);

            // 3e ligne
            this.offrePlusTxt3 = this.offrePlusObj.fields.Offre_plus_3__c.value;
            this.show3rdLine = (this.offrePlusTxt3 != null);
            this.offrePlusIcone3 = this.getIconeURL(this.offrePlusObj.fields.Icone_offre_plus_3__c.value);

            // 4e ligne
            this.offrePlusTxt4 = this.offrePlusObj.fields.Offre_plus_4__c.value;
            this.show4thLine = (this.offrePlusTxt4 != null);
            this.offrePlusIcone4 = this.getIconeURL(this.offrePlusObj.fields.Icone_offre_plus_4__c.value);

            // 5e ligne
            this.offrePlusTxt5 = this.offrePlusObj.fields.Offre_plus_5__c.value;
            this.show5thLine = (this.offrePlusTxt5 != null);
            this.offrePlusIcone5 = this.getIconeURL(this.offrePlusObj.fields.Icone_offre_plus_5__c.value);

            // 6e ligne
            this.offrePlusTxt6 = this.offrePlusObj.fields.Offre_plus_6__c.value;
            this.show6thLine = (this.offrePlusTxt6 != null);
            this.offrePlusIcone6 = this.getIconeURL(this.offrePlusObj.fields.Icone_offre_plus_6__c.value);

            //Tech titre composant
            this.Tech_Titre_Composant_SC = this.offrePlusObj.fields.Tech_Titre_Composant_SC__c.value;
        }
    }

    getIconeURL (icone) {
        switch(icone) {
            case 'Application' : return ICONE + '/icones_banniere_offre_plus/Application.svg';
            case 'Automobile' : return ICONE + '/icones_banniere_offre_plus/Automobile.svg';
            case 'Badge' : return ICONE + '/icones_banniere_offre_plus/Badge.svg';
            case 'Calendrier' : return ICONE + '/icones_banniere_offre_plus/Calendrier.svg';
            case 'Camion' : return ICONE + '/icones_banniere_offre_plus/Camion.svg';
            case 'Carte' : return ICONE + '/icones_banniere_offre_plus/Carte.svg';
            case 'Catalogue' : return ICONE + '/icones_banniere_offre_plus/Catalogue.svg';
            case 'Colis' : return ICONE + '/icones_banniere_offre_plus/Colis.svg';
            case 'Création graphique' : return ICONE + '/icones_banniere_offre_plus/Creation_graphique.svg';
            case 'Croissance' : return ICONE + '/icones_banniere_offre_plus/Croissance.svg';
            case 'Devis' : return ICONE + '/icones_banniere_offre_plus/Devis.svg';
            case 'Entreprise' : return ICONE + '/icones_banniere_offre_plus/Entreprise.svg';
            case 'Etude' : return ICONE + '/icones_banniere_offre_plus/Etude.svg';
            case 'Europe' : return ICONE + '/icones_banniere_offre_plus/Europe.svg';
            case 'Expertise' : return ICONE + '/icones_banniere_offre_plus/Expertise.svg';
            case 'Fibre' : return ICONE + '/icones_banniere_offre_plus/Fibre.svg';
            case 'Internet' : return ICONE + '/icones_banniere_offre_plus/Internet.svg';
            case 'Livraison' : return ICONE + '/icones_banniere_offre_plus/Livraison.svg';
            case 'Magasin' : return ICONE + '/icones_banniere_offre_plus/Magasin.svg';
            case 'Page web' : return ICONE + '/icones_banniere_offre_plus/Page_web.svg';
            case 'Partenaire' : return ICONE + '/icones_banniere_offre_plus/Partenaire.svg';
            case 'Qualité' : return ICONE + '/icones_banniere_offre_plus/Qualite.svg';
            case 'Remise' : return ICONE + '/icones_banniere_offre_plus/Remise.svg';
            case 'Tarif' : return ICONE + '/icones_banniere_offre_plus/Tarif.svg';
            case 'Téléphone' : return ICONE + '/icones_banniere_offre_plus/Telephone.svg';
            case 'Borne' : return ICONE + '/icones_banniere_offre_plus/Borne.svg';
            case 'CCH' : return ICONE + '/icones_banniere_offre_plus/CCH.svg';
            case 'Chrono' : return ICONE + '/icones_banniere_offre_plus/Chrono.svg';
            case 'Formation' : return ICONE + '/icones_banniere_offre_plus/Formation.svg';
            case 'Pouce' : return ICONE + '/icones_banniere_offre_plus/Pouce.svg';
            case 'Relation' : return ICONE + '/icones_banniere_offre_plus/Relation.svg';

            default : return null;
        }
    }
}