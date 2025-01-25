import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';



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
      title: 'LoveSpeech',
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
  String Title = 'LoveSpeech 1.0 copyright 2006-2025 Alexander Graf';              //Variable für den angezeigten Titel in der AppBar
  List<int> Passwort = [];                      //256 Byte langes Passwort während des Chiffrierens/Dechiffrierens
  List<int> PasswortAlgorithmen = [];           //256 Byte lange Liste mit Passwort-Indizes
  int    PasswortIndex = 0;                     //Variable für den Passwort-Index während des Chiffrierens/Dechiffrierens
  int    PasswortAlgorithmus = 0;               //Variable für die Indexwahl (1 aus 256 möglichen Passwort-Algorithmen) während des Chiffrierens/Dechiffrierens
  int    PasswortCountdown = 0;                 //Variable für den Indexwahl-Countdown während des Chiffrierens/Dechiffrierens
  int    Countrycode = 0x2800;                  //Unicode-Auswahl beim Chiffrieren/Dechiffrieren
  double FontSize = 40.0;                       //Schriftgröße im Textfeld (default 16)
  bool   EnableSmileys = true;                  //Smileys bei der Verschlüsselung standardmäßig aktivieren
  int    Namensbegrenzung = 30;                 //Namen sollen nicht zu pompös werden!

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
    windowManager.ensureInitialized();
    FensterMaximieren();
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
      FensterMaximieren();
    }
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
//#                    Methode zum Maximieren des Fensters
//#########################################################################################
Future<void> FensterMaximieren() async
{
  final rect = await windowManager.getBounds();
  await windowManager.setBounds(Rect.fromLTWH(0, 0, rect.width, rect.height));
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
// Chiffrierte Zeichen werden der Länderauswahl entsprechend im Unicode hochgesetzt
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

  //Ansonsten entsprechend der Sprachauswahl chiffrieren
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
  if(Zeilen.length < 3)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Incorrect format. Copy all of the cipher.')),
    );
    return false;
  }

  //Suche nach einem "gefreakten Benutzernamen" in der Zeilenliste
  for(int i = 0; i < Zeilen.length; i++)
  {
    //Benutzernamen sind nicht mehr als 30 Zeichen!
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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unreadable! This is either not a LoveSpeech-Message or parts of it are missing or you don\'t know the buddy who wrote it.')),
  );
  return false;
}


//#########################################################################################
//#                  Popup-Menü für die Länderauswahl
//#########################################################################################
void ShowCountryMenu()
{
  showMenu(
    context: context,
    position: RelativeRect.fill,
    items: [
      PopupMenuItem<int>(
        value: 0,
        child: Text('Neutral (0..0xFF)'),
      ),
      PopupMenuItem<int>(
        value: 0x400,
        child: Text('Russian (0x400..0x4FF)'),
      ),
      PopupMenuItem<int>(
        value: 0x600,
        child: Text('Arabean (0x600..0x6FF)'),
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
        child: Text('Korean (0xAC00)'),
      ),
      PopupMenuItem<int>(
        value: 0xAD00,
        child: Text('Korean (0xAD00)'),
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
        child: Text('Minoan Crete (where available!)'),
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
        title: Text('Add new buddy', style: TextStyle(color: Textfarbe)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newUsernameController,
              decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Textfarbe) ),
              style: TextStyle(color: Textfarbe),
            ),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Textfarbe) ),
              style: TextStyle(color: Textfarbe),
              obscureText: false,
            ),
            //Button zum Generieren eines starken Passworts
            ElevatedButton(
              onPressed: () {
                newPasswordController.text = StarkesPasswort(32);
              },
              child: Text('Generate Strong Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Back', style: TextStyle(color: Textfarbe)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add', style: TextStyle(color: Textfarbe)),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username $Benutzername already exists. Please choose a different one or delete the old one.')),
                  );
                }
                else
                {
                  //Benutzernamen sollen nicht so unfassbar lang sein!
                  if(Benutzername.runes.length > Namensbegrenzung)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Username $Benutzername is too long. Please choose a shorter name.')),
                    );
                  }
                  else
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
void AlgorithmusWahl()
{
  //Countdown für neuen Passwort-Index dekrementieren
  PasswortCountdown -= 1;

  //Ist noch keine Zeit für ein neuen Passwort-Index ?
  if(PasswortCountdown > 0) { return; }

  //Neuen Countdown aus dem Passwort gewinnen
  PasswortCountdown = (Passwort[(PasswortIndex + (Passwort[PasswortIndex] & 255)) & 255] & 7) + 7;

  //Bisherigen Passwort-Algorithmen zurückschreiben!
  PasswortAlgorithmen[PasswortAlgorithmus] = PasswortIndex;

  //Neuen Algorithmus aus dem Passwort auswählen
  PasswortAlgorithmus = Passwort[(PasswortIndex + PasswortAlgorithmus) & 255] & 255;

  //Passwort-Index aus einer anderen Zeit wieder rauskramen
  PasswortIndex = PasswortAlgorithmen[PasswortAlgorithmus];
}


//######################################################################################################
//#           Setzt den Passwortindex einen Schritt weiter
//######################################################################################################
void PasswortSchritt(int Step)
{
  //Von Zeit zu Zeit wird der Algorithmus gewechselt
  AlgorithmusWahl();

  //Der Passwort-Index geht jetzt einen Schritt nach rechts/links, je nachdem
  PasswortIndex = (PasswortIndex + Step + PasswortCountdown + PasswortAlgorithmus + 1) % Passwort.length;
}


//######################################################################################################
//#            Zufallsgenerator kann zwischendurch aufgerufen werden
//######################################################################################################
int Zufallszahl()
{
  //Von Zeit zu Zeit wird der Algorithmus gewechselt
  AlgorithmusWahl();

  //Pseudo-Zufallszahl zurückgeben..
  return Passwort.reduce((sum, value) => sum + value) + PasswortAlgorithmen.reduce((sum, value) => sum + value) + PasswortIndex + PasswortAlgorithmus + PasswortCountdown;
}


//######################################################################################################
//#            Selbstmodifikation von Passwort und Passwortindex
//######################################################################################################
void Shredder()
{
  int Count = (Zufallszahl() & 127) + 56;

  for(int f = 0; f < Count; f++)
  {
    //Hole den aktuellen Wert basierend auf PasswortIndex
    int currentValue = Passwort[PasswortIndex];

    //Verwende den aktuellen PasswortIndex, um einen weiteren chaotischen Wert zu bestimmen
    PasswortSchritt(currentValue);

    //Hole den nächsten Wert basierend auf PasswortIndex
    int nextValue = Passwort[PasswortIndex];

    //Beispiel für eine chaotische Modifikation
    Passwort[PasswortIndex] = (Passwort[PasswortIndex] + currentValue + nextValue + PasswortCountdown + PasswortAlgorithmus + 41) & 255;

    //Verwende den aktuellen PasswortIndex, um einen weiteren chaotischen Wert zu bestimmen
    PasswortSchritt(nextValue);
  }
}


//######################################################################################################
//#        Alle Zeichen durchmischen und 256-stelliges Passwort erzeugen
//######################################################################################################
void PasswortBerechnen(String Key)
{
  //Verwandle das Passwort in eine Liste von Zeichen
  Passwort = Key.codeUnits.toList();

  //Erstelle zwei Zeiger A und B aus den ersten beiden Bytes des Source-Passworts
  int a = Passwort[0] % Passwort.length;
  int b = Passwort[1] % Passwort.length;

  //Zeiger E,F
  int e = Passwort[2] % Passwort.length;
  int f = Passwort[3] % Passwort.length;

  //Unmöglicher Schleifenindex
  int i = Passwort[4];

  //Schleife ? mal über alle Passwortbytes
  while(Passwort.length < 256)
  {
    //Abfrage zur Sicherheit dürfen A und B nicht gleich sein!
    if(a == b) b = (a + 1) % Passwort.length;

    //Abfrage zur Sicherheit dürfen E und F nicht gleich sein!
    if(e == f) f = (e + 1) % Passwort.length;

    //Tausche und inkrementiere die Zeichen an den Indizes A und B
    int temp    = (Passwort[a] + e + Passwort.length) & 255;
    Passwort[a] = (Passwort[b] + f + Passwort.length) & 255;
    Passwort[b] = temp;

    //Setze die Zeiger A und B weiter..
    a = (a + Passwort[e] + 1) % Passwort.length;
    b = (b + Passwort[f] + 1) % Passwort.length;
    e = (e + Passwort[a] + 1) % Passwort.length;
    f = (f + Passwort[b] + 1) % Passwort.length;

    //Verlängere Dest um ein Zeichen und kopiere das Zeichen von Index a+b+e+f+i+41
    if((i & 127) == 0)
    {
      //Zeichen auswählen und hinten anhängen
      Passwort.add(Passwort[(a + b + e + f + i + 41) % Passwort.length]);
    }
    //Variable I immer schön weiterzählen (aber nicht überlaufen lassen)..
    i = (i + a + b + e + f + 1) & 255;
  }

  //Unfassbarer "letzter Passwort-Index-Slot"
  PasswortAlgorithmus = Passwort[i];

  //Unbegreiflicher Countdown für die Änderung des Algorithmus
  PasswortCountdown = (Passwort[(i+85)&255] & 7) + 7;

  //Der Passwort-Index beginnt irgendwo inmitten des Passworts
  PasswortIndex = Passwort[(i+170)&255];

  //Die Startwerte für die Passwort-Indizes werden aus dem fertigen Passwort entnommen
  PasswortAlgorithmen = List.from(Passwort);

  //Zerstöre das soeben erstellte Passwort und den Passwort-Index, samt Algorithmenliste
  for(int f = 0; f < 256; f++) { Shredder(); }
}


//##########################################################################################
//#                  Erzeugt ein sehr starkes Passwort
//##########################################################################################
String StarkesPasswort(int Size)
{
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!\()-=+{}:,.<>?ß°@§%';
  Random random = Random.secure();
  return List.generate(Size, (index) => chars[random.nextInt(chars.length)]).join();
}


//######################################################################################################
//#                         Verschlüsseln/Entschlüsseln
//######################################################################################################
String Chiffre(String Source)
{
  //Masterpasswort & Algorithmen vorbereiten
  PasswortBerechnen(PrivateKey + PublicKey);

  //Anzahl Windings berechnen (kurze Nachrichten werden öfter verschlüsselt, lange Nachrichten min 3x)
  int Windings = 543 ~/ Source.runes.length;
  if(Windings < 3) { Windings = 3; }

  //Beginne mit dem Text, der übergeben wurde
  String Ergebnis = Source; for(int k = 0; k < Windings; k++)
  {
    StringBuffer Puffer = StringBuffer();
    for (int Rune in Ergebnis.runes)
    {
      int Count = (Zufallszahl() & 31) + 32;
      for(int f = 0; f < Count; f++) { Shredder(); Rune ^= Passwort[PasswortIndex] & 255; }
      Puffer.writeCharCode(Rune);
    }
    //Fertiges Chiffre als String zusammenfügen und weiter loopen..
    Ergebnis = Puffer.toString(); Shredder();
  } 

  //Passwort/Algorithmen/PublicKey löschen und fertigen Text/Chiffre zurückgeben..
  Passwort.fillRange(0, Passwort.length, 0); 
  PasswortAlgorithmen.fillRange(0, PasswortAlgorithmen.length, 0);
  return Ergebnis;
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
        title: Text('Delete User', style: TextStyle(color: Textfarbe)),
        content: Text('Are you sure you want to delete $username ?', style: TextStyle(color: Textfarbe)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Textfarbe)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Textfarbe)),
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
void ShowHelpDialog()
{
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppBarColor,
        title: Text(
          'Welcome reader!',
          style: TextStyle(color: Textfarbe),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                'ABOUT:\n'
                'Have you ever dreamed of leaving secret messages online for only select individuals to read?\n'
                'With LoveSpeech, your messages are password-encrypted and then transformed to resemble foreign language sprinkled with emojis. You\’ll have a user list complete with usernames and passwords, allowing you to post secret messages online to specific individuals and read their secret communications as well.\n'
                'And the best part? You can do this in plain sight! Whether on Facebook, X (formerly Twitter), YouTube, and more, your messages will remain a mystery — unless you\’re on someone\’s buddy list.\n'
                'Playfully troll your friends by posting encrypted comments or even form secret societies with closed user groups that exchange hidden messages right in the open. Plus, you can also encrypt and publicly share your buddy list.\n'
                'Feel free to create your own passwords or generate strong ones (recommented) at the click of a button. LoveSpeech adds a whole new level of excitement to online communication!\n\n'

                'ENCRYPTION:\n'
                '1. Choose a name and password for yourself.\n'
                '2. Choose a language (default is the Braille character set of the blind)\n'
                '3. Type in your secret message in the text field.\n'
                '4. Press <Encrypt>.\n'
                '5. Wait a few seconds until the screen updates.\n'
                '6. The cipher is copied to the clipboard along with your username and a randomly generated public key and can be posted on social media platforms like YouTube, X (Twitter) or Facebook.\n\n'
                
                'DECRYPTION:\n'
                '1. If you happen to find a LoveSpeech-Message on the internet, first copy it into your clipboard.\n'
                '2. Go back to this App. That clipboard will automatically show up in the text window.\n'
                '3. Press <Decrypt>.\n'
                '4. Wait a few seconds until the screen updates.\n'
                '5. The original message is now readable in the text window.\n\n'

                'CHARACTER SETS:\n'
                '1. Click on the flag.\n'
                '2. Select a character set from the menu.\n'
                '  - Russia = Cyrillic Character Set 0x400..0x4FF\n'
                '  - Arabean = Arabic Character Set 0x600..0x6FF\n'
                '  - Chinese (rare) = Asian Character Set 0x3400..0x34FF\n'
                '  - Chinese (common) = Asian Character Set 0x4E00..0x4EFF\n'
                '  - Yi - Symbols = Asian Yi (Feng Shui) Character Set 0xA000..0xA0FF\n'
                '  - Korean = Korean Character Set 0xAC00..0xACFF\n'
                '  - Hieroglyph = Ancient Egypt hieroglyph Character Set 0x13000..0x130FF\n'
                '  - Braille Patterns = Character Set of the Blind\n'
                '  - Sumerian = Ancient sumerian Character Set (Windows only)\n'
                '  - Minoan = Ancient minoan Character Set (Windows only)\n'
                '  - Bamum Symbols = African Bamum Character Set (Windows only)\n\n'

                'EMOJIS:\n'
                '  - Click on that Emoji-Symbol in the top right corner of the app. Emojis can either be enabled or disabled to enhance the appearance of the cipher.\n\n'

                'THEMES:\n'
                '  - Click on the Image-Symbol in the top right corner of the app and then select one of the images from the menu to change the appearance of the app.\n\n'

                'BUDDIES:\n'
                '  - Click on the + symbol in the top right corner of the app. Now enter a username and a password or generate a strong password for yourself.\n'
                '  - Click on a name in the buddy list to change his password or to generate a new one.\n\n'

                'EXPORT USER LIST:\n'
                '  - Click on Export User List. Your buddy list will now appear in the text window. You can encrypt it and share it on the internet or via some messenging app.\n\n'

                'IMPORT USER LIST:\n'
                '  - Get someone\'s buddy list. That can either be encrypted or not. If it is encrypted, click on <decrypt> to get the raw text.\n'
                '  - Click on Import User List. All users in that list will be imported into your buddy list. If a buddy already exists, only the password will be updated.\n\n'

                'CREATE SECRET SOCIETY:\n'
                '  - To create a secret society, create a name and password and share it with friends.\n'
                '  - Get their buddy lists too to read their comments or use one common buddy for the whole society.\n'
                '  - To share names and passwords, simply encrypt them and post them as a comment on an internet platform. After all your friends received the buddy list, delete that comment again :-)\n'
                '  - You can continue to share secret information on the internet, after your secret society has shared all their passwords. No one will ever be able to crack your messages.\n'
                '  - Single buddies can be kicked out simply by changing the passwords.\n\n'

                'PROBLEMS:\n'
                'Make sure you selected the right buddy when encrypting text.\n'
                'That can either be you or a friend in your list.\n\n'

                'Make sure you post everything from the clipboard, after encryption.\n'
                'Otherwise, your readers will not be able to decipher what you\'ve written.\n\n'

                'Make sure you get everything into the clipboard when decrypting.\n'
                'Otherwise the format cannot be detected, username and public key will be unrecognized and no decryption will take place.\n\n'

                'ALGORITHM:\n'

                '1. Random Public Key Generation: Each time a message is encrypted, a random public key is generated and transmitted along with the username in the cipher. This ensures that if two different messages are encrypted with the same password, they cannot be compared with each other.\n\n'
                '2. Private Key and Public Key are combined and shuffled in an unpredictable way that depends only on the passwords. At the same time, the algorithm makes sure the passwort has 256 Bytes length.\n\n'
                '3. Multiple Encryptions: The message is encrypted multiple times based on its length, with a minimum of 3 encryptions. This guarantees that a hacker must decrypt the entire text during a brute-force attack before he can test whether the result is okay.\n\n'
                '4. Extensive Character Encryption: Each character of the message is encrypted at least 32 times, destroying its very nature.\n\n'
                '5. Self-Modification: With each access to the password, it is self-modified hundreds of times, and the password index jumps around chaotically. The constant byte overflows unpredictably destroy the password and from time to time, one of 256 different password indexes is randomly chosen.\n\n'
                '6. Disguise: After encryption, the cipher is shifted into the range of foreign Unicode character sets (as determined by the selected language) to resemble foreign text. Additionally, some characters are shifted into the range of Emojis, enhancing the natural appearance of the cipher.\n\n'
                '7. Formatting: The final message consists of 3 lines: cipher, username and public key. Before and after the cipher block, additional lines can be inserted for fun.\n\n'
                '8. The algorithm employs no mechanism to detect whether the password was correct or incorrect. This makes a hacker angry, because he will have to detect that on his own for each possible combination of passwords he might figure out and that takes a long long time for him.\n\n'
                '9. If a hacker can probe 1 Million Passwords per Second and the original password was 21 characters long, the whole process of hacking the message will take 1.02 Billion Billion years! Yes, you read right!\n\n'
                '10.For highly classified information always use a STRONG password. If you don\'t, a hacker might use rainbow-tables or word dictionaries to hack your message within minutes. This is probably the most important point and holds true for all passwords you\'ll ever use in your daily life. Don\'t forget!\n\n'
                '11.Analysers might use neural networks and stable diffusion to DENOISE your encrypted message. If some of the content of the message can be guessed (i.e. empty lines in the beginning or at the end or names or locations), this enables hackers to use a probabilistic approach. They then can calculate thousands of possible messages within your cipher and select the most obvious one. They simply assume, that your message is overlayed by noise and then try to denoise it to the point, where they can assume the text (like a text2image generator, which takes a noise image and a text to create an image).\n\n',

                style: TextStyle(color: Textfarbe),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Ok',
              style: TextStyle(color: Textfarbe),
            ),
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
        title: Text('Update Password for $username'),
        content: TextField(
          controller: newPasswordController,
          decoration: InputDecoration(labelText: 'Change Password'),
          obscureText: false,
        ),
        actions: [
          //Button zum Generieren eines starken Passworts
          ElevatedButton(
            onPressed: () {
              newPasswordController.text = StarkesPasswort(32);
            },
            child: Text('Generate Strong Password'),
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Apply'),
            onPressed: () {
              if (newPasswordController.text.isNotEmpty) {
                setState(() {
                  PrivateKey = Benutzerliste[index]['password'] = newPasswordController.text.trim();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password for $username updated!')),
                );
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
        child: Row(
          children: [
            Image.asset(imagePath, width: 128, height: 128),
          ],
        ),
      );
    }).toList(),
  ).then((selectedImage) {
    if (selectedImage != null) {
      setState(()
      {
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
  setState(() { Textfeld.text = Buffer.toString(); });
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
  if(Count > 0)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nicknames $Count updated!')),
    );
  }
}


//######################################################################################################
//#       Funktion zum Anzeigen des Dialogs Import/Export der Benutzerliste
//######################################################################################################
void ShowImportExportMenu()
{
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(100, 100, 0, 0),
    items: [
      PopupMenuItem<int>(
        value: 1,
        child: Text('Export buddy list'),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: Text('Import buddy list'),
      ),
    ],
  ).then((value) {
    if (value != null) {
      if (value == 1) {
        ExportUserListToTextField();
      } else if (value == 2) {
        ImportUserListFromTextField();
      }
    }
  });
}


//######################################################################################################
//#                     Schreibt Text in die Zwischenablage
//######################################################################################################
void CopyToClipboard(String Text)
{
  Clipboard.setData(ClipboardData(text: Text));
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
            onPressed: ShowCountryMenu,
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
            icon: Icon(Icons.more_vert, color: Textfarbe),
            onPressed: ShowImportExportMenu,
          ),
          IconButton(
            icon: Icon(
              EnableSmileys ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied,
              color: Textfarbe,
            ),
            onPressed: () {
              setState(() { EnableSmileys = !EnableSmileys; });

              //Snackbar-Nachricht basierend auf dem aktuellen Zustand von EnableSmileys
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(EnableSmileys ? 'Emojis enabled' : 'Emojis disabled'),
                ),
              );
            },
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Text copied to clipboard')),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.paste),
                          onPressed: () async {
                            FetchClipboardText();
                            Fokus.requestFocus();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            Fokus.requestFocus();
                            setState(() {
                              Textfeld.clear();
                            });
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
                    if(Textfeld.text.isNotEmpty && User.isNotEmpty && PrivateKey.isNotEmpty)
                    {
                      //Öffentlichen Schlüssel generieren
                      PublicKey = StarkesPasswort(7);

                      //Fertiges Chiffre erzeugen
                      Textfeld.text = Hochsetzen(Chiffre(Textfeld.text.trim())) + '\n' + Hochsetzen(User) + '\n' + Hochsetzen(PublicKey);

                      //Chiffre in die Zwischenablage kopieren, fertig..
                      CopyToClipboard(Textfeld.text);
                    }
                    else
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please type in a message and select a buddy.')),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(ButtonColor),
                    foregroundColor: MaterialStateProperty.all(Textfarbe),
                  ),
                  child: Text('Encrypt'),
                ),
                ElevatedButton(
                  onPressed: () {
                    //Wenn dies ein bekannter Chiffre-Typ ist und Benutzername und Passwort erkannt wurden:
                    if(Parser())
                    {
                      //Dechiffrierte Originalschrift im Fenster anzeigen
                      Textfeld.text = Hinabsetzen(Chiffre(Textfeld.text));
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(ButtonColor),
                    foregroundColor: MaterialStateProperty.all(Textfarbe),
                  ),
                  child: Text('Decrypt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}