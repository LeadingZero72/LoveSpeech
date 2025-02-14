import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:translator/translator.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;


void main()
{
  runApp(LeChiffreApp());
}


class LeChiffreApp extends StatelessWidget
{
  const LeChiffreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoveSpeech 1.0 (c)2006-2025 Alexander Graf (LeadingZero78@gmail.com)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChiffrierungScreen(),
    );
  }
}


class ChiffrierungScreen extends StatefulWidget {
  const ChiffrierungScreen({super.key});

  @override
  _ChiffrierungScreenState createState() => _ChiffrierungScreenState();
}


class _ChiffrierungScreenState extends State<ChiffrierungScreen> with WidgetsBindingObserver
{
  final TextEditingController Textfeld = TextEditingController();
  final FocusNode Fokus                = FocusNode();
  final Translator                     = GoogleTranslator();

  List<Map<String, String>> Benutzerliste = [];        //Liste für Benutzernamen und Passwörter
  String Hintergrundbild = '';                         //Das gewählte Hintergrundbild
  String User = '';                                    //Speichern des ausgewählten Benutzers
  String PublicKey = '';                               //Öffentlicher Schlüssel während des Chiffrierens/Dechiffrierens
  String PrivateKey = '';                              //Privater Schlüssel während des Chiffrierens/Dechiffrierens
  String Title = 'LoveSpeech 1.0 copyright 2006-2025 Alexander Graf (LeadingZero78@gmail.com)'; //Variable für den angezeigten Titel in der AppBar
  List<int> Passwort            = List.filled(256, 0); //256 Byte langes Passwort während des Chiffrierens/Dechiffrierens
  List<int> Index               = List.filled(256, 0); //256 Dimensionen für die Index-Variable
  int    PasswortLength = 0;                           //Virtuelle Länge des Passworts (Passwort.length würde immer 256 zurückliefern, weil das fest reserviert ist! Ich muß also eine extra Variable dafür nehmen und die aktualisieren, wenn während der Verschlüsselung Einträge dazukommen)
  int    PasswortMinimum = 123;                        //Halbierung des Passworts (mit etwas Sicherheitsabstand..).
  int    PasswortMaximum = 256;                        //Längstes Passwort.
  bool   PasswortSchrumpfen = false;                   //Passwort wachsen oder schrumpfen lassen (für die Wobbel-Metamorphose)
  int    DimensionenTotal = 256;                       //Gesamtmenge hängt von der länge des Passworts ab
  int    Dimensionen = 7;                              //Aktuelle Dimensionszahl
  int    Hash = 0;                                     //Laufender Hash vom Passwort bei der Verschlüsselung/Entschlüsselung
  int    Style = 0x2800;                               //Unicode-Auswahl beim Chiffrieren/Dechiffrieren (Default = Blindenschrift)
  double FontSize = 28.0;                              //Schriftgröße im Textfeld (default 16)
  bool   EnableSmileys = true;                         //Smileys bei der Verschlüsselung standardmäßig aktivieren
  int    Namensbegrenzung = 30;                        //Namen sollen nicht zu pompös werden!
  bool   isEncrypted = false;                          //Text bisher noch unverschlüsselt.
  String Sprache = 'en';                               //Aktuelle GUI-Sprache

  //Definiere hier ein paar Standardfarben
  Color ButtonColor = Colors.black;
  Color AppBarColor = Colors.black;
  Color Textfarbe   = Colors.black;

  //Hier sind die Namen für die einzelnen Hintergrundbilder
  List<String> Hintergrundbilder =
  [
    'assets/Bilder/Bild1.jpg',
    'assets/Bilder/Bild2.jpg',
    'assets/Bilder/Bild3.jpg',
    'assets/Bilder/Bild4.jpg',
    'assets/Bilder/Bild5.jpg',
    'assets/Bilder/Bild6.jpg',
    'assets/Bilder/Bild7.jpg',
    'assets/Bilder/Bild8.jpg',
    'assets/Bilder/Bild9.jpg',
    'assets/Bilder/Bild10.jpg',
    'assets/Bilder/Bild11.jpg',
    'assets/Bilder/Bild12.jpg',
    'assets/Bilder/Bild13.jpg',
    'assets/Bilder/Bild14.jpg',
    'assets/Bilder/Bild15.jpg',
    'assets/Bilder/Bild16.jpg',
    'assets/Bilder/Bild17.jpg',
    'assets/Bilder/Bild18.jpg',
    'assets/Bilder/Bild19.jpg',
    'assets/Bilder/Bild20.jpg',
    'assets/Bilder/Bild21.jpg',
    'assets/Bilder/Bild22.jpg',
    'assets/Bilder/Bild23.jpg',
    'assets/Bilder/Bild24.jpg',
    'assets/Bilder/Bild25.jpg',
    'assets/Bilder/Bild26.jpg',
    'assets/Bilder/Bild27.jpg',
    'assets/Bilder/Bild28.jpg',
    'assets/Bilder/Bild29.jpg',
    'assets/Bilder/Bild30.jpg',
  ];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ZufallsHintergrund();
    SetzeFarben(Hintergrundbild);
    SpracheErmitteln();
  }

  @override
  void dispose() {
    Textfeld.dispose();
    Fokus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      FetchClipboardText();
    }
  }




//#########################################################################################
//#                  Hier sind die einzelnen Sprachelemente
//#########################################################################################
final Map<String, Map<String, String>> Sprachelemente =
{
  'en':
  {
    'Chiffrieren':      'Encrypt',
    'Dechiffrieren':    'Decrypt',
    'Zurück':           'Back',
    'Hinzufügen':       'Add',
    'EmailTitel':       'Send cipher as E-Mail',
    'EmailAdresse':     'Email-Address',
    'EmailBetreff':     'Subject (optional)',
    'EmailFehlt':       'Please enter a valid email address',
    'EmailSenden':      'Send',
    'PasswortÄndern':   'Change password',
    'Übernehmen':       'Apply',
    'Abbrechen':        'Cancel',
    'PasswortStark':    'Generate strong password',
    'Name':             'Nickname',
    'Passwort':         'Password',
    'NeuerBuddy':       'Add new buddy',
    'Existiert':        'Username already exists. Please delete or choose a different one.',
    'ZuLang':           'Username is too long. Please choose a shorter name.',
    'PasswortKurz':     'The password must be at least 12 characters long!',
    'PasswortUnsicher': 'The password must contain at least one uppercase, one lowercase, a number and a special character and must be at least 12 characters long',
    'Löschen':          'Are you sure you want to delete him/her from the list ?',
    'Lösche':           'Delete',
    'Import':           'Import buddy list',
    'Export':           'Export buddy list',
    'Welcome':          'Welcome!',
    'Handy':            'Please enter a phone number',
    'SMSSenden':        'Send SMS',
    'TextNickname':     'Please type in a message (and select a nickname first).',
    'Textfeld':         'Text/Cipher',
    'EmojisON':         'Emojis enabled',
    'EmojisOFF':        'Emojis disabled',
  },
  'de':
  {
    'Chiffrieren':      'Chiffrieren',
    'Dechiffrieren':    'Dechiffrieren',
    'Zurück':           'Zurück',
    'Hinzufügen':       'Hinzufügen',
    'EmailTitel':       'Chiffre als EMail versenden',
    'EmailAdresse':     'EMail-Empfänger',
    'EmailBetreff':     'Betreff (optional)',
    'EmailFehlt':       'Bitte gib eine gültige EMail-Adresse ein',
    'EmailSenden':      'Senden',
    'PasswortÄndern':   'Passwort ändern',
    'Übernehmen':       'Übernehmen',
    'Abbrechen':        'Abbrechen',
    'PasswortStark':    'Starkes Passwort generieren',
    'Name':             'Spitzname',
    'Passwort':         'Passwort',
    'NeuerBuddy':       'Freund hinzufügen',
    'Existiert':        'Ein Freund mit diesem Namen existiert bereits. Bitte wähle einen neuen Namen.',
    'ZuLang':           'Der gewählte Name ist zu lang. Bitte wähle einen Namen mit maximal 30 Zeichen.',
    'PasswortKurz':     'Das Passwort muß mindestens 12 Zeichen lang sein.',
    'PasswortUnsicher': 'Das Passwort muß mindestens einen Großbuchstaben, Kleinbuchstaben, eine Zahl und ein Sonderzeichen enthalten und mindestens 12 Zeichen lang sein.',
    'Löschen':          'Sicher, daß er/sie gelöscht werden soll ?',
    'Lösche':           'Löschen',
    'Import':           'Freundesliste importieren',
    'Export':           'Freundesliste exportieren',
    'Welcome':          'Herzlich Willkommen!',
    'Handy':            'Bitte gib eine gültige Handynummer ein',
    'SMSSenden':        'SMS Senden',
    'TextNickname':     'Gib zuerst einen Text ein (und wähle einen Freund für die Verschlüsselung)',
    'Textfeld':         'Text/Chiffre',
    'EmojisON':         'Emojis aktiv',
    'EmojisOFF':        'Keine Emojis',
  },
  'fr':
  {
    'Chiffrieren':      'Crypter',
    'Dechiffrieren':    'Décrypter',
    'Zurück':           'Dos',
    'Hinzufügen':       'Ajouter',
    'EmailTitel':       'Envoyer le code par e-mail',
    'EmailAdresse':     'Adresse email',
    'EmailBetreff':     'Sujet (facultatif)',
    'EmailFehlt':       'S\'il vous plaît, mettez une adresse email valide',
    'EmailSenden':      'Envoyer',
    'PasswortÄndern':   'Changer le mot de passe',
    'Übernehmen':       'Reprendre',
    'Abbrechen':        'Annuler',
    'PasswortStark':    'Générer un mot de passe fort',
    'Name':             'Surnom',
    'Passwort':         'Mot de passe',
    'NeuerBuddy':       'Ajouter un nouveau camarade',
    'Existiert':        'Un ami portant ce nom existe déjà. Veuillez choisir un nouveau nom.',
    'ZuLang':           'Le nom que vous avez choisi est trop long. Veuillez choisir un nom de 30 caractères maximum.',
    'PasswortKurz':     'Le mot de passe doit comporter au moins 12 caractères.',
    'PasswortUnsicher': 'Le mot de passe doit contenir au moins une lettre majuscule, une lettre minuscule, un chiffre et un caractère spécial et comporter au moins 12 caractères.',
    'Löschen':          'Etes-vous sûr qu\'il/elle doit être supprimé ?',
    'Lösche':           'Supprimer',
    'Import':           'Importer la liste d\'amis',
    'Export':           'Exporter la liste d\'amis',
    'Welcome':          'Accueillir!',
    'Handy':            'Veuillez saisir un numéro de mobile valide',
    'SMSSenden':        'Envoyer des SMS',
    'TextNickname':     'Entrez d\'abord un texte (et choisissez un ami à chiffrer)',
    'Textfeld':         'Texte/Chiffre',
    'EmojisON':         'Emojis activés',
    'EmojisOFF':        'Emojis désactivés',
  },
  'es':
  {
    'Chiffrieren':      'Cifrar',
    'Dechiffrieren':    'Descifrar',
    'Zurück':           'Atrás',
    'Hinzufügen':       'Agregar',
    'EmailTitel':       'Enviar el código como un correo electrónico',
    'EmailAdresse':     'Dirección de correo electrónico',
    'EmailBetreff':     'Asunto (opcional)',
    'EmailFehlt':       'Por favor, introduce una dirección de correo electrónico válida',
    'EmailSenden':      'Enviar',
    'PasswortÄndern':   'Cambiar la contraseña',
    'Übernehmen':       'Aceptar',
    'Abbrechen':        'Cancelar',
    'PasswortStark':    'Generar contraseña segura',
    'Name':             'Apodo',
    'Passwort':         'Contraseña',
    'NeuerBuddy':       'Agregar nuevo compañero',
    'Existiert':        'Ya existe un amigo con este nombre. Por favor elija un nuevo nombre.',
    'ZuLang':           'El nombre que elegiste es demasiado largo. Elija un nombre con un máximo de 30 caracteres.',
    'PasswortKurz':     'La contraseña debe tener al menos 12 caracteres.',
    'PasswortUnsicher': 'La contraseña debe contener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial y tener al menos 12 caracteres.',
    'Löschen':          '¿Estás seguro de que debería eliminarlo?',
    'Lösche':           'Borrar',
    'Import':           'Importar lista de amigos',
    'Export':           'Exportar lista de amigos',
    'Welcome':          '¡Bienvenido!',
    'Handy':            'Por favor introduce un número de móvil válido',
    'SMSSenden':        'Enviar SMS',
    'TextNickname':     'Primero ingresa un texto (y elige un amigo para cifrar)',
    'Textfeld':         'Texto/Chiffre',
    'EmojisON':         'Emojis habilitados',
    'EmojisOFF':        'Emojis deshabilitados',
  },
  'it':
  {
    'Chiffrieren':      'Cripta',
    'Dechiffrieren':    'Decripta',
    'Zurück':           'Indietro',
    'Hinzufügen':       'Aggiungere',
    'EmailTitel':       'Invia il codice tramite e-mail',
    'EmailAdresse':     'Indirizzo e-mail',
    'EmailBetreff':     'Oggetto (facoltativo)',
    'EmailFehlt':       'Si prega di inserire un indirizzo email valido',
    'EmailSenden':      'Inviare',
    'PasswortÄndern':   'Cambiare la password',
    'Übernehmen':       'Accettare',
    'Abbrechen':        'Cancellare',
    'PasswortStark':    'Genera una password complessa',
    'Name':             'Soprannome',
    'Passwort':         'Password',
    'NeuerBuddy':       'Aggiungi amico',
    'Existiert':        'Esiste già un amico con questo nome. Scegli un nuovo nome.',
    'ZuLang':           'Il nome che hai scelto è troppo lungo. Scegli un nome con un massimo di 30 caratteri.',
    'PasswortKurz':     'La password deve essere lunga almeno 12 caratteri.',
    'PasswortUnsicher': 'La password deve contenere almeno una lettera maiuscola, una lettera minuscola, un numero e un carattere speciale ed essere lunga almeno 12 caratteri.',
    'Löschen':          'Sei sicuro che debba essere cancellato ?',
    'Lösche':           'Eliminare',
    'Import':           'Importa l\'elenco degli amici',
    'Export':           'Esporta elenco amici',
    'Welcome':          'Benvenuto!',
    'Handy':            'Inserisci un numero di cellulare valido',
    'SMSSenden':        'Invia SMS',
    'TextNickname':     'Per prima cosa inserisci un testo (e scegli un amico da crittografare)',
    'Textfeld':         'Testo/Chiffre',
    'EmojisON':         'Emoji abilitati',
    'EmojisOFF':        'Emoji disabilitati',
  },
};


//#########################################################################################
//#                      Sprachelement heraussuchen
//#########################################################################################
String Sprachelement(String key)
{
  return Sprachelemente[Sprache]?[key] ?? key;
}


//#########################################################################################
//#                  Sprache für Dialoge und Schaltflächen wechseln
//#########################################################################################
void Sprachauswahl(String LanguageCode)
{
  setState(()
  {
    Sprache = LanguageCode;
  });
}


//#########################################################################################
//#                  Ermittelt die System-Sprache
//#########################################################################################
void SpracheErmitteln()
{
  //Aktuellen languageCode ermitteln
  final String languageCode = ui.window.locale.languageCode;

  //Liste der unterstützten Sprachen
  const List<String> supportedLanguages = ['de', 'en', 'es', 'fr', 'it'];

  //Überprüfen, ob der aktuelle languageCode in der Liste der unterstützten Sprachen ist
  if(supportedLanguages.contains(languageCode)) { Sprache = languageCode; }
  else { Sprache = 'en'; }
}


//#########################################################################################
//#                  Einfache Methode für Fehlermeldungen
//#########################################################################################
void Message(String This)
{
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        decoration: BoxDecoration(
          color: AppBarColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          This,
          style: TextStyle(color: Textfarbe),
        ),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}


//#########################################################################################
//#                     Holt Zwischenablage in das Textfeld
//#########################################################################################
void FetchClipboardText() async
{
  ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  if(clipboardData != null && clipboardData.text != null)
  {
    setState(() { Textfeld.text = clipboardData.text!.trim(); });
  }
}


//#########################################################################################
//#                       Wählt ein zufälliges Thema aus
//#########################################################################################
void ZufallsHintergrund()
{
  final random = Random();
  setState(() { Hintergrundbild = Hintergrundbilder[random.nextInt(Hintergrundbilder.length)]; });
}


//######################################################################################################
//#                             E-Mail senden
//######################################################################################################
void SendeEmail(String to, String subject, String body) async
{
  String url = 'mailto:$to?subject=$subject&body=$body';
  await launch(url);
}


//######################################################################################################
//#                         E-Mail-Adresse prüfen
//######################################################################################################
bool EmailAdresseOK(String Email)
{
  //Regulärer Ausdruck für die E-Mail-Validierung
  final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',);
  return regex.hasMatch(Email);
}


//######################################################################################################
//#                   Sendet eine Nachricht per SMS
//######################################################################################################
void SendeSms(String Handynummer, String Nachricht) async
{
  //Die URL zur SMS-Nachricht
  final Uri smsUri = Uri.parse('sms:$Handynummer?body=$Nachricht');
    
  //Überprüfen, ob die URL gestartet werden kann
  if(await canLaunch(smsUri.toString()))
  {
    await launch(smsUri.toString());
  }
}


//######################################################################################################
//#              Den Country-Code aus einer Daten-Rune rausrechnen
//######################################################################################################
int Akzentkorrektur(int Rune)
{
  //if(Rune == 0x1F92E) return 0x1F92E - 0x08; //Kotzender Smiley
  //if(Rune == 0x1F4A9) return 0x1F4A9 - 0x16; //Poop-Haufen
  if(Rune >= 0x1F600) return 0x1F600;        //Emoticons
  if(Rune >= 0x17300) return 0x17300;        //Chinese Tangut (mostly bad)
  if(Rune >= 0x17000) return 0x17000;        //Chinese Tangut (mostly good)
  if(Rune >= 0x16900) return 0x16900;        //Bamum Schriftzeichen
  if(Rune >= 0x14400) return 0x14400;        //Anatolische Schriftzeichen
  if(Rune >= 0x13000) return 0x13000;        //Ägyptische Hieroglyphen
  if(Rune >= 0x12000) return 0x12000;        //Sumerische Schriftzeichen
  if(Rune >= 0x10600) return 0x10600;        //Minoische Schriftzeichen (Linear A Schrift von Kreta)
  if(Rune >= 0xF900)  return 0xF900;         //Chinesische Kompatibilität
  if(Rune >= 0xAD00)  return 0xAD00;         //Korean (evil)
  if(Rune >= 0xAC00)  return 0xAC00;         //Koreanische Schriftzeichen
  if(Rune >= 0xA000)  return 0xA000;         //Yi-Silbenzeichen
  if(Rune >= 0x5200)  return 0x5200;         //Chinesische Schriftzeichen (Gefühle, Schönheit..)
  if(Rune >= 0x5100)  return 0x5100;         //Chinesische Schriftzeichen (Hindernisse, Konflikte..)
  if(Rune >= 0x4E00)  return 0x4E00;         //Chinesische Schriftzeichen (regulär)
  if(Rune >= 0x3400)  return 0x3400;         //Chinesische Schriftzeichen (selten)
  if(Rune >= 0x3200)  return 0x3200;         //Chinesischer Telegraph
  if(Rune >= 0x2800)  return 0x2800;         //Braille Patterns (Blindenschrift)
  if(Rune >= 0x2200)  return 0x2200;         //Mathematical Expressions
  if(Rune >= 0x1100)  return 0x1100;         //Hangul Jamo Schriftzeichen
  if(Rune >= 0x600)   return 0x600;          //Arabische Schriftzeichen
  if(Rune >= 0x400)   return 0x400;          //Russische Schriftzeichen
  return(0);
}


//######################################################################################################
//# Chiffrierte Zeichen werden der Länderauswahl entsprechend im Unicode hochgesetzt
//######################################################################################################
int Verzierung(int Rune)
{
  //Wenn keine Emoticons erwünscht sind, nur den Style verwenden..
  if(EnableSmileys == false) { return Rune + Style; }

  //Den roten Teufel ersetzen wir durch einen kotzenden Emoji
  //if(Rune == 0x08) { return 0x1F92E; }
  if(Rune == 0x08) { return Rune + Style; }

  //Den bestürzten Emoji ersetzen wir durch einen Poop-Haufen
  //if(Rune == 0x16) { return 0x1F4A9; }
  if(Rune == 0x16) { return Rune + Style; }

  //Zeichen von 0..0x1D werden als Emojis dargestellt (ohne den roten Teufel)
  if(Rune < 0x1E) { return Rune + 0x1F600; }

  //Ansonsten entsprechend der Symbolik chiffrieren
  return Rune + Style;
}


//######################################################################################################
//#         Text in der gewählten Sprache kodieren und Emojis einbetten
//######################################################################################################
String Hochsetzen(String Text)
{
  StringBuffer output = StringBuffer();
  for (int Rune in Text.runes)
  {
    output.writeCharCode(Verzierung(Rune));
  }
  return output.toString();
}


//######################################################################################################
//#            Frisierten Text wieder ins Byte-Chiffre zurückverwandeln
//######################################################################################################
String Hinabsetzen(String Text)
{
  StringBuffer output = StringBuffer();
  for (int Rune in Text.runes)
  {
    output.writeCharCode(Rune - Akzentkorrektur(Rune));
  }
  return output.toString();
}


//#########################################################################################
//#                   Extrahiert die Daten aus dem Textfeld
//#########################################################################################
bool Parser()
{
  //Leerstellen an Anfang und Ende entfernen!
  Textfeld.text.trim();

  //Den Text an den Zeilenumbrüchen splitten
  List<String> Zeilen = Textfeld.text.split("\n");

  //Nur weitermachen, wenn mindestens 3 Zeilen!
  if(Zeilen.length < 3) { return false; }

  //Suche nach einem "gefreakten Benutzernamen" in der Zeilenliste (die erste und letzte Zeile dabei überspringen, weil die können es nicht sein!)
  for(int i = 1; i < Zeilen.length - 1; i++)
  {
    //Benutzernamen sind nicht mehr als 30 Zeichen lang!
    if(Zeilen[i].runes.length <= Namensbegrenzung)
    {
      //Annehmen, die aktuelle Zeile sei ein Benutzername  
      String Benutzername = Hinabsetzen(Zeilen[i].trim());

      //Alle Benutzer in der Benutzerliste durchsuchen ->
      for(var user in Benutzerliste)
      {
        //Gibt es eine Übereinstimmung?
        if(Benutzername == user['username'])
        {
          //Daten übernehmen (wird gleich dechiffriert)
          setState(()
          {
            PrivateKey    = user['password']!;
            PublicKey     = Hinabsetzen(Zeilen[i + 1].trim());  
            Textfeld.text = Zeilen[i - 1].trim();
            Title         = Benutzername;
          });
          return true;
        }
      }
    }
  }
  //Keine Autodetection ? Dann false zurückgeben..
  return false;
}


//#########################################################################################
//#                  Popup-Menü für die Style-Auswahl
//#########################################################################################
void ShowStyleMenu()
{
  showMenu(
    context: context,
    position: RelativeRect.fill,
    items: [
      PopupMenuItem<int>(
        value: 0,
        child: Text('Neutral'),
      ),
      PopupMenuItem<int>(
        value: 0x400,
        child: Text('Russian'),
      ),
      PopupMenuItem<int>(
        value: 0x600,
        child: Text('Arabean'),
      ),
      PopupMenuItem<int>(
        value: 0x3400,
        child: Text('Chinese (rare)'),
      ),
      PopupMenuItem<int>(
        value: 0x4E00,
        child: Text('Chinese (common)'),
      ),
      PopupMenuItem<int>(
        value: 0x5200,
        child: Text('Chinese (Happiness, Harmony, Peace and Prosperity)'),
      ),
      PopupMenuItem<int>(
        value: 0x5100,
        child: Text('Chinese (Conflicts and obstacles)'),
      ),
      PopupMenuItem<int>(
        value: 0xA000,
        child: Text('Yi(Feng Shui)-Symbols'),
      ),
      PopupMenuItem<int>(
        value: 0xAC00,
        child: Text('Korean'),
      ),
      PopupMenuItem<int>(
        value: 0xAD00,
        child: Text('Korean'),
      ),
      PopupMenuItem<int>(
        value: 0x1100,
        child: Text('Hangul Jamo'),
      ),
      PopupMenuItem<int>(
        value: 0x2200,
        child: Text('Mathematical Expressions'),
      ),
      PopupMenuItem<int>(
        value: 0x2800,
        child: Text('Braille Patterns'),
      ),
      PopupMenuItem<int>(
        value: 0x12000,
        child: Text('Sumerian'),
      ),
      PopupMenuItem<int>(
        value: 0x13000,
        child: Text('Hieroglyphs (where available!)'),
      ),
      PopupMenuItem<int>(
        value: 0x14400,
        child: Text('Anatolian (where available!)'),
      ),
      PopupMenuItem<int>(
        value: 0x16900,
        child: Text('Bamum Symbols (where available!)'),
      ),
      PopupMenuItem<int>(
        value: 0x17000,
        child: Text('Chinese Tangut (mostly good)'),
      ),
      PopupMenuItem<int>(
        value: 0x17300,
        child: Text('Chinese Tangut (mostly bad)'),
      ),
      PopupMenuItem<int>(
        value: 0x3200,
        child: Text('Chinese Telegraph'),
      ),
      PopupMenuItem<int>(
        value: 0xF900,
        child: Text('Chinese (Kompatibility)'),
      ),
      PopupMenuItem<int>(
        value: 0x10600,
        child: Text('Minoan from Crete (where available!)'),
      ),
    ],
  ).then((value) {
    if (value != null)
    {
      setState(() { Style = value; });
    }
  });
}


//#########################################################################################
//#         Zeigt einen Dialog zum Hinzufügen eines Benutzers
//#########################################################################################
void ShowAddUserDialog()
{
  final TextEditingController newUsernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppBarColor,
        title: Text(Sprachelement('NeuerBuddy'), style: TextStyle(color: Textfarbe)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newUsernameController,
              decoration: InputDecoration(labelText: Sprachelement('Name'), labelStyle: TextStyle(color: Textfarbe) ),
              style: TextStyle(color: Textfarbe),
            ),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: Sprachelement('Passwort'), labelStyle: TextStyle(color: Textfarbe) ),
              style: TextStyle(color: Textfarbe),
              obscureText: false,
            ),
            //Button zum Generieren eines starken Passworts
            ElevatedButton(
              onPressed: () {
                newPasswordController.text = StarkesPasswort(21);
              },
              child: Text(Sprachelement('PasswortStark')),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(Sprachelement('Zurück'), style: TextStyle(color: Textfarbe)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(Sprachelement('Hinzufügen'), style: TextStyle(color: Textfarbe)),
            onPressed: () {
              if(newUsernameController.text.isNotEmpty &&
                 newPasswordController.text.isNotEmpty) {

                //Benutzernamen dürfen keine Leerzeichen enthalten, weil der Import sonst nicht klappt!
                newUsernameController.text = newUsernameController.text.replaceAll(' ', '');

                //Benutzername prüfen, ob er bereits existiert
                bool userExists     = Benutzerliste.any((user) => user['username'] == newUsernameController.text.trim());
                String Benutzername = newUsernameController.text.trim();
                String Passwort     = newPasswordController.text.trim();

                if(userExists)
                {
                  //Snackbar anzeigen, wenn der Benutzername bereits existiert
                  Message(Sprachelement('Existiert'));
                }
                else
                {
                  //Benutzernamen sollen nicht so unfassbar lang sein!
                  if(Benutzername.runes.length > Namensbegrenzung)
                  {
                    Message(Sprachelement('ZuLang'));
                  }
                  else
                  {
                    //Passworteingabe prüfen und fortfahren:
                    if(SicheresPasswort(Passwort))
                    {
                      //Benutzer zur Liste hinzufügen, wenn der Benutzername neu ist
                      setState(() {
                        Benutzerliste.add({
                          'username': Benutzername,
                          'password': Passwort,
                        });
                        //Neuen Buddy sofort auswählen
                        User       = Benutzername;
                        PrivateKey = Passwort;
                        Title      = User;
                      });
                      Navigator.of(context).pop();
                    }
                  }
                }
              }
            },
          ),
        ],
      );
    },
  );
}


//######################################################################################################
//#                     Absolut bester Zufallsgenerator
//######################################################################################################
int Zufall(int Spektrum)
{
  //Momentanzustand des Passworts bestimmen
  for(int i = 0; i < PasswortLength;   i++) { Hash ^= Passwort[i]; }
  for(int i = 0; i < DimensionenTotal; i++) { Hash ^= Index[i];    }

  //Pseudo-Zufallszahl zurückgeben..
  return Hash % Spektrum;
}


//######################################################################################################
//#                      Holt den nächsten Wert vom Passwort
//######################################################################################################
int Wert()
{
  //Multidimensionalen Vektor-Hash ausrechnen
  for(int i = 0; i < Dimensionen; i++)
  {
    int A = Index[i] % PasswortLength;
    Hash ^= Passwort[A];
    Passwort[A] = (Passwort[A] + Hash) & 255;
    Index[i]    = (Index[i]    + Hash) & 255;
  }
  return Hash;
}


//#########################################################################################
//#                           ALGORITHMUS ALTERN LASSEN
//#########################################################################################
void Weisheit()
{
  //Immer beiläufig Werte ziehen, um den ganzen Vorgang zu vertuschen
  while(Wert() > 127)
  {
    //Die Dimensionen ändern sich dabei von Zeit zu Zeit
    int Rahmen = DimensionenTotal - 3;
    Dimensionen = DimensionenTotal - (Hash % Rahmen);
  }
}


//#########################################################################################
//#                   Liest Werte, bis ungleich Null erscheint
//#########################################################################################
int NichtNull()
{
  int Charme = 0; while(Charme == 0) { Weisheit(); Charme = Wert(); }
  return Charme;
}


//##########################################################################################
//#                 Das Passwort ändert ständig seine Länge
//##########################################################################################
void Metamorphose()
{
  //Soll das Passwort in der Größe zunehmen ?
  if(PasswortSchrumpfen == false)
  {
    if(PasswortLength < PasswortMaximum) { Passwort[PasswortLength] = NichtNull(); PasswortLength++; }
    else                                 { PasswortSchrumpfen = true; PasswortMinimum = 123 + Zufall(64); }
  }

  //Soll das Passwort wieder zurückschrumpfen ?
  if(PasswortSchrumpfen == true)
  {
    if(PasswortLength > PasswortMinimum) { PasswortLength -= Wert() % 21; Weisheit(); }
    else                                 { PasswortSchrumpfen = false; PasswortMaximum = 256 - Zufall(64); }
  }
}


//#########################################################################################
//#                Hier steckt die eigentliche Chiffre-Routine drin
//#########################################################################################
int Berechnung(int Rune)
{
  //Die Passwortlänge ist unbekannt und variabel und daher auch die Schleifenzahl:
  for(int a = 0; a < PasswortLength; a++)
  {
    //Rune wird fortwährend verschlüsselt/entschlüsselt
    Rune ^= NichtNull();

    //Das Passwort verwandelt sich andauernd
    Metamorphose();
  }
  //Fertige Rune zurückgeben..
  return Rune;
}


//######################################################################################################
//#         Runen des Passworts und der Dimensionen
//######################################################################################################
void Initialisierung(String Key)
{
  PasswortLength     = Key.runes.length;
  DimensionenTotal   = PasswortLength;
  Dimensionen        = PasswortLength;
  Hash               = PasswortLength;
  PasswortSchrumpfen = false;
  PasswortMaximum    = 256;
  Passwort.setRange(0, PasswortLength, Key.runes.toList());
  Index.setRange(0, PasswortLength, Passwort);
}


//######################################################################################################
//#                         Verschlüsseln/Entschlüsseln
//######################################################################################################
String Chiffre(String Quelle)
{
  //Masterpasswort & Algorithmus vorbereiten
  Initialisierung(PrivateKey + PublicKey);

  //Umwandlung des Textes in ein Array von Runen
  List<int> Runes = Quelle.runes.toList();

  //Kurze Nachrichten werden öfter verschlüsselt (lange Nachrichten min. 3x)
  int Windings = (543 ~/ Runes.length) + Zufall(13); if(Windings < 3) { Weisheit(); Windings = 3 + Zufall(7); }

  //Beginne mit den Runen, die übergeben wurden (und arbeite sie immer wieder komplett durch)
  for(int w = 0; w < Windings; w++)
  {
    for(int i = 0; i < Runes.length; i++)
    { 
      Runes[i] = Berechnung(Runes[i]); 
    }
  }
  //Fertigen Text/Chiffre zurückgeben..
  return String.fromCharCodes(Runes);
}


//##########################################################################################
//#                  Erzeugt ein sehr starkes Passwort
//##########################################################################################
String StarkesPasswort(int Size)
{
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789°!@#%^&*(),.?":{}|<>';
  Random random = Random.secure();
  return List.generate(Size, (index) => chars[random.nextInt(chars.length)]).join();
}


//######################################################################################################
//#             Testet, ob ein Passwort stark genug ist
//######################################################################################################
bool SicheresPasswort(String Password)
{
  //Nur weitermachen, wenn das Passwort nicht leer ist!
  if(Password.isEmpty) { return false; }

  //Nur weitermachen, wenn das Passwort lang genug ist!
  if(Password.length < 21) { Message(Sprachelement('PasswortKurz')); return false; }

  //Teilbedingungen für das Passwort
  bool hasLowercase        = Password.contains(RegExp(r'[a-z]'));
  bool hasUppercase        = Password.contains(RegExp(r'[A-Z]'));
  bool hasDigit            = Password.contains(RegExp(r'[0-9]'));
  bool hasSpecialCharacter = Password.contains(RegExp(r'[°!@#%^&*(),.?":{}|<>]'));

  //Die Bedingung ist erst erfüllt, wenn alle Teilbedingunen erfüllt sind
  bool Safe = hasLowercase && hasUppercase && hasDigit && hasSpecialCharacter;

  //Wenn noch etwas offen ist, gibt es eine Fehlermeldung!
  if(Safe == false) { Message(Sprachelement('PasswortUnsicher')); }

  //Passwort ist gültig, wenn alle Bedingungen erfüllt sind
  return Safe;
}


//######################################################################################################
//#             Funktion zum Anzeigen des Löschen-Bestätigungsdialogs
//######################################################################################################
void ShowDeleteConfirmationDialog(BuildContext context, int index, String username)
{
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppBarColor,
        title: Text(username, style: TextStyle(color: Textfarbe)),
        content: Text(Sprachelement('Löschen'), style: TextStyle(color: Textfarbe)),
        actions: [
          TextButton(
            child: Text(Sprachelement('Abbrechen'), style: TextStyle(color: Textfarbe)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(Sprachelement('Lösche'), style: TextStyle(color: Textfarbe)),
            onPressed: () {
              setState(() {
                Benutzerliste.removeAt(index);
                if (User == username) {
                  User = '';
                  PrivateKey = '';
                  Title = '';
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


//######################################################################################################
//#                         Zeigt den Hilfe-Dialog
//######################################################################################################
void ShowHelpDialog() async
{
  String HilfeAsset = 'assets/Hilfe/Hilfe_${Sprache}.txt';
  String Hilfetext  = await rootBundle.loadString(HilfeAsset);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppBarColor,
        title: Text(Sprachelement('Welcome'), style: TextStyle(color: Textfarbe)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(height: 10),
              Text(Hilfetext, style: TextStyle(color: Textfarbe)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok', style: TextStyle(color: Textfarbe)),
            onPressed: () { Navigator.of(context).pop(); },
          ),
        ],
      );
    },
  );
}


//######################################################################################################
//#             Funktion zum Anzeigen des Dialogs zur Passwortänderung
//######################################################################################################
void ShowChangePasswordDialog(String username, String currentPassword, int index)
{
  final TextEditingController newPasswordController = TextEditingController();

  //Vorbelegen des Passworts
  newPasswordController.text = currentPassword;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppBarColor,
        title: Text(
          '$username',
          style: TextStyle(color: Textfarbe),
        ),
        content: TextField(
          controller: newPasswordController,
          decoration: InputDecoration(
            labelText: Sprachelement('PasswortÄndern'),
            labelStyle: TextStyle(color: Textfarbe),
          ),
          obscureText: false,
          style: TextStyle(color: Textfarbe),
        ),
        actions: [
          //Button zum Generieren eines starken Passworts
          ElevatedButton(
            onPressed: () {
              newPasswordController.text = StarkesPasswort(21);
            },
            child: Text(Sprachelement('PasswortStark')),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(ButtonColor),
              foregroundColor: MaterialStateProperty.all(Textfarbe),
            ),
          ),
          TextButton(
            child: Text(
              Sprachelement('Abbrechen'),
              style: TextStyle(color: Textfarbe),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              Sprachelement('Übernehmen'),
              style: TextStyle(color: Textfarbe),
            ),
            onPressed: () {
              if(newPasswordController.text.isNotEmpty)
              {
                if(SicheresPasswort(newPasswordController.text.trim()))
                {
                  setState(() {
                    PrivateKey = Benutzerliste[index]['password'] = newPasswordController.text.trim();
                  });
                  Navigator.of(context).pop();
                  Message('Password for $username updated !');
                }
              }
            },
          ),
        ],
      );
    },
  );
}


//#########################################################################################
//#          Ermittelt die durchschnittliche Farbe eines Bildes
//#########################################################################################
Future<Color> Bildfarbe(String Dateiname) async
{
  //Lade das Bild als Byte-Daten
  final ByteData data = await rootBundle.load(Dateiname);
  final Uint8List bytes = data.buffer.asUint8List();

  //Dekodiere die Bilddaten
  img.Image? image = img.decodeImage(bytes);
  if(image == null) return Colors.black;

  //Summiere die RGB-Werte aller Pixel
  int totalR = 0, totalG = 0, totalB = 0;
  int pixelCount = image.width * image.height;

  for (int y = 0; y < image.height; y++)
  {
    for (int x = 0; x < image.width; x++)
    {
      var pixel = image.getPixel(x, y);
      totalR += pixel.r.toInt();
      totalG += pixel.g.toInt();
      totalB += pixel.b.toInt();
    }
  }
  //Berechne den Durchschnitt der RGB-Werte
  int avgR = (totalR / pixelCount).round();
  int avgG = (totalG / pixelCount).round();
  int avgB = (totalB / pixelCount).round();

  //Rückgabe der mittleren Farbe als Flutter-Color
  return Color.fromARGB(255, avgR, avgG, avgB);
}


//#########################################################################################
//#                 Berechnet die Helligkeit einer Farbe neu
//#########################################################################################
Color FarbeSkalieren(Color Farbe, int scale)
{
  //RGB-Werte der Farbe extrahieren
  int r = Farbe.red;
  int g = Farbe.green;
  int b = Farbe.blue;

  //RGB-Werte mit dem Skalierungsfaktor multiplizieren
  r = (r * scale / 100).clamp(0, 255).toInt();
  g = (g * scale / 100).clamp(0, 255).toInt();
  b = (b * scale / 100).clamp(0, 255).toInt();

  //Neue Farbe zurückgeben
  return Color.fromARGB(Farbe.alpha, r, g, b);
}


//#########################################################################################
//#              Berechnet die Helligkeit einer Farbe in Prozent
//#########################################################################################
int Helligkeit(Color Farbe)
{
  return (Farbe.red + Farbe.green + Farbe.blue) * 100 ~/ 768;
}


//#########################################################################################
//#         Hänge Bildfarbe und die Komplementärfarbe am Theme fest
//#########################################################################################
void SetzeFarben(String Bildpfad) async
{
  Color Farbe1 = await Bildfarbe(Bildpfad);
  Color Farbe2;

  //Wenn die Helligkeit größer als 50% ist, setze Farbe2 dunkler, sonst heller
  if(Helligkeit(Farbe1) > 50) { Farbe2 = FarbeSkalieren(Farbe1, 11); } else { Farbe2 = FarbeSkalieren(Farbe1, 500); }

  //Setze die App-Variablen für die Farben neu
  setState(() {
    AppBarColor = Farbe1;
    ButtonColor = Farbe1;
    Textfarbe   = Farbe2;
  });
}


//######################################################################################################
//#         Funktion zum Anzeigen des Dialogs zur GUI-Thema-Änderung
//######################################################################################################
void ShowThemeMenu()
{
  showMenu(
    context: context,
    position: RelativeRect.fill,
    items: Hintergrundbilder.map((imagePath) {
      return PopupMenuItem<String>(
        value: imagePath,
        child: Container(
          color: AppBarColor,
          child: Row(
            children: [
              Image.asset(imagePath, width: 128, height: 128),
            ],
          ),
        ),
      );
    }).toList(),
    elevation: 8.0,
    color: AppBarColor,
  ).then((selectedImage) {
    if (selectedImage != null) {
      setState(() {
        Hintergrundbild = selectedImage;
        SetzeFarben(selectedImage);
      });
    }
  });
}


//######################################################################################################
//#                 Exportiert die Benutzerliste ins Textfeld
//######################################################################################################
void ExportUserListToTextField()
{
  StringBuffer Buffer = StringBuffer();
  for(var user in Benutzerliste)
  {
    Buffer.writeln('${user['username']}, ${user['password']}');
  }
  //Setze die Benutzerliste in das Textfeld und in die Zwischenablage
  setState(() { Textfeld.text = Buffer.toString(); isEncrypted = false; });
}


//######################################################################################################
//#               Importiert die Benutzerliste aus dem Textfeld
//######################################################################################################
void ImportUserListFromTextField()
{
  String content = Textfeld.text.trim();

  //Zähler für die geupdateten/hinzugefügten Benutzer
  int Count = 0;

  //Splitte den Inhalt anhand der Zeilenumbrüche
  List<String> lines = content.split("\n");

  //Für jede Zeile die Benutzerinformationen extrahieren
  for(String line in lines)
  {
    RegExp regExp = RegExp(r'(\w+)\s*,\s*(.+)');
    var match = regExp.firstMatch(line);

    if(match != null && match.groupCount == 2)
    {
      String nickname = match.group(1)!.trim();
      String password = match.group(2)!.trim();
      
      //Überprüfen, ob der Benutzername bereits existiert
      int existingUserIndex = Benutzerliste.indexWhere((user) => user['username'] == nickname);

      //Entweder nur das Passwort übernehmen
      if(existingUserIndex != -1)
      {
        //Benutzername existiert bereits, Passwort aktualisieren
        setState(() { Benutzerliste[existingUserIndex]['password'] = password; });
      }
      else
      {
        //Benutzername existiert noch nicht, daher hinzufügen
        setState(() { Benutzerliste.add({'username': nickname, 'password': password}); });
      }
      //Zähler wird um 1 erhöht
      Count += 1;
    }
  }
  //Am Ende einen Text ausgeben:
  if(Count > 0) { Message('Nicknames $Count updated !'); }
}


//######################################################################################################
//#                     Schreibt Text in die Zwischenablage
//######################################################################################################
void CopyToClipboard(String Text)
{
  Clipboard.setData(ClipboardData(text: Text));
}


//######################################################################################################
//#                     Zeigt den Email-Dialog
//######################################################################################################
void ShowEmailDialog()
{
  final TextEditingController toController      = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppBarColor,
        title: Text(Sprachelement('EmailTitel'), style: TextStyle(color: Textfarbe)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: toController,
              decoration: InputDecoration(
                labelText: Sprachelement('EmailAdresse'),
                labelStyle: TextStyle(color: Textfarbe),
              ),
              style: TextStyle(color: Textfarbe),
            ),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: Sprachelement('EmailBetreff'),
                labelStyle: TextStyle(color: Textfarbe),
              ),
              style: TextStyle(color: Textfarbe),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(context).pop(); },
            child: Text(Sprachelement('Zurück'), style: TextStyle(color: Textfarbe)),
          ),
          TextButton(
            onPressed: () {
              String to = toController.text.trim();
              if(to.isNotEmpty && EmailAdresseOK(to)) {
                SendeEmail(to, subjectController.text.trim(), Textfeld.text.trim());
                Navigator.of(context).pop();
              } else { Message(Sprachelement('EmailFehlt')); }
            },
            child: Text(Sprachelement('EmailSenden'), style: TextStyle(color: Textfarbe)),
          ),
        ],
      );
    },
  );
}


//######################################################################################################
//#                     Zeigt den SMS-Dialog
//######################################################################################################
void ShowSMSDialog()
{
  final TextEditingController phoneController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(Sprachelement('SMSSenden')),
        content: TextField(
          controller: phoneController,
          decoration: InputDecoration(hintText: "Handynummer"),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.of(context).pop(); },
            child: Text(Sprachelement('Zurück')),
          ),
          TextButton(
            onPressed: () {
              String Handynummer = phoneController.text.trim();
              String Nachricht   = Textfeld.text.trim();

              if (Handynummer.isNotEmpty && Nachricht.isNotEmpty)
              {
                SendeSms(Handynummer, Nachricht);
                Navigator.of(context).pop();
              }
              else { Message(Sprachelement('Handy')); }
            },
            child: Text(Sprachelement('SMSSenden')),
          ),
        ],
      );
    },
  );
}


//######################################################################################################
//#            Übersetzt das Textfeld in die gewählte Sprache
//######################################################################################################
Future<void> TranslateText() async
{
  //Übersetze den Text in die gewünschte Sprache
  var Translation = await Translator.translate(Textfeld.text, to: Sprache);

  //Kopiere den übersetzten Text in das Textfeld
  setState(() { Textfeld.text = Translation.text; });
}







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Title, style: TextStyle(color: Textfarbe)),
        backgroundColor: AppBarColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Textfarbe),
            onPressed: ShowAddUserDialog,
          ),
          IconButton(
            icon: Icon(Icons.flag, color: Textfarbe),
            onPressed: ShowStyleMenu,
          ),
          IconButton(
            icon: Icon(Icons.help_outline, color: Textfarbe),
            onPressed: ShowHelpDialog,
          ),
          IconButton(
            icon: Icon(Icons.image, color: Textfarbe),
            onPressed: ShowThemeMenu,
          ),
          IconButton(
            icon: Icon(
              EnableSmileys ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
              color: Textfarbe,
            ),
            onPressed: () {
              setState(() { EnableSmileys = !EnableSmileys; });
              Message(EnableSmileys ? Sprachelement('EmojisON') : Sprachelement('EmojisOFF'));
            },
          ),
          PopupMenuButton<String>(
            onSelected: Sprachauswahl,
            icon: Icon(Icons.language, color: Textfarbe),
            itemBuilder: (BuildContext context)
            {
              return [
                PopupMenuItem(value: 'de', child: Text('Deutsch', style: TextStyle(color: Textfarbe))),
                PopupMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Textfarbe))),
                PopupMenuItem(value: 'es', child: Text('Español', style: TextStyle(color: Textfarbe))),
                PopupMenuItem(value: 'fr', child: Text('Français', style: TextStyle(color: Textfarbe))),
                PopupMenuItem(value: 'it', child: Text('Italiano', style: TextStyle(color: Textfarbe))),
              ];
            },
            color: AppBarColor,
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: Textfarbe),
            onSelected: (value) {
              if (value == 1) {
                ExportUserListToTextField();
              } else if (value == 2) {
                ImportUserListFromTextField();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                value: 1,
                child: Text(Sprachelement('Export'), style: TextStyle(color: Textfarbe)),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text(Sprachelement('Import'), style: TextStyle(color: Textfarbe)),
              ),
            ],
            color: AppBarColor,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Hintergrundbild),
            fit: BoxFit.cover,
          ),
        ),
/*
        decoration: BoxDecoration(
          image: (HintergrundDownload != null)
              ? DecorationImage(
                  image: MemoryImage(HintergrundDownload!),
                  fit: BoxFit.cover,
                )
              : DecorationImage(
                  image: AssetImage(Hintergrundbild),
                  fit: BoxFit.cover,
                ),
        ),
*/
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: Benutzerliste.length,
                itemBuilder: (context, index) {
                  String username = Benutzerliste[index]['username']!;
                  bool isSelected = username == User;
                  return Container(
                    color: isSelected
                        ? Colors.red.withOpacity(0.8)
                        : Colors.black.withOpacity(0.2),
                    child: ListTile(
                      title: Text(
                        Benutzerliste[index]['username']!,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: ()
                        {
                          ShowDeleteConfirmationDialog(context, index, username);
                        },
                      ),
                      onTap: ()
                      {
                        if(Benutzerliste.isNotEmpty)
                        {
                          if(username == User)
                          {
                            ShowChangePasswordDialog(username, Benutzerliste[index]['password']!, index);
                          }
                          else
                          {
                            //Selektierten Buddy jetzt annehmen
                            setState(() {
                              User       = Benutzerliste[index]['username']!;
                              PrivateKey = Benutzerliste[index]['password']!;
                              Title      = User;
                            });
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            //TextField in einem Container ohne Scroll, um die Höhe zu begrenzen
            Container(
              height: 300,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: TextField(
                      controller: Textfeld,
                      focusNode: Fokus,
                      decoration: InputDecoration(
                        labelText: Sprachelement('Textfeld'),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.65),
                      ),
                      style: TextStyle(fontSize: FontSize),
                      minLines: 10,
                      maxLines: null,
                      onTap: () { Fokus.requestFocus(); },
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            CopyToClipboard(Textfeld.text);
                            Message('Text copied to clipboard');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.paste),
                          onPressed: () async {
                            FetchClipboardText();
                            Fokus.requestFocus();
                            isEncrypted = false;
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Fokus.requestFocus();
                            setState(() {
                              Textfeld.clear();
                              isEncrypted = false;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () { if(Textfeld.text.isNotEmpty) ShowEmailDialog(); },
                        ),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () { if(Textfeld.text.isNotEmpty) ShowSMSDialog(); },
                        ),
                        IconButton(
                          icon: Icon(Icons.translate),
                          onPressed: () { if(Textfeld.text.isNotEmpty) TranslateText(); },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Slider zur Anpassung der Schriftgröße
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: ButtonColor,
                    inactiveTrackColor: Colors.yellow[200],
                    thumbColor: ButtonColor,
                    overlayColor: Colors.red.withOpacity(0.2),
                    valueIndicatorColor: ButtonColor,
                  ),
                  child: Slider(
                    value: FontSize,
                    min: 16.0,
                    max: 40.0,
                    divisions: 30,
                    label: FontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        FontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            //Buttons zum chiffrieren/dechiffrieren
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    //Dafür werden der Text, der Benutzername und sein/ihr Passwort benötigt!
                    if(isEncrypted == false && Textfeld.text.isNotEmpty && User.isNotEmpty && PrivateKey.isNotEmpty)
                    {
                      //Öffentlichen Schlüssel generieren
                      PublicKey = StarkesPasswort(7);

                      //Fertiges Chiffre erzeugen
                      Textfeld.text = Hochsetzen(Chiffre(Textfeld.text.trim())) + '\r\n' + Hochsetzen(User) + '\r\n' + Hochsetzen(PublicKey);

                      //Chiffre in die Zwischenablage kopieren, fertig..
                      CopyToClipboard(Textfeld.text);

                      //Vermerken, daß schon verschlüsselt wurde, damit man nicht zweimal draufdrücken kann!
                      isEncrypted = true;
                    }
                    else
                    {
                      if(isEncrypted == false) { Message(Sprachelement('TextNickname')); }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(ButtonColor),
                    foregroundColor: MaterialStateProperty.all(Textfarbe),
                  ),
                  child: Text(Sprachelement('Chiffrieren')),
                ),
                ElevatedButton(
                  onPressed: () {
                    //Wenn dies ein bekannter Chiffre-Typ ist und Benutzername und Passwort erkannt wurden:
                    if(Parser())
                    {
                      //Dechiffrierte Originalschrift im Fenster anzeigen
                      Textfeld.text = Chiffre(Hinabsetzen(Textfeld.text));

                      //Vermerken, daß der Text jetzt wieder unverschlüsselt ist!
                      isEncrypted = false;
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(ButtonColor),
                    foregroundColor: MaterialStateProperty.all(Textfarbe),
                  ),
                  child: Text(Sprachelement('Dechiffrieren')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
//Ende LoveSpeech ##########################################################################