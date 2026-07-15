# XICA
XICA (Cross-platform Image Capture Architecture) for Lazarus (Free Pascal) and Delphi

Read this in: [English](README.md)

# Descrizione

XICA è una libreria runtime only. Non ci sono componenti visuali da installare.
È sufficiente aggiungere il pacchetto alle dipendenze/richieste della tua applicazione Lazarus/Delphi e iniziare a usarla.

La libreria ha l'obiettivo di accentrare le diverse librerie di acquisizione immagini come WIA, Twain, Sane,  ICA, etc. 
in modo da poter utilizzare un solo manager per enumerare ed acquisire l'immagine nelle varie piattaforme. 
Ovviamente nel caso di una libreria limitata ad un solo Sistema Operativo, come ad esempio WIA, questa non sarà disponibile su Linux/Mac.

# Uso della libreria

- Non ci sono classi derivate da TComponent, quindi devi utilizzarle solo dal codice e liberare la memoria autonomamente (vedi gli esempi).
  Per Lazarus utilizza il pacchetto xica_pkg.lpk
  Per Delphi utilizza il pacchetto xica_dpkg.dpk

- Compilatori supportati:
  Lazarus / Free Pascal
  Delphi

Consulta il file changelog.txt per il Log delle modifiche.


(c) 2026 Massimo Magnano
