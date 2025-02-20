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
⢟⢶⠫⢪⢲⠪⡔⠽😏⡡⢑⠽⣟⠠⢠⢗⣴⢏⡪⡑⡖⣦⢥⡍⡐😙⡡⡷😎⠯⡣⢆⠧⠩⣛⠞⢍⣰⣛⠟⢴⡗⢓😌😒⢞⣜⣔⡫⡔⣨⢵⣚⢈⣤⡲⢓😙⡾⢖😉⢴⣒⢿⡝⡏⡃⡤⢱⠼⣒⣏⡈⣟⡆⣭⣣⠴⠧⣰😏
⡁⡬⡥⡸⡡⡮⡤⡥⡲⡇⡲⡡⡦
⡕⡦⡻⡐⡑⠶⠸

Rare chinese symbols:
㓙㑛😋㓘㑐㑬😚㓘㒞😇㑅㓋㓜㒍㑋㓕㓃㐢😒㐥😕😚㑊㓀㑅㑞㐴㑟㓴㑖㑚㑓㑒㑨😆㑶㑼㒅㐖㓑㓇㓔㓤㒷㑋㓃㒚㑼㓝㑎㓚㒅㐭㒉㓫㑼㓸㑪㒎㓗㑀😎㑦㐰㑟㓙㒏㐭㓉㒧㐖😂㑋😇㓝㒉㓵㑹😋㐟㐟㓫㑎㒯㓃㓗㑭㓳㒨㐮㓸㒥㓙㓩😂㑆㐳㑥㓴㒞㒷㒣㓇㐵㐹㓂㒗㓘㒄㓐㐖㒵😉㓁㐳㒃㓊
㑁㑬㑇㑲㐷㐲㑤㑥㑬㑵㑸㑥
㐼㑯㑐㐾㑃㐥㐾

Feng Shui symbols:
ꃵꁀꁪ😌ꁌꂺꁖ😝ꀡꂀꂦꂵꃰꁏꁞꃶꃬꁃꃤꂧꂺꀭꃹꁧꁃꂶꂘꀹꃬꂌ😕ꃐꂳꀢꂫꀳꃒꂀꂴꂛꁑꁖꃭꂙꁗꀖꀯꁔꁿꃵꂟ😐ꀖꃓꀱꂽꂺꃲꁬꂙꃉꁂꂝꁇꃩꃂꃅ😋ꃐ😛ꂫꁴꀾꀤꁫꃠꂎꁘꃥꃖꃼꂞ😄ꁄꁔꀾꁲꃨꃯꃠꀽꂪꃏꂝꁀꂣꃵꁈꁑꃭꂝꁝꂿꀲꂃꁏꂐꃌꃶꃅꃺꁶꂹꁹꁱꂎꂙꀵꃳꂐꁙꂅꂦꂓꂏ😕ꀿꁣꁏꀈ😎ꀩꀣꂧꂒꃃꁲꃑꃙ😜ꃝꁟ😏ꂧꂯꃋꁡꀿꁉꁬꀡꃨꃃ
ꁁꁬꁇꁲꀷꀲꁷꁩꁣꁫꁥꁤ
ꁢꁉꁈꀾꁽꁖꁲ

Sumerian:
𒂞𒃡𒃋𒁪😏𒂖😋𒁚😓😆𒃊𒂖😙𒁕𒃊𒂔𒂪𒃗𒂃𒂗𒂮𒁸𒃬𒂬𒁛𒁤𒀬𒃖𒃒😎𒃿𒁜𒁷𒃸𒃻𒁳𒂙😙𒁄𒁞😍😚𒁐𒂢𒁡𒃶𒀣𒀪😐𒁳𒁓𒂰𒂑𒃃😓𒂚𒃦𒂙𒁯𒃿𒃄𒂣😌𒁺𒂫😒𒁿😆𒂜𒃽𒂔𒀳𒁺𒁼𒂦𒃮𒀖😙𒂢𒀢𒃉😔𒃴𒃓𒁖𒁵𒂒𒃵𒃥𒂹𒂸𒂩𒂒𒁉𒂠𒁐😐𒃺𒀼𒂃𒃄𒀷𒂨𒃾𒂲𒀺😄😔𒂪𒁰😌𒁠𒀧𒀟𒀟𒃝𒃜𒂾𒃆𒂂𒀱𒃱𒂤𒃁𒃦𒀩😋𒂔𒂮𒁧𒃺𒁵𒃲𒂕𒁤𒁁𒃕𒃫𒁏𒂸😎𒂢𒃎𒀵𒃟𒁄😍𒃔𒁻𒁼𒁳😉𒁷𒃠𒁓𒁕𒃼𒀰𒃻𒁾𒃶𒂞𒂔𒂴𒀠𒀹𒃍𒁛𒂴𒁑𒂾𒃐𒁳𒂱𒂼𒀳𒃤𒃶𒁑𒃷𒁆𒁏𒀟𒁐𒁷𒁄𒁊𒁾
𒁁𒁬𒁇𒁲𒀷𒀲𒁴𒁲𒁵𒁴𒁨
𒁺𒁦𒁮𒁊𒁖𒁥𒁂

Hieroglyphs:
𓁐𓁲𓃹𓀖𓃹𓀤𓀎𓀦𓃖𓀎𓁔𓃺𓃈𓁈𓀟𓂿𓀁𓃬𓀅𓃍𓂊𓃔𓀧𓁪𓂒𓂞𓃪𓁢𓁐𓂏𓃿𓀾𓂙𓃓𓃦𓀰𓂔𓂔𓁥𓀼𓃒𓀫𓃓𓃷𓁼𓃋𓀇𓁔𓀨𓂌𓃕𓂜𓂑𓂐𓀀𓁀𓃰𓂍𓀯𓃛𓂻𓂨𓂺𓃨𓁾𓂀𓀞𓂻𓁍𓀌𓃿𓃣𓃥𓀙𓂺𓁳𓃄𓂽𓁬𓂤𓃶𓂿𓂧𓃋𓂙𓀼𓂑𓀒𓁯𓃤𓁤𓀐𓂓𓁇𓂯𓃓𓃀𓁨𓂊𓂽𓃿𓁤𓃵𓁺𓀼𓁌𓂽𓃙𓀘𓀖𓀬𓁛𓃫𓀱𓀸𓂁𓁄𓀊𓃬𓁯𓂺𓁔𓃰𓁈𓃪𓁣𓃽𓀁𓃞𓀢𓂵𓁐𓁌𓂙𓁦𓀍𓁠𓃲𓀿𓁽𓃈𓁐𓁙𓀌𓁠𓃶𓂾𓃻𓀛𓁞𓁞𓃛𓃰𓀉𓂪𓁾𓁽𓀪𓁟𓃻𓂇𓀁𓀣𓀹𓀮𓂘𓃋𓃗𓂮𓂕𓃦𓁆𓂶𓂎𓃱𓂓𓀛𓃭𓀔𓁡𓀽𓂹𓁎𓁫𓂤𓁬𓂙𓃣𓂧𓀽𓀛𓃧𓀣𓀌𓀐𓀈𓀁𓂩𓂐𓀷𓁉𓃝𓁗𓀳𓂧𓃍𓂼𓀓𓂠𓂤𓂙𓀒𓀱𓀋𓃾𓃓𓂈𓂃𓀰𓁅𓃜𓃂
𓁁𓁬𓁇𓁲𓀷𓀲𓁴𓁲𓁵𓁴𓁨
𓁚𓀩𓁧𓁍𓁂𓁋𓁦


