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

Every single rune of the message is processed in a loop, that runs hundreds of XOR-encryptions using password bytes. The vector used for accessing the password is n-dimensional and constantly changes its dimensions. The passwort grows to 256 characters and then begins to constantly shrink and grow. All the same time the password is chopped up and self-modified.

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

Braille Patterns:
⡔⡂⣯⣉⣊⣢😘⠣⢋⡒⠈⡸⢚⣇⣉⡶⣓⢕😔😝⠈😀⣪⠟⠣⣖⣗⢫⢿⣁⢁⢄⢏⢿⡑⢘⢤⣶⢷⡂⢋😇⣄⡍⢅⠷⣕⣸⠬😒⣬⡬⠴⠮⢀😃⡆⠭⢴⡌😉⠳😎⡧⣗⠼😔⢞⣯⠼😆⢈⣔⢽⡮⠭⢷⢳😒😇⡯
⡁⡬⡥⡸⡡⡮⡤⡥⡲⡇⡲⡡⡦
⡴⠳⡴⠸⡪⡄⠢

Rare chinese symbols:
㓳㓇㑓㑿㐿㑀㐞㓛㐶㓪㒲㑪㑜㒪😑㐰㒔㒘㐮㐭㒩㓆㓄㒓㓘😅😃㑔㐵㓿㑳㓬㒹㓾㑯㒧㓖㒉😒㑧㓻㓦㑛㑞㑜㑨㑢㐼㓳㓾㒝㓕😝㓺㑕㒧㑱㓄㐬㐲😆㓁😏㒀㒒㓑㑂㓩㓶㓷㑟😌㒅㒂㒚㒾😕㑃😙㐲㐡㓊㓾㓥㒛😒㑨㑉㒜㒖㑶㓨㓺㒑㑫㐈㓐㑖㒊㒔㐻㓰㓵㑱㐭㑖㒌㒑㑖㓢㑨㑻😘㑄㑩
㑁㑬㑇㑲㐷㐲㑤㑥㑬㑵㑸㑥
㐩㐿㑄㐸㑏㑣㑓

Feng Shui symbols:
😊😔ꂑꂰ😉😛ꀷꃪꃩꀯꃛꂗꁮꁍ😌ꀾꁕꁂꁏꁶꃐꃰꁟꃥꂂꃢꃈꂗꀾꁨ😒😍ꂰꀰꀰꂄꀥꂭꃙꁈꂩꁆꂮꁙꃲꃨꂻꂔꁭꂉꂾꁀꃳꀪꀢꂸꂺ😔😚ꁖꁣꁠꂲꂽꀿ😍ꂫꃖ😙ꀠꂇꁇꁰꂀꂢꁭꃡꀶꀲꀈꂦꁾꀦꂯꂸꂚꀾꁂꀫꂺꀲꁵꂉꀵꁺꁠꂿꃙꁜꁉꃮꃉꀭꁁꀦ😕😎ꃵꂀꂮꃞꃴꀟꃠꀟꀸꃯꃘꁒꃪꃂꃣꀮꃗꃑꂹꂙꃫꂹꂠꀷ😘ꀪꂒꀶꂭꀣ😄ꂽꁥ😎ꀤꁂ😛ꀞꃂꁃꃫꂔꀡꂛ
ꁁꁬꁇꁲꀷꀲꁤꁯꁯꁭ
ꁴꀲꁄꁱꁺꁅꁰ

Sumerian:
𒀯𒂛𒀬😕𒃍𒁚𒁋𒃯𒁄𒂙𒃌𒃢𒀪𒁻𒂊𒂯𒃗𒀣𒂈𒃿𒃦𒂅𒀤𒃭𒂊𒀮𒀵𒂾𒀈𒃡𒀦𒂫𒃞😝𒁵𒂉𒁕𒁆𒀬𒂤𒂵𒃈𒁼𒀈𒃋𒂙𒂣𒁦𒃄𒂧𒃸𒀷𒃅𒃵𒃶𒃛𒁩😇𒂑😚𒃂𒂶𒁢𒃮𒀺😜😌𒀵𒃢𒁝𒂛𒂪𒁄𒂪𒀯𒁟𒃣𒁂𒂱𒁼𒂤😘𒀟𒂽😐😇𒂌𒀦😜𒃸𒂱𒂈𒁜𒂩𒂸𒂶𒁐𒁘𒂉𒁓𒁜😋😗𒃐𒃜𒀬𒁚𒀭𒁩😄𒀱𒂖𒃝𒂷𒀟𒂶𒀲𒂛𒁂😁𒃨😏𒁭𒁺𒁞😄𒃎𒁤𒁓𒁣𒂌𒀟𒃫😋𒃁𒀟𒂔𒃼𒀩𒂛𒀠𒃮𒀬𒂁𒁕𒂫𒃎𒃩𒀩𒀴𒃙𒁹𒀰𒁟𒁓𒁷𒁻𒀺𒃌𒁿𒃮𒁉𒂁😉𒃏𒃔😕𒂐𒂚𒀴𒃂𒃾𒃀𒀿𒀡𒃆𒃸𒂏𒂝𒁃𒀣𒃭𒀾𒁴𒂌𒂯𒁳😑
𒁁𒁬𒁇𒁲𒀷𒀲𒁢𒁥𒁡𒁵𒁴𒁹
𒀪𒁞𒁦𒁷𒁸𒀲𒀺

Hieroglyphs:
𓁿𓃉𓃡𓃕𓃦𓁘𓃘𓀥𓂪𓂳𓁋𓃬𓃌𓂆𓁶𓁢𓂯𓁡𓀂𓂷𓂜𓁿𓂋𓂬𓃜𓀨𓂌𓂀𓂌𓂙𓂤𓁜𓂙𓁚𓂢𓀨𓃓𓂧𓁛𓂇𓁊𓁻𓁏𓂆𓂛𓂄𓀨𓃱𓂐𓃩𓃥𓂠𓀬𓁿𓀾𓂀𓀢𓀨𓀀𓁜𓃄𓃽𓀛𓃯𓀾𓂇𓁸𓁝𓂂𓃩𓃎𓀜𓁍𓃍𓁤𓁾𓃸𓂰𓁯𓂄𓁶𓁹𓀃𓁕𓂍𓁱𓃋𓁋𓃬𓃍𓂻𓁶𓀽𓀵𓁥𓀑𓁋𓂥𓂫𓃂𓁻𓀻𓀭𓀊𓃠𓂌𓁡𓃽𓁸𓁄𓁿𓁢𓀻𓀖𓁬𓁟𓁧𓂻𓃒𓂳𓂎𓃯𓃒𓁖𓃊𓃾𓂢𓂥𓂌𓀑𓁂𓀮𓁠𓂶𓂔𓁾𓀢𓁳𓂿𓁼𓀟𓁇𓃑𓂆𓀢𓃏𓂆𓂘𓃘𓃳𓀵𓁄𓀬𓁞𓃂𓂁𓂯𓂬𓀰𓂎𓀂𓃢𓂤𓂖𓁟𓃍𓁟𓃂𓃑𓂸𓁧𓀱𓃣𓂐𓀧𓁶𓁗𓀝𓃎𓁑𓁟𓀆𓃛𓁠𓃰𓂯𓃽𓁧𓂁𓀀𓂿𓀕𓂗𓁬𓀗𓂫𓁃𓂞𓂝𓃒𓁋𓁛𓀜𓁅𓃖𓁙𓃶𓁰𓁫𓃢𓂿𓀤𓃲𓂊𓂈𓁘𓂑𓂰𓀒𓃗𓃢𓀪𓃆𓂽𓀉
𓁁𓁬𓁇𓁲𓀷𓀲𓁤𓁥𓁳𓁰𓁡𓁩𓁲
𓀰𓁭𓁉𓁎𓁢𓁓𓁆


