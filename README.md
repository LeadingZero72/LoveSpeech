LoveSpeech 1.0

This is the source code of ​​my app <LoveSpeech>. I had the idea around 2006, but was prevented from releasing it (some idiots stole it from me). Now, here it is.

Private Encryption for Social Media. Disguise your posts, only your friends can read.

With this app you encrypt your shitposts, which are secured with a password, disguised as occult symbolism and decorated with emojis to make it look funnier. Only friends will be able to read your messages. For everyone else it will remain a mysterious wonder.

There are 30 amazing app themes for every user.

Choose from different styles such as Russian, Arabic, Chinese, Korean, Hieroglyph, Braille of the Blind, Sumerian, Feng Shui and African Bamum Symbols.

You can export or import buddy lists. You export your buddy list, encrypt it and post it somewhere on the Internet. This way others can import them and use your passwords to read your messages and possibly those of your friends too. All you need is LoveSpeech!

Emojis can be turned on or off at will, depending on the mood.

The software is now multilinguar and supports German, English, Spanish, Frensh and Italian, including buttons, messages and the help screen.

The Algorithm

An additional public key is generated for each encryption to ensure uniqueness.
Both keys are combined. The resulting password is then duplicated to create an n-dimensional vector used to access the password.

The whole message is encrypted multiple times, depending on its length maybe hundrends of times, but at least 3x.

Every single rune of the message is processed in a loop, that runs hundreds of XOR-encryptions using password bytes. The vector used for accessing the password is n-dimensional and constantly changes its dimensions. The passwort grows to 256 characters and then begins to constantly shrink and grow. At the same time the password is constantly chopped up and self-modified.

The resulting cipher code is now moved in the upper Unicode range so that the desired symbolism can be seen. The decryption process is reversed. Only one routine is needed for encryption and decryption.

The cipher code is structured in 3 lines, so that the encrypted message follows first, then the user name and then the public key. There can be lines with other things above and below. When decrypting, a line is first searched for that has a known user name and then the password is taken and the cipher is decrypted.

The algorithm is very diligent. If the message "Test" is encrypted, it will do hundreds of loops around the message, hundreds of thousands of encryptions will take place, the password is accessed millions of times.

GOALS:

If everyone uses private encryption for social media, the Internet will become a strange mystery to everyone.

When no one can read what others have written on the Internet, free speech will apply everywhere.

You can write about anything you think in public and only selected friends can read it.

Yours
Alexander Graf
LeadingZero78@gmail.com
