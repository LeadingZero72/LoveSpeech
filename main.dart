import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';


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

  List<Map<String, String>> Benutzerliste = []; //Liste für Benutzernamen und Passwörter
  String Hintergrundbild = '';                  //Variable für das gewählte Hintergrundbild
  String User = '';                             //Variable zum Speichern des ausgewählten Benutzers
  String PublicKey = '';                        //Variable für den öffentlichen Schlüssel während des Chiffrierens/Dechiffrierens
  String PrivateKey = '';                       //Variable für den privaten Schlüssel während des Chiffrierens/Dechiffrierens
  String Title = 'LoveSpeech 1.0 copyright 2006-2025 Alexander Graf (LeadingZero78@gmail.com)'; //Variable für den angezeigten Titel in der AppBar
  List<int> Passwort = [];                      //256 Byte langes Passwort während des Chiffrierens/Dechiffrierens
  List<int> PasswortAlgorithmen = [];           //256 Byte lange Liste mit Passwort-Indizes
  int    PasswortIndex = 0;                     //Variable für den Passwort-Index während des Chiffrierens/Dechiffrierens
  int    PasswortAlgorithmus = 0;               //Variable für die Indexwahl (1 aus 256 möglichen Passwort-Algorithmen) während des Chiffrierens/Dechiffrierens
  int    PasswortCountdown = 0;                 //Variable für den Indexwahl-Countdown während des Chiffrierens/Dechiffrierens
  int    Countrycode = 0x2800;                  //Unicode-Auswahl beim Chiffrieren/Dechiffrieren
  double FontSize = 40.0;                       //Schriftgröße im Textfeld (default 16)
  bool   EnableSmileys = true;                  //Smileys bei der Verschlüsselung standardmäßig aktivieren
  int    Namensbegrenzung = 30;                 //Namen sollen nicht zu pompös werden!
  bool   isEncrypted = false;                   //Text bisher noch unverschlüsselt.
  String Sprache = 'de';                        //Aktuelle GUI-Sprache

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
  ];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ZufallsHintergrund();
    SetzeFarben(Hintergrundbild);
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
  },
  'de':
  {
    'Chiffrieren':      'Verschlüsseln',
    'Dechiffrieren':    'Entschlüsseln',
    'Zurück':           'Zurück',
    'Hinzufügen':       'Hinzufügen',
    'EmailTitel':       'Chiffre als EMail versenden',
    'EmailAdresse':     'EMail-Empfänger',
    'EmailBetreff':     'Betreff (optional)',
    'EmailFehlt':       'Bitte eine gültige EMail-Adresse eingeben',
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
//#                  Sprache für Sprachausgaben wechseln
//#########################################################################################
void Sprachauswahl(String lang)
{
  setState(()
  {
    Sprache = lang;
  });
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
  //Wenn keine Emoticons erwünscht sind, nur den Countrycode verwenden..
  if(EnableSmileys == false) { return Rune + Countrycode; }

  //Den roten Teufel ersetzen wir durch einen kotzenden Emoji
  //if(Rune == 0x08) { return 0x1F92E; }
  if(Rune == 0x08) { return Rune + Countrycode; }

  //Den bestürzten Emoji ersetzen wir durch einen Poop-Haufen
  //if(Rune == 0x16) { return 0x1F4A9; }
  if(Rune == 0x16) { return Rune + Countrycode; }

  //Zeichen von 0..0x1D werden als Emojis dargestellt (ohne den roten Teufel)
  if(Rune < 0x1E) { return Rune + 0x1F600; }

  //Ansonsten entsprechend der Symbolik chiffrieren
  return Rune + Countrycode;
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
      setState(() { Countrycode = value; });
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


//##########################################################################################
//#                 Wählt einen neuen Passwort-Index-Algorithmus
//##########################################################################################
int AlgorithmusWechsel = 0;
int Chiffrierungen = 0;
int Picks = 0;

void AlgorithmusWahl()
{
  //Erst weitermachen, wenn die richtige Zeit gekommen ist !
  PasswortCountdown -= 1; if(PasswortCountdown > 0) { return; }

  //Jetzt den bisherigen Passwort-Index zurückschreiben!
  PasswortAlgorithmen[PasswortAlgorithmus] = PasswortIndex;

  //Countdown für einen kurzen Moment auf unendlich setzen, um Rekursion zu vermeiden (weil ich Pick() benutze, um neue Werte zu bekommen)
  PasswortCountdown = 999;

  //Neuen Algorithmus auswählen
  PasswortAlgorithmus = Pick() % PasswortAlgorithmen.length;

  //Neuen Countdown festlegen
  PasswortCountdown = (Pick() & 7) + 7;

  //Neuen Countdown aus dem Passwort gewinnen
//  PasswortCountdown = (Passwort[(PasswortIndex + Passwort[PasswortIndex]) % Passwort.length] & 7) + 7;

  //Neuen Algorithmus aus dem Passwort auswählen
//  PasswortAlgorithmus = Passwort[(PasswortIndex + PasswortAlgorithmus) % Passwort.length] % PasswortAlgorithmen.length;

  //Passwort-Index aus einer anderen Zeit wieder rauskramen
  PasswortIndex = PasswortAlgorithmen[PasswortAlgorithmus] % Passwort.length;

  //Das Passwort verlängern und die Algorithmen erweitern, solange bis voll!
  if(Passwort.length < 256)
  {
    //Zeichen auswählen und hinten anhängen (Hier entsteht Rekursion, weil Pick() intern PasswortSchritt() und somit auch AlgorithmusWahl() aufruft, allerdings ist der Countdown hier jedesmal zu groß, als daß das jemals eine Kaskade auslösen könnte :-)
    Passwort.add(Pick());

    //Der Algorithmus soll auch 256 Werte bekommen
    PasswortAlgorithmen.add(Pick());   
  }

  AlgorithmusWechsel += 1;
}


//######################################################################################################
//#           Setzt den Passwortindex einen Schritt weiter
//######################################################################################################
void PasswortSchritt(int Step)
{
  //Von Zeit zu Zeit wird der Algorithmus gewechselt
  AlgorithmusWahl();

  //Der Passwort-Index geht jetzt einen Schritt nach rechts/links, je nachdem, aber mindestens einen Schritt von "1", damit es nie zum Stillstand kommt!
  PasswortIndex = (PasswortIndex + Step + PasswortCountdown + PasswortAlgorithmus + 1) % Passwort.length;
}


//######################################################################################################
//#            Zufallsgenerator kann zwischendurch aufgerufen werden
//######################################################################################################
int Zufallszahl()
{
  //Pseudo-Zufallszahl zurückgeben..
  return Passwort.reduce((sum, value) => sum + value) + PasswortAlgorithmen.reduce((sum, value) => sum + value);
}


//######################################################################################################
//#            Holt einen Wert vom Passwort
//######################################################################################################
int Pick()
{
  int Value = Passwort[PasswortIndex] & 255;
 
  PasswortSchritt(Value);

  Picks += 1;

  return Value;
}


//#########################################################################################
//#                Hier steckt die eigentliche Chiffre-Routine drin
//#########################################################################################
int Berechnung(int Rune)
{
  //Zwei beliebige Startpunkte wählen, die innerhalb des Passwortes liegen
  int A = Pick() % Passwort.length;
  int B = Pick() % Passwort.length;

  //Erstmal sehen, wie lang das Passwort ist, davon die Hälfte nehmen
  int Halbwert = Passwort.length ~/ 2;

  //Gesamtes Passwort oft genug durcheinanderbringen
  int Schleifen = (Zufallszahl() % Halbwert) + Halbwert;

  //Zeichen in Schleife immer weiter verschlüsseln, Passwort und Algorithmus mutieren
  for (int i = 0; i < Schleifen; i++)
  {
    //A und B sollen nicht gleich sein!
    if(A == B) { B = (A + 1) % Passwort.length; }

    //Hole CharA und CharB von den aktuellen Indizes und verändere sie
    int CharA = (Passwort[A] + Pick()) & 255;
    int CharB = (Passwort[B] + Pick()) & 255;

    //Vertausche beide Werte
    Passwort[A] = CharB;
    Passwort[B] = CharA;

    //Aktualisiere die Indizes A und B für den nächsten Durchlauf
    A = (A + Pick() + 1) % Passwort.length;
    B = (B + Pick() + 1) % Passwort.length;

    //Die Text/Chiffre-Rune wird immer weiter XOR-verschlüsselt/entschlüsselt
    Rune ^= Pick();

    Chiffrierungen += 1;
  }
  //Fertige Rune zurückgeben..
  return Rune;
}


//######################################################################################################
//#        Alle Zeichen durchmischen und 256-stelliges Passwort erzeugen
//######################################################################################################
void PasswortBerechnen(String Key)
{
  //Verwandle das Passwort in eine Liste von Zeichen, die ständig erweitert wird, bis eine Länge von 256 Zeichen erreicht ist
  Passwort = Key.runes.toList();

  //Die Startwerte für die Passwort-Algorithmen werden aus dem Passwort entnommen und ebenfalls ständig erweitert, bis 256 Algorithmen erreicht sind
  PasswortAlgorithmen = List.from(Passwort);

  //Zufälligen Wert für die Anfangszustände nehmen
  int Zauber = Zufallszahl() % Passwort.length;

  //Unfassbarer "letzter Passwort-Index-Slot"
  PasswortAlgorithmus = Passwort[Zauber] % PasswortAlgorithmen.length;

  //Der Algorithmus ändert sobald seinen Weg!
  PasswortCountdown = (Zauber & 7) + 7;

  //Der Passwort-Index beginnt irgendwo inmitten des Passworts
  PasswortIndex = Passwort[(Zauber + 1) % Passwort.length] % Passwort.length;

  //Debug-Variablen auf NULL
  AlgorithmusWechsel = 0;
  Chiffrierungen     = 0;
  Picks              = 0;
}


//######################################################################################################
//#                         Verschlüsseln/Entschlüsseln
//######################################################################################################
/*
String Chiffre(String Source)
{
  //Masterpasswort & Algorithmus vorbereiten
  PasswortBerechnen(PrivateKey + PublicKey);

  //Anzahl Windings berechnen (kurze Nachrichten werden öfter verschlüsselt, lange Nachrichten min. 3x)
  int Windings = (1234 ~/ Source.runes.length) + (Pick() & 7); if(Windings < 3) { Windings = 3 + (Pick() & 7); }

  //Beginne mit dem Text/Chiffrecode, der übergeben wurde (und arbeite diesen immer wieder komplett durch)
  String Ergebnis = Source; for(int k = 0; k < Windings; k++)
  {
    StringBuffer Puffer = StringBuffer(); for(int Rune in Ergebnis.runes)
    {
      Puffer.writeCharCode(Berechnung(Rune));
    }
    //Fertiges Chiffre als String zusammenfügen und weiter loopen..
    Ergebnis = Puffer.toString();
  } 

  //Im Debug-Mode werden hinterher die Statistiken angezeigt
  if(Countrycode == 0) { Message('Windings $Windings, Wechsel $AlgorithmusWechsel, Chiffrierungen $Chiffrierungen, Picks $Picks'); }

  //Passwort + Algorithmen unkenntlich machen und fertigen Text/Chiffre zurückgeben..
  Passwort.fillRange(0, Passwort.length, 0); PasswortAlgorithmen.fillRange(0, PasswortAlgorithmen.length, 0);
  return Ergebnis;
}
*/
String Chiffre(String Source)
{
  //Masterpasswort & Algorithmus vorbereiten
  PasswortBerechnen(PrivateKey + PublicKey);

  //Umwandlung von Source in die Liste von Runen
  List<int> Runes = Source.runes.toList();

  //Anzahl Windings berechnen (kurze Nachrichten werden öfter verschlüsselt, lange Nachrichten min. 3x)
  int Windings = (1234 ~/ Runes.length) + (Pick() & 7); if(Windings < 3) { Windings = 3 + (Pick() & 7); }

  //Beginne mit dem Text/Chiffrecode, der übergeben wurde (und arbeite diesen immer wieder komplett durch)
  for(int k = 0; k < Windings; k++)
  {
    for(int i = 0; i < Runes.length; i++)
    {
      Runes[i] = Berechnung(Runes[i]);
    }
  }

  //Im Debug-Mode werden hinterher die Statistiken angezeigt
  if(Countrycode == 0) { Message('Windings $Windings, Wechsel $AlgorithmusWechsel, Chiffrierungen $Chiffrierungen, Picks $Picks'); }

  //Passwort + Algorithmen unkenntlich machen
  Passwort.fillRange(0, Passwort.length, 0); PasswortAlgorithmen.fillRange(0, PasswortAlgorithmen.length, 0);

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
  if(Password.length < 12) { Message(Sprachelement('PasswortKurz')); return false; }

  //Teilbedingungen für das Passwort
  bool hasLowercase        = Password.contains(RegExp(r'[a-z]'));
  bool hasUppercase        = Password.contains(RegExp(r'[A-Z]'));
  bool hasDigit            = Password.contains(RegExp(r'[0-9]'));
  bool hasSpecialCharacter = Password.contains(RegExp(r'[°!@#%^&*(),.?":{}|<>]'));

  //Die Bedingung ist erst erfüllt, wenn alle Teilbedingunen erfüllt sind
  bool Result = hasLowercase && hasUppercase && hasDigit && hasSpecialCharacter;

  //Wenn noch etwas offen ist, gibt es eine Fehlermeldung!
  if(Result == false) { Message(Sprachelement('PasswortUnsicher')); }

  //Passwort ist gültig, wenn alle Bedingungen erfüllt sind
  return Result;
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

/*
//#########################################################################################
//#                 Berechnet die inverse einer Farbe
//#########################################################################################
Color InverseFarbe(Color Farbe)
{
  return Color.fromARGB(Farbe.alpha, 255 - Farbe.red, 255 - Farbe.green, 255 - Farbe.blue);
}
*/

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
  if(Helligkeit(Farbe1) > 50) { Farbe2 = FarbeSkalieren(Farbe1, 33); } else { Farbe2 = FarbeSkalieren(Farbe1, 333); }

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
              if(to.isNotEmpty) {
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









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('LoveSpeech', style: TextStyle(color: Textfarbe)),
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
              Message(EnableSmileys ? 'Emojis enabled' : 'Emojis disabled');
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
              height: 200,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: TextField(
                      controller: Textfeld,
                      focusNode: Fokus,
                      decoration: InputDecoration(
                        labelText: 'Text/Cipher',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                      style: TextStyle(fontSize: FontSize),
                      minLines: 6,
                      maxLines: null,
                      onTap: () { Fokus.requestFocus(); },
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Column(
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
                          onPressed: () {
                            if(Textfeld.text.isNotEmpty) { ShowEmailDialog(); }
                          },
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
                      if(isEncrypted == false)
                      {
                        Message('Please type in a message and select a nickname first.');
                      }
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