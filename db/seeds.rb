require 'roo'
require 'spreadsheet'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Languages
# This is the official list of languages for which there are ISO 639-2 codes,
# from http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt
languages = [
    Language.create(english_name: 'Afar', native_name: 'afar', iso639_2_code: '﻿aar'),
    Language.create(english_name: 'Abkhazian', native_name: 'abkhaze', iso639_2_code: 'abk'),
    Language.create(english_name: 'Achinese', native_name: 'aceh', iso639_2_code: 'ace'),
    Language.create(english_name: 'Acoli', native_name: 'acoli', iso639_2_code: 'ach'),
    Language.create(english_name: 'Adangme', native_name: 'adangme', iso639_2_code: 'ada'),
    Language.create(english_name: 'Adyghe; Adygei', native_name: 'adyghé', iso639_2_code: 'ady'),
    Language.create(english_name: 'Afro-Asiatic languages', native_name: 'afro-asiatiques, langues', iso639_2_code: 'afa'),
    Language.create(english_name: 'Afrihili', native_name: 'afrihili', iso639_2_code: 'afh'),
    Language.create(english_name: 'Afrikaans', native_name: 'afrikaans', iso639_2_code: 'afr'),
    Language.create(english_name: 'Ainu', native_name: 'aïnou', iso639_2_code: 'ain'),
    Language.create(english_name: 'Akan', native_name: 'akan', iso639_2_code: 'aka'),
    Language.create(english_name: 'Akkadian', native_name: 'akkadien', iso639_2_code: 'akk'),
    Language.create(english_name: 'Albanian', native_name: 'albanais', iso639_2_code: 'alb'),
    Language.create(english_name: 'Aleut', native_name: 'aléoute', iso639_2_code: 'ale'),
    Language.create(english_name: 'Algonquian languages', native_name: 'algonquines, langues', iso639_2_code: 'alg'),
    Language.create(english_name: 'Southern Altai', native_name: 'altai du Sud', iso639_2_code: 'alt'),
    Language.create(english_name: 'Amharic', native_name: 'amharique', iso639_2_code: 'amh'),
    Language.create(english_name: 'English, Old (ca.450-1100)', native_name: 'anglo-saxon (ca.450-1100)', iso639_2_code: 'ang'),
    Language.create(english_name: 'Angika', native_name: 'angika', iso639_2_code: 'anp'),
    Language.create(english_name: 'Apache languages', native_name: 'apaches, langues', iso639_2_code: 'apa'),
    Language.create(english_name: 'Arabic', native_name: 'arabe', iso639_2_code: 'ara'),
    Language.create(english_name: 'Official Aramaic (700-300 BCE); Imperial Aramaic (700-300 BCE)', native_name: 'araméen d\'empire (700-300 BCE)', iso639_2_code: 'arc'),
    Language.create(english_name: 'Aragonese', native_name: 'aragonais', iso639_2_code: 'arg'),
    Language.create(english_name: 'Armenian', native_name: 'arménien', iso639_2_code: 'arm'),
    Language.create(english_name: 'Mapudungun; Mapuche', native_name: 'mapudungun; mapuche; mapuce', iso639_2_code: 'arn'),
    Language.create(english_name: 'Arapaho', native_name: 'arapaho', iso639_2_code: 'arp'),
    Language.create(english_name: 'Artificial languages', native_name: 'artificielles, langues', iso639_2_code: 'art'),
    Language.create(english_name: 'Arawak', native_name: 'arawak', iso639_2_code: 'arw'),
    Language.create(english_name: 'Assamese', native_name: 'assamais', iso639_2_code: 'asm'),
    Language.create(english_name: 'Asturian; Bable; Leonese; Asturleonese', native_name: 'asturien; bable; léonais; asturoléonais', iso639_2_code: 'ast'),
    Language.create(english_name: 'Athapascan languages', native_name: 'athapascanes, langues', iso639_2_code: 'ath'),
    Language.create(english_name: 'Australian languages', native_name: 'australiennes, langues', iso639_2_code: 'aus'),
    Language.create(english_name: 'Avaric', native_name: 'avar', iso639_2_code: 'ava'),
    Language.create(english_name: 'Avestan', native_name: 'avestique', iso639_2_code: 'ave'),
    Language.create(english_name: 'Awadhi', native_name: 'awadhi', iso639_2_code: 'awa'),
    Language.create(english_name: 'Aymara', native_name: 'aymara', iso639_2_code: 'aym'),
    Language.create(english_name: 'Azerbaijani', native_name: 'azéri', iso639_2_code: 'aze'),
    Language.create(english_name: 'Banda languages', native_name: 'banda, langues', iso639_2_code: 'bad'),
    Language.create(english_name: 'Bamileke languages', native_name: 'bamiléké, langues', iso639_2_code: 'bai'),
    Language.create(english_name: 'Bashkir', native_name: 'bachkir', iso639_2_code: 'bak'),
    Language.create(english_name: 'Baluchi', native_name: 'baloutchi', iso639_2_code: 'bal'),
    Language.create(english_name: 'Bambara', native_name: 'bambara', iso639_2_code: 'bam'),
    Language.create(english_name: 'Balinese', native_name: 'balinais', iso639_2_code: 'ban'),
    Language.create(english_name: 'Basque', native_name: 'basque', iso639_2_code: 'baq'),
    Language.create(english_name: 'Basa', native_name: 'basa', iso639_2_code: 'bas'),
    Language.create(english_name: 'Baltic languages', native_name: 'baltes, langues', iso639_2_code: 'bat'),
    Language.create(english_name: 'Beja; Bedawiyet', native_name: 'bedja', iso639_2_code: 'bej'),
    Language.create(english_name: 'Belarusian', native_name: 'biélorusse', iso639_2_code: 'bel'),
    Language.create(english_name: 'Bemba', native_name: 'bemba', iso639_2_code: 'bem'),
    Language.create(english_name: 'Bengali', native_name: 'bengali', iso639_2_code: 'ben'),
    Language.create(english_name: 'Berber languages', native_name: 'berbères, langues', iso639_2_code: 'ber'),
    Language.create(english_name: 'Bhojpuri', native_name: 'bhojpuri', iso639_2_code: 'bho'),
    Language.create(english_name: 'Bihari languages', native_name: 'langues biharis', iso639_2_code: 'bih'),
    Language.create(english_name: 'Bikol', native_name: 'bikol', iso639_2_code: 'bik'),
    Language.create(english_name: 'Bini; Edo', native_name: 'bini; edo', iso639_2_code: 'bin'),
    Language.create(english_name: 'Bislama', native_name: 'bichlamar', iso639_2_code: 'bis'),
    Language.create(english_name: 'Siksika', native_name: 'blackfoot', iso639_2_code: 'bla'),
    Language.create(english_name: 'Bantu (Other)', native_name: 'bantoues, autres langues', iso639_2_code: 'bnt'),
    Language.create(english_name: 'Bosnian', native_name: 'bosniaque', iso639_2_code: 'bos'),
    Language.create(english_name: 'Braj', native_name: 'braj', iso639_2_code: 'bra'),
    Language.create(english_name: 'Breton', native_name: 'breton', iso639_2_code: 'bre'),
    Language.create(english_name: 'Batak languages', native_name: 'batak, langues', iso639_2_code: 'btk'),
    Language.create(english_name: 'Buriat', native_name: 'bouriate', iso639_2_code: 'bua'),
    Language.create(english_name: 'Buginese', native_name: 'bugi', iso639_2_code: 'bug'),
    Language.create(english_name: 'Bulgarian', native_name: 'bulgare', iso639_2_code: 'bul'),
    Language.create(english_name: 'Burmese', native_name: 'birman', iso639_2_code: 'bur'),
    Language.create(english_name: 'Blin; Bilin', native_name: 'blin; bilen', iso639_2_code: 'byn'),
    Language.create(english_name: 'Caddo', native_name: 'caddo', iso639_2_code: 'cad'),
    Language.create(english_name: 'Central American Indian languages', native_name: 'amérindiennes de L\'Amérique centrale, langues', iso639_2_code: 'cai'),
    Language.create(english_name: 'Galibi Carib', native_name: 'karib; galibi; carib', iso639_2_code: 'car'),
    Language.create(english_name: 'Catalan; Valencian', native_name: 'catalan; valencien', iso639_2_code: 'cat'),
    Language.create(english_name: 'Caucasian languages', native_name: 'caucasiennes, langues', iso639_2_code: 'cau'),
    Language.create(english_name: 'Cebuano', native_name: 'cebuano', iso639_2_code: 'ceb'),
    Language.create(english_name: 'Celtic languages', native_name: 'celtiques, langues; celtes, langues', iso639_2_code: 'cel'),
    Language.create(english_name: 'Chamorro', native_name: 'chamorro', iso639_2_code: 'cha'),
    Language.create(english_name: 'Chibcha', native_name: 'chibcha', iso639_2_code: 'chb'),
    Language.create(english_name: 'Chechen', native_name: 'tchétchène', iso639_2_code: 'che'),
    Language.create(english_name: 'Chagatai', native_name: 'djaghataï', iso639_2_code: 'chg'),
    Language.create(english_name: 'Chinese', native_name: 'chinois', iso639_2_code: 'chi'),
    Language.create(english_name: 'Chuukese', native_name: 'chuuk', iso639_2_code: 'chk'),
    Language.create(english_name: 'Mari', native_name: 'mari', iso639_2_code: 'chm'),
    Language.create(english_name: 'Chinook jargon', native_name: 'chinook, jargon', iso639_2_code: 'chn'),
    Language.create(english_name: 'Choctaw', native_name: 'choctaw', iso639_2_code: 'cho'),
    Language.create(english_name: 'Chipewyan; Dene Suline', native_name: 'chipewyan', iso639_2_code: 'chp'),
    Language.create(english_name: 'Cherokee', native_name: 'cherokee', iso639_2_code: 'chr'),
    Language.create(english_name: 'Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic', native_name: 'slavon d\'église; vieux slave; slavon liturgique; vieux bulgare', iso639_2_code: 'chu'),
    Language.create(english_name: 'Chuvash', native_name: 'tchouvache', iso639_2_code: 'chv'),
    Language.create(english_name: 'Cheyenne', native_name: 'cheyenne', iso639_2_code: 'chy'),
    Language.create(english_name: 'Chamic languages', native_name: 'chames, langues', iso639_2_code: 'cmc'),
    Language.create(english_name: 'Coptic', native_name: 'copte', iso639_2_code: 'cop'),
    Language.create(english_name: 'Cornish', native_name: 'cornique', iso639_2_code: 'cor'),
    Language.create(english_name: 'Corsican', native_name: 'corse', iso639_2_code: 'cos'),
    Language.create(english_name: 'Creoles and pidgins, English based', native_name: 'créoles et pidgins basés sur l\'anglais', iso639_2_code: 'cpe'),
    Language.create(english_name: 'Creoles and pidgins, French-based', native_name: 'créoles et pidgins basés sur le français', iso639_2_code: 'cpf'),
    Language.create(english_name: 'Creoles and pidgins, Portuguese-based', native_name: 'créoles et pidgins basés sur le portugais', iso639_2_code: 'cpp'),
    Language.create(english_name: 'Cree', native_name: 'cree', iso639_2_code: 'cre'),
    Language.create(english_name: 'Crimean Tatar; Crimean Turkish', native_name: 'tatar de Crimé', iso639_2_code: 'crh'),
    Language.create(english_name: 'Creoles and pidgins', native_name: 'créoles et pidgins', iso639_2_code: 'crp'),
    Language.create(english_name: 'Kashubian', native_name: 'kachoube', iso639_2_code: 'csb'),
    Language.create(english_name: 'Cushitic languages', native_name: 'couchitiques, langues', iso639_2_code: 'cus'),
    Language.create(english_name: 'Czech', native_name: 'tchèque', iso639_2_code: 'cze'),
    Language.create(english_name: 'Dakota', native_name: 'dakota', iso639_2_code: 'dak'),
    Language.create(english_name: 'Danish', native_name: 'danois', iso639_2_code: 'dan'),
    Language.create(english_name: 'Dargwa', native_name: 'dargwa', iso639_2_code: 'dar'),
    Language.create(english_name: 'Land Dayak languages', native_name: 'dayak, langues', iso639_2_code: 'day'),
    Language.create(english_name: 'Delaware', native_name: 'delaware', iso639_2_code: 'del'),
    Language.create(english_name: 'Slave (Athapascan)', native_name: 'esclave (athapascan)', iso639_2_code: 'den'),
    Language.create(english_name: 'Dogrib', native_name: 'dogrib', iso639_2_code: 'dgr'),
    Language.create(english_name: 'Dinka', native_name: 'dinka', iso639_2_code: 'din'),
    Language.create(english_name: 'Divehi; Dhivehi; Maldivian', native_name: 'maldivien', iso639_2_code: 'div'),
    Language.create(english_name: 'Dogri', native_name: 'dogri', iso639_2_code: 'doi'),
    Language.create(english_name: 'Dravidian languages', native_name: 'dravidiennes, langues', iso639_2_code: 'dra'),
    Language.create(english_name: 'Lower Sorbian', native_name: 'bas-sorabe', iso639_2_code: 'dsb'),
    Language.create(english_name: 'Duala', native_name: 'douala', iso639_2_code: 'dua'),
    Language.create(english_name: 'Dutch, Middle (ca.1050-1350)', native_name: 'néerlandais moyen (ca. 1050-1350)', iso639_2_code: 'dum'),
    Language.create(english_name: 'Dutch; Flemish', native_name: 'néerlandais; flamand', iso639_2_code: 'dut'),
    Language.create(english_name: 'Dyula', native_name: 'dioula', iso639_2_code: 'dyu'),
    Language.create(english_name: 'Dzongkha', native_name: 'dzongkha', iso639_2_code: 'dzo'),
    Language.create(english_name: 'Efik', native_name: 'efik', iso639_2_code: 'efi'),
    Language.create(english_name: 'Egyptian (Ancient)', native_name: 'égyptien', iso639_2_code: 'egy'),
    Language.create(english_name: 'Ekajuk', native_name: 'ekajuk', iso639_2_code: 'eka'),
    Language.create(english_name: 'Elamite', native_name: 'élamite', iso639_2_code: 'elx'),
    Language.create(english_name: 'English', native_name: 'anglais', iso639_2_code: 'eng'),
    Language.create(english_name: 'English, Middle (1100-1500)', native_name: 'anglais moyen (1100-1500)', iso639_2_code: 'enm'),
    Language.create(english_name: 'Esperanto', native_name: 'espéranto', iso639_2_code: 'epo'),
    Language.create(english_name: 'Estonian', native_name: 'estonien', iso639_2_code: 'est'),
    Language.create(english_name: 'Ewe', native_name: 'éwé', iso639_2_code: 'ewe'),
    Language.create(english_name: 'Ewondo', native_name: 'éwondo', iso639_2_code: 'ewo'),
    Language.create(english_name: 'Fang', native_name: 'fang', iso639_2_code: 'fan'),
    Language.create(english_name: 'Faroese', native_name: 'féroïen', iso639_2_code: 'fao'),
    Language.create(english_name: 'Fanti', native_name: 'fanti', iso639_2_code: 'fat'),
    Language.create(english_name: 'Fijian', native_name: 'fidjien', iso639_2_code: 'fij'),
    Language.create(english_name: 'Filipino; Pilipino', native_name: 'filipino; pilipino', iso639_2_code: 'fil'),
    Language.create(english_name: 'Finnish', native_name: 'finnois', iso639_2_code: 'fin'),
    Language.create(english_name: 'Finno-Ugrian languages', native_name: 'finno-ougriennes, langues', iso639_2_code: 'fiu'),
    Language.create(english_name: 'Fon', native_name: 'fon', iso639_2_code: 'fon'),
    Language.create(english_name: 'French', native_name: 'français', iso639_2_code: 'fre'),
    Language.create(english_name: 'French, Middle (ca.1400-1600)', native_name: 'français moyen (1400-1600)', iso639_2_code: 'frm'),
    Language.create(english_name: 'French, Old (842-ca.1400)', native_name: 'français ancien (842-ca.1400)', iso639_2_code: 'fro'),
    Language.create(english_name: 'Northern Frisian', native_name: 'frison septentrional', iso639_2_code: 'frr'),
    Language.create(english_name: 'Eastern Frisian', native_name: 'frison oriental', iso639_2_code: 'frs'),
    Language.create(english_name: 'Western Frisian', native_name: 'frison occidental', iso639_2_code: 'fry'),
    Language.create(english_name: 'Fulah', native_name: 'peul', iso639_2_code: 'ful'),
    Language.create(english_name: 'Friulian', native_name: 'frioulan', iso639_2_code: 'fur'),
    Language.create(english_name: 'Ga', native_name: 'ga', iso639_2_code: 'gaa'),
    Language.create(english_name: 'Gayo', native_name: 'gayo', iso639_2_code: 'gay'),
    Language.create(english_name: 'Gbaya', native_name: 'gbaya', iso639_2_code: 'gba'),
    Language.create(english_name: 'Germanic languages', native_name: 'germaniques, langues', iso639_2_code: 'gem'),
    Language.create(english_name: 'Georgian', native_name: 'géorgien', iso639_2_code: 'geo'),
    Language.create(english_name: 'German', native_name: 'allemand', iso639_2_code: 'ger'),
    Language.create(english_name: 'Geez', native_name: 'guèze', iso639_2_code: 'gez'),
    Language.create(english_name: 'Gilbertese', native_name: 'kiribati', iso639_2_code: 'gil'),
    Language.create(english_name: 'Gaelic; Scottish Gaelic', native_name: 'gaélique; gaélique écossais', iso639_2_code: 'gla'),
    Language.create(english_name: 'Irish', native_name: 'irlandais', iso639_2_code: 'gle'),
    Language.create(english_name: 'Galician', native_name: 'galicien', iso639_2_code: 'glg'),
    Language.create(english_name: 'Manx', native_name: 'manx; mannois', iso639_2_code: 'glv'),
    Language.create(english_name: 'German, Middle High (ca.1050-1500)', native_name: 'allemand, moyen haut (ca. 1050-1500)', iso639_2_code: 'gmh'),
    Language.create(english_name: 'German, Old High (ca.750-1050)', native_name: 'allemand, vieux haut (ca. 750-1050)', iso639_2_code: 'goh'),
    Language.create(english_name: 'Gondi', native_name: 'gond', iso639_2_code: 'gon'),
    Language.create(english_name: 'Gorontalo', native_name: 'gorontalo', iso639_2_code: 'gor'),
    Language.create(english_name: 'Gothic', native_name: 'gothique', iso639_2_code: 'got'),
    Language.create(english_name: 'Grebo', native_name: 'grebo', iso639_2_code: 'grb'),
    Language.create(english_name: 'Greek, Ancient (to 1453)', native_name: 'grec ancien (jusqu\'à 1453)', iso639_2_code: 'grc'),
    Language.create(english_name: 'Greek, Modern (1453-)', native_name: 'grec moderne (après 1453)', iso639_2_code: 'gre'),
    Language.create(english_name: 'Guarani', native_name: 'guarani', iso639_2_code: 'grn'),
    Language.create(english_name: 'Swiss German; Alemannic; Alsatian', native_name: 'suisse alémanique; alémanique; alsacien', iso639_2_code: 'gsw'),
    Language.create(english_name: 'Gujarati', native_name: 'goudjrati', iso639_2_code: 'guj'),
    Language.create(english_name: 'Gwich\'in', native_name: 'gwich\'in', iso639_2_code: 'gwi'),
    Language.create(english_name: 'Haida', native_name: 'haida', iso639_2_code: 'hai'),
    Language.create(english_name: 'Haitian; Haitian Creole', native_name: 'haïtien; créole haïtien', iso639_2_code: 'hat'),
    Language.create(english_name: 'Hausa', native_name: 'haoussa', iso639_2_code: 'hau'),
    Language.create(english_name: 'Hawaiian', native_name: 'hawaïen', iso639_2_code: 'haw'),
    Language.create(english_name: 'Hebrew', native_name: 'hébreu', iso639_2_code: 'heb'),
    Language.create(english_name: 'Herero', native_name: 'herero', iso639_2_code: 'her'),
    Language.create(english_name: 'Hiligaynon', native_name: 'hiligaynon', iso639_2_code: 'hil'),
    Language.create(english_name: 'Himachali languages; Western Pahari languages', native_name: 'langues himachalis; langues paharis occidentales', iso639_2_code: 'him'),
    Language.create(english_name: 'Hindi', native_name: 'hindi', iso639_2_code: 'hin'),
    Language.create(english_name: 'Hittite', native_name: 'hittite', iso639_2_code: 'hit'),
    Language.create(english_name: 'Hmong; Mong', native_name: 'hmong', iso639_2_code: 'hmn'),
    Language.create(english_name: 'Hiri Motu', native_name: 'hiri motu', iso639_2_code: 'hmo'),
    Language.create(english_name: 'Croatian', native_name: 'croate', iso639_2_code: 'hrv'),
    Language.create(english_name: 'Upper Sorbian', native_name: 'haut-sorabe', iso639_2_code: 'hsb'),
    Language.create(english_name: 'Hungarian', native_name: 'hongrois', iso639_2_code: 'hun'),
    Language.create(english_name: 'Hupa', native_name: 'hupa', iso639_2_code: 'hup'),
    Language.create(english_name: 'Iban', native_name: 'iban', iso639_2_code: 'iba'),
    Language.create(english_name: 'Igbo', native_name: 'igbo', iso639_2_code: 'ibo'),
    Language.create(english_name: 'Icelandic', native_name: 'islandais', iso639_2_code: 'ice'),
    Language.create(english_name: 'Ido', native_name: 'ido', iso639_2_code: 'ido'),
    Language.create(english_name: 'Sichuan Yi; Nuosu', native_name: 'yi de Sichuan', iso639_2_code: 'iii'),
    Language.create(english_name: 'Ijo languages', native_name: 'ijo, langues', iso639_2_code: 'ijo'),
    Language.create(english_name: 'Inuktitut', native_name: 'inuktitut', iso639_2_code: 'iku'),
    Language.create(english_name: 'Interlingue; Occidental', native_name: 'interlingue', iso639_2_code: 'ile'),
    Language.create(english_name: 'Iloko', native_name: 'ilocano', iso639_2_code: 'ilo'),
    Language.create(english_name: 'Interlingua (International Auxiliary Language Association)', native_name: 'interlingua (langue auxiliaire internationale)', iso639_2_code: 'ina'),
    Language.create(english_name: 'Indic languages', native_name: 'indo-aryennes, langues', iso639_2_code: 'inc'),
    Language.create(english_name: 'Indonesian', native_name: 'indonésien', iso639_2_code: 'ind'),
    Language.create(english_name: 'Indo-European languages', native_name: 'indo-européennes, langues', iso639_2_code: 'ine'),
    Language.create(english_name: 'Ingush', native_name: 'ingouche', iso639_2_code: 'inh'),
    Language.create(english_name: 'Inupiaq', native_name: 'inupiaq', iso639_2_code: 'ipk'),
    Language.create(english_name: 'Iranian languages', native_name: 'iraniennes, langues', iso639_2_code: 'ira'),
    Language.create(english_name: 'Iroquoian languages', native_name: 'iroquoises, langues', iso639_2_code: 'iro'),
    Language.create(english_name: 'Italian', native_name: 'italien', iso639_2_code: 'ita'),
    Language.create(english_name: 'Javanese', native_name: 'javanais', iso639_2_code: 'jav'),
    Language.create(english_name: 'Lojban', native_name: 'lojban', iso639_2_code: 'jbo'),
    Language.create(english_name: 'Japanese', native_name: 'japonais', iso639_2_code: 'jpn'),
    Language.create(english_name: 'Judeo-Persian', native_name: 'judéo-persan', iso639_2_code: 'jpr'),
    Language.create(english_name: 'Judeo-Arabic', native_name: 'judéo-arabe', iso639_2_code: 'jrb'),
    Language.create(english_name: 'Kara-Kalpak', native_name: 'karakalpak', iso639_2_code: 'kaa'),
    Language.create(english_name: 'Kabyle', native_name: 'kabyle', iso639_2_code: 'kab'),
    Language.create(english_name: 'Kachin; Jingpho', native_name: 'kachin; jingpho', iso639_2_code: 'kac'),
    Language.create(english_name: 'Kalaallisut; Greenlandic', native_name: 'groenlandais', iso639_2_code: 'kal'),
    Language.create(english_name: 'Kamba', native_name: 'kamba', iso639_2_code: 'kam'),
    Language.create(english_name: 'Kannada', native_name: 'kannada', iso639_2_code: 'kan'),
    Language.create(english_name: 'Karen languages', native_name: 'karen, langues', iso639_2_code: 'kar'),
    Language.create(english_name: 'Kashmiri', native_name: 'kashmiri', iso639_2_code: 'kas'),
    Language.create(english_name: 'Kanuri', native_name: 'kanouri', iso639_2_code: 'kau'),
    Language.create(english_name: 'Kawi', native_name: 'kawi', iso639_2_code: 'kaw'),
    Language.create(english_name: 'Kazakh', native_name: 'kazakh', iso639_2_code: 'kaz'),
    Language.create(english_name: 'Kabardian', native_name: 'kabardien', iso639_2_code: 'kbd'),
    Language.create(english_name: 'Khasi', native_name: 'khasi', iso639_2_code: 'kha'),
    Language.create(english_name: 'Khoisan languages', native_name: 'khoïsan, langues', iso639_2_code: 'khi'),
    Language.create(english_name: 'Central Khmer', native_name: 'khmer central', iso639_2_code: 'khm'),
    Language.create(english_name: 'Khotanese; Sakan', native_name: 'khotanais; sakan', iso639_2_code: 'kho'),
    Language.create(english_name: 'Kikuyu; Gikuyu', native_name: 'kikuyu', iso639_2_code: 'kik'),
    Language.create(english_name: 'Kinyarwanda', native_name: 'rwanda', iso639_2_code: 'kin'),
    Language.create(english_name: 'Kirghiz; Kyrgyz', native_name: 'kirghiz', iso639_2_code: 'kir'),
    Language.create(english_name: 'Kimbundu', native_name: 'kimbundu', iso639_2_code: 'kmb'),
    Language.create(english_name: 'Konkani', native_name: 'konkani', iso639_2_code: 'kok'),
    Language.create(english_name: 'Komi', native_name: 'kom', iso639_2_code: 'kom'),
    Language.create(english_name: 'Kongo', native_name: 'kongo', iso639_2_code: 'kon'),
    Language.create(english_name: 'Korean', native_name: 'coréen', iso639_2_code: 'kor'),
    Language.create(english_name: 'Kosraean', native_name: 'kosrae', iso639_2_code: 'kos'),
    Language.create(english_name: 'Kpelle', native_name: 'kpellé', iso639_2_code: 'kpe'),
    Language.create(english_name: 'Karachay-Balkar', native_name: 'karatchai balkar', iso639_2_code: 'krc'),
    Language.create(english_name: 'Karelian', native_name: 'carélien', iso639_2_code: 'krl'),
    Language.create(english_name: 'Kru languages', native_name: 'krou, langues', iso639_2_code: 'kro'),
    Language.create(english_name: 'Kurukh', native_name: 'kurukh', iso639_2_code: 'kru'),
    Language.create(english_name: 'Kuanyama; Kwanyama', native_name: 'kuanyama; kwanyama', iso639_2_code: 'kua'),
    Language.create(english_name: 'Kumyk', native_name: 'koumyk', iso639_2_code: 'kum'),
    Language.create(english_name: 'Kurdish', native_name: 'kurde', iso639_2_code: 'kur'),
    Language.create(english_name: 'Kutenai', native_name: 'kutenai', iso639_2_code: 'kut'),
    Language.create(english_name: 'Ladino', native_name: 'judéo-espagnol', iso639_2_code: 'lad'),
    Language.create(english_name: 'Lahnda', native_name: 'lahnda', iso639_2_code: 'lah'),
    Language.create(english_name: 'Lamba', native_name: 'lamba', iso639_2_code: 'lam'),
    Language.create(english_name: 'Lao', native_name: 'lao', iso639_2_code: 'lao'),
    Language.create(english_name: 'Latin', native_name: 'latin', iso639_2_code: 'lat'),
    Language.create(english_name: 'Latvian', native_name: 'letton', iso639_2_code: 'lav'),
    Language.create(english_name: 'Lezghian', native_name: 'lezghien', iso639_2_code: 'lez'),
    Language.create(english_name: 'Limburgan; Limburger; Limburgish', native_name: 'limbourgeois', iso639_2_code: 'lim'),
    Language.create(english_name: 'Lingala', native_name: 'lingala', iso639_2_code: 'lin'),
    Language.create(english_name: 'Lithuanian', native_name: 'lituanien', iso639_2_code: 'lit'),
    Language.create(english_name: 'Mongo', native_name: 'mongo', iso639_2_code: 'lol'),
    Language.create(english_name: 'Lozi', native_name: 'lozi', iso639_2_code: 'loz'),
    Language.create(english_name: 'Luxembourgish; Letzeburgesch', native_name: 'luxembourgeois', iso639_2_code: 'ltz'),
    Language.create(english_name: 'Luba-Lulua', native_name: 'luba-lulua', iso639_2_code: 'lua'),
    Language.create(english_name: 'Luba-Katanga', native_name: 'luba-katanga', iso639_2_code: 'lub'),
    Language.create(english_name: 'Ganda', native_name: 'ganda', iso639_2_code: 'lug'),
    Language.create(english_name: 'Luiseno', native_name: 'luiseno', iso639_2_code: 'lui'),
    Language.create(english_name: 'Lunda', native_name: 'lunda', iso639_2_code: 'lun'),
    Language.create(english_name: 'Luo (Kenya and Tanzania)', native_name: 'luo (Kenya et Tanzanie)', iso639_2_code: 'luo'),
    Language.create(english_name: 'Lushai', native_name: 'lushai', iso639_2_code: 'lus'),
    Language.create(english_name: 'Macedonian', native_name: 'macédonien', iso639_2_code: 'mac'),
    Language.create(english_name: 'Madurese', native_name: 'madourais', iso639_2_code: 'mad'),
    Language.create(english_name: 'Magahi', native_name: 'magahi', iso639_2_code: 'mag'),
    Language.create(english_name: 'Marshallese', native_name: 'marshall', iso639_2_code: 'mah'),
    Language.create(english_name: 'Maithili', native_name: 'maithili', iso639_2_code: 'mai'),
    Language.create(english_name: 'Makasar', native_name: 'makassar', iso639_2_code: 'mak'),
    Language.create(english_name: 'Malayalam', native_name: 'malayalam', iso639_2_code: 'mal'),
    Language.create(english_name: 'Mandingo', native_name: 'mandingue', iso639_2_code: 'man'),
    Language.create(english_name: 'Maori', native_name: 'maori', iso639_2_code: 'mao'),
    Language.create(english_name: 'Austronesian languages', native_name: 'austronésiennes, langues', iso639_2_code: 'map'),
    Language.create(english_name: 'Marathi', native_name: 'marathe', iso639_2_code: 'mar'),
    Language.create(english_name: 'Masai', native_name: 'massaï', iso639_2_code: 'mas'),
    Language.create(english_name: 'Malay', native_name: 'malais', iso639_2_code: 'may'),
    Language.create(english_name: 'Moksha', native_name: 'moksa', iso639_2_code: 'mdf'),
    Language.create(english_name: 'Mandar', native_name: 'mandar', iso639_2_code: 'mdr'),
    Language.create(english_name: 'Mende', native_name: 'mendé', iso639_2_code: 'men'),
    Language.create(english_name: 'Irish, Middle (900-1200)', native_name: 'irlandais moyen (900-1200)', iso639_2_code: 'mga'),
    Language.create(english_name: 'Mi\'kmaq; Micmac', native_name: 'mi\'kmaq; micmac', iso639_2_code: 'mic'),
    Language.create(english_name: 'Minangkabau', native_name: 'minangkabau', iso639_2_code: 'min'),
    Language.create(english_name: 'Uncoded languages', native_name: 'langues non codées', iso639_2_code: 'mis'),
    Language.create(english_name: 'Mon-Khmer languages', native_name: 'môn-khmer, langues', iso639_2_code: 'mkh'),
    Language.create(english_name: 'Malagasy', native_name: 'malgache', iso639_2_code: 'mlg'),
    Language.create(english_name: 'Maltese', native_name: 'maltais', iso639_2_code: 'mlt'),
    Language.create(english_name: 'Manchu', native_name: 'mandchou', iso639_2_code: 'mnc'),
    Language.create(english_name: 'Manipuri', native_name: 'manipuri', iso639_2_code: 'mni'),
    Language.create(english_name: 'Manobo languages', native_name: 'manobo, langues', iso639_2_code: 'mno'),
    Language.create(english_name: 'Mohawk', native_name: 'mohawk', iso639_2_code: 'moh'),
    Language.create(english_name: 'Mongolian', native_name: 'mongol', iso639_2_code: 'mon'),
    Language.create(english_name: 'Mossi', native_name: 'moré', iso639_2_code: 'mos'),
    Language.create(english_name: 'Multiple languages', native_name: 'multilingue', iso639_2_code: 'mul'),
    Language.create(english_name: 'Munda languages', native_name: 'mounda, langues', iso639_2_code: 'mun'),
    Language.create(english_name: 'Creek', native_name: 'muskogee', iso639_2_code: 'mus'),
    Language.create(english_name: 'Mirandese', native_name: 'mirandais', iso639_2_code: 'mwl'),
    Language.create(english_name: 'Marwari', native_name: 'marvari', iso639_2_code: 'mwr'),
    Language.create(english_name: 'Mayan languages', native_name: 'maya, langues', iso639_2_code: 'myn'),
    Language.create(english_name: 'Erzya', native_name: 'erza', iso639_2_code: 'myv'),
    Language.create(english_name: 'Nahuatl languages', native_name: 'nahuatl, langues', iso639_2_code: 'nah'),
    Language.create(english_name: 'North American Indian languages', native_name: 'nord-amérindiennes, langues', iso639_2_code: 'nai'),
    Language.create(english_name: 'Neapolitan', native_name: 'napolitain', iso639_2_code: 'nap'),
    Language.create(english_name: 'Nauru', native_name: 'nauruan', iso639_2_code: 'nau'),
    Language.create(english_name: 'Navajo; Navaho', native_name: 'navaho', iso639_2_code: 'nav'),
    Language.create(english_name: 'Ndebele, South; South Ndebele', native_name: 'ndébélé du Sud', iso639_2_code: 'nbl'),
    Language.create(english_name: 'Ndebele, North; North Ndebele', native_name: 'ndébélé du Nord', iso639_2_code: 'nde'),
    Language.create(english_name: 'Ndonga', native_name: 'ndonga', iso639_2_code: 'ndo'),
    Language.create(english_name: 'Low German; Low Saxon; German, Low; Saxon, Low', native_name: 'bas allemand; bas saxon; allemand, bas; saxon, bas', iso639_2_code: 'nds'),
    Language.create(english_name: 'Nepali', native_name: 'népalais', iso639_2_code: 'nep'),
    Language.create(english_name: 'Nepal Bhasa; Newari', native_name: 'nepal bhasa; newari', iso639_2_code: 'new'),
    Language.create(english_name: 'Nias', native_name: 'nias', iso639_2_code: 'nia'),
    Language.create(english_name: 'Niger-Kordofanian languages', native_name: 'nigéro-kordofaniennes, langues', iso639_2_code: 'nic'),
    Language.create(english_name: 'Niuean', native_name: 'niué', iso639_2_code: 'niu'),
    Language.create(english_name: 'Norwegian Nynorsk; Nynorsk, Norwegian', native_name: 'norvégien nynorsk; nynorsk, norvégien', iso639_2_code: 'nno'),
    Language.create(english_name: 'Bokmål, Norwegian; Norwegian Bokmål', native_name: 'norvégien bokmål', iso639_2_code: 'nob'),
    Language.create(english_name: 'Nogai', native_name: 'nogaï; nogay', iso639_2_code: 'nog'),
    Language.create(english_name: 'Norse, Old', native_name: 'norrois, vieux', iso639_2_code: 'non'),
    Language.create(english_name: 'Norwegian', native_name: 'norvégien', iso639_2_code: 'nor'),
    Language.create(english_name: 'N\'Ko', native_name: 'n\'ko', iso639_2_code: 'nqo'),
    Language.create(english_name: 'Pedi; Sepedi; Northern Sotho', native_name: 'pedi; sepedi; sotho du Nord', iso639_2_code: 'nso'),
    Language.create(english_name: 'Nubian languages', native_name: 'nubiennes, langues', iso639_2_code: 'nub'),
    Language.create(english_name: 'Classical Newari; Old Newari; Classical Nepal Bhasa', native_name: 'newari classique', iso639_2_code: 'nwc'),
    Language.create(english_name: 'Chichewa; Chewa; Nyanja', native_name: 'chichewa; chewa; nyanja', iso639_2_code: 'nya'),
    Language.create(english_name: 'Nyamwezi', native_name: 'nyamwezi', iso639_2_code: 'nym'),
    Language.create(english_name: 'Nyankole', native_name: 'nyankolé', iso639_2_code: 'nyn'),
    Language.create(english_name: 'Nyoro', native_name: 'nyoro', iso639_2_code: 'nyo'),
    Language.create(english_name: 'Nzima', native_name: 'nzema', iso639_2_code: 'nzi'),
    Language.create(english_name: 'Occitan (post 1500); Provençal', native_name: 'occitan (après 1500); provençal', iso639_2_code: 'oci'),
    Language.create(english_name: 'Ojibwa', native_name: 'ojibwa', iso639_2_code: 'oji'),
    Language.create(english_name: 'Oriya', native_name: 'oriya', iso639_2_code: 'ori'),
    Language.create(english_name: 'Oromo', native_name: 'galla', iso639_2_code: 'orm'),
    Language.create(english_name: 'Osage', native_name: 'osage', iso639_2_code: 'osa'),
    Language.create(english_name: 'Ossetian; Ossetic', native_name: 'ossète', iso639_2_code: 'oss'),
    Language.create(english_name: 'Turkish, Ottoman (1500-1928)', native_name: 'turc ottoman (1500-1928)', iso639_2_code: 'ota'),
    Language.create(english_name: 'Otomian languages', native_name: 'otomi, langues', iso639_2_code: 'oto'),
    Language.create(english_name: 'Papuan languages', native_name: 'papoues, langues', iso639_2_code: 'paa'),
    Language.create(english_name: 'Pangasinan', native_name: 'pangasinan', iso639_2_code: 'pag'),
    Language.create(english_name: 'Pahlavi', native_name: 'pahlavi', iso639_2_code: 'pal'),
    Language.create(english_name: 'Pampanga; Kapampangan', native_name: 'pampangan', iso639_2_code: 'pam'),
    Language.create(english_name: 'Panjabi; Punjabi', native_name: 'pendjabi', iso639_2_code: 'pan'),
    Language.create(english_name: 'Papiamento', native_name: 'papiamento', iso639_2_code: 'pap'),
    Language.create(english_name: 'Palauan', native_name: 'palau', iso639_2_code: 'pau'),
    Language.create(english_name: 'Persian, Old (ca.600-400 B.C.)', native_name: 'perse, vieux (ca. 600-400 av. J.-C.)', iso639_2_code: 'peo'),
    Language.create(english_name: 'Persian', native_name: 'persan', iso639_2_code: 'per'),
    Language.create(english_name: 'Philippine languages', native_name: 'philippines, langues', iso639_2_code: 'phi'),
    Language.create(english_name: 'Phoenician', native_name: 'phénicien', iso639_2_code: 'phn'),
    Language.create(english_name: 'Pali', native_name: 'pali', iso639_2_code: 'pli'),
    Language.create(english_name: 'Polish', native_name: 'polonais', iso639_2_code: 'pol'),
    Language.create(english_name: 'Pohnpeian', native_name: 'pohnpei', iso639_2_code: 'pon'),
    Language.create(english_name: 'Portuguese', native_name: 'portugais', iso639_2_code: 'por'),
    Language.create(english_name: 'Prakrit languages', native_name: 'prâkrit, langues', iso639_2_code: 'pra'),
    Language.create(english_name: 'Provençal, Old (to 1500)', native_name: 'provençal ancien (jusqu\'à 1500)', iso639_2_code: 'pro'),
    Language.create(english_name: 'Pushto; Pashto', native_name: 'pachto', iso639_2_code: 'pus'),
    Language.create(english_name: 'Reserved for local use', native_name: 'réservée à l\'usage local', iso639_2_code: 'qaa-qtz'),
    Language.create(english_name: 'Quechua', native_name: 'quechua', iso639_2_code: 'que'),
    Language.create(english_name: 'Rajasthani', native_name: 'rajasthani', iso639_2_code: 'raj'),
    Language.create(english_name: 'Rapanui', native_name: 'rapanui', iso639_2_code: 'rap'),
    Language.create(english_name: 'Rarotongan; Cook Islands Maori', native_name: 'rarotonga; maori des îles Cook', iso639_2_code: 'rar'),
    Language.create(english_name: 'Romance languages', native_name: 'romanes, langues', iso639_2_code: 'roa'),
    Language.create(english_name: 'Romansh', native_name: 'romanche', iso639_2_code: 'roh'),
    Language.create(english_name: 'Romany', native_name: 'tsigane', iso639_2_code: 'rom'),
    Language.create(english_name: 'Romanian; Moldavian; Moldovan', native_name: 'roumain; moldave', iso639_2_code: 'rum'),
    Language.create(english_name: 'Rundi', native_name: 'rundi', iso639_2_code: 'run'),
    Language.create(english_name: 'Aromanian; Arumanian; Macedo-Romanian', native_name: 'aroumain; macédo-roumain', iso639_2_code: 'rup'),
    Language.create(english_name: 'Russian', native_name: 'russe', iso639_2_code: 'rus'),
    Language.create(english_name: 'Sandawe', native_name: 'sandawe', iso639_2_code: 'sad'),
    Language.create(english_name: 'Sango', native_name: 'sango', iso639_2_code: 'sag'),
    Language.create(english_name: 'Yakut', native_name: 'iakoute', iso639_2_code: 'sah'),
    Language.create(english_name: 'South American Indian (Other)', native_name: 'indiennes d\'Amérique du Sud, autres langues', iso639_2_code: 'sai'),
    Language.create(english_name: 'Salishan languages', native_name: 'salishennes, langues', iso639_2_code: 'sal'),
    Language.create(english_name: 'Samaritan Aramaic', native_name: 'samaritain', iso639_2_code: 'sam'),
    Language.create(english_name: 'Sanskrit', native_name: 'sanskrit', iso639_2_code: 'san'),
    Language.create(english_name: 'Sasak', native_name: 'sasak', iso639_2_code: 'sas'),
    Language.create(english_name: 'Santali', native_name: 'santal', iso639_2_code: 'sat'),
    Language.create(english_name: 'Sicilian', native_name: 'sicilien', iso639_2_code: 'scn'),
    Language.create(english_name: 'Scots', native_name: 'écossais', iso639_2_code: 'sco'),
    Language.create(english_name: 'Selkup', native_name: 'selkoupe', iso639_2_code: 'sel'),
    Language.create(english_name: 'Semitic languages', native_name: 'sémitiques, langues', iso639_2_code: 'sem'),
    Language.create(english_name: 'Irish, Old (to 900)', native_name: 'irlandais ancien (jusqu\'à 900)', iso639_2_code: 'sga'),
    Language.create(english_name: 'Sign Languages', native_name: 'langues des signes', iso639_2_code: 'sgn'),
    Language.create(english_name: 'Shan', native_name: 'chan', iso639_2_code: 'shn'),
    Language.create(english_name: 'Sidamo', native_name: 'sidamo', iso639_2_code: 'sid'),
    Language.create(english_name: 'Sinhala; Sinhalese', native_name: 'singhalais', iso639_2_code: 'sin'),
    Language.create(english_name: 'Siouan languages', native_name: 'sioux, langues', iso639_2_code: 'sio'),
    Language.create(english_name: 'Sino-Tibetan languages', native_name: 'sino-tibétaines, langues', iso639_2_code: 'sit'),
    Language.create(english_name: 'Slavic languages', native_name: 'slaves, langues', iso639_2_code: 'sla'),
    Language.create(english_name: 'Slovak', native_name: 'slovaque', iso639_2_code: 'slo'),
    Language.create(english_name: 'Slovenian', native_name: 'slovène', iso639_2_code: 'slv'),
    Language.create(english_name: 'Southern Sami', native_name: 'sami du Sud', iso639_2_code: 'sma'),
    Language.create(english_name: 'Northern Sami', native_name: 'sami du Nord', iso639_2_code: 'sme'),
    Language.create(english_name: 'Sami languages', native_name: 'sames, langues', iso639_2_code: 'smi'),
    Language.create(english_name: 'Lule Sami', native_name: 'sami de Lule', iso639_2_code: 'smj'),
    Language.create(english_name: 'Inari Sami', native_name: 'sami d\'Inari', iso639_2_code: 'smn'),
    Language.create(english_name: 'Samoan', native_name: 'samoan', iso639_2_code: 'smo'),
    Language.create(english_name: 'Skolt Sami', native_name: 'sami skolt', iso639_2_code: 'sms'),
    Language.create(english_name: 'Shona', native_name: 'shona', iso639_2_code: 'sna'),
    Language.create(english_name: 'Sindhi', native_name: 'sindhi', iso639_2_code: 'snd'),
    Language.create(english_name: 'Soninke', native_name: 'soninké', iso639_2_code: 'snk'),
    Language.create(english_name: 'Sogdian', native_name: 'sogdien', iso639_2_code: 'sog'),
    Language.create(english_name: 'Somali', native_name: 'somali', iso639_2_code: 'som'),
    Language.create(english_name: 'Songhai languages', native_name: 'songhai, langues', iso639_2_code: 'son'),
    Language.create(english_name: 'Sotho, Southern', native_name: 'sotho du Sud', iso639_2_code: 'sot'),
    Language.create(english_name: 'Spanish; Castilian', native_name: 'espagnol; castillan', iso639_2_code: 'spa'),
    Language.create(english_name: 'Sardinian', native_name: 'sarde', iso639_2_code: 'srd'),
    Language.create(english_name: 'Sranan Tongo', native_name: 'sranan tongo', iso639_2_code: 'srn'),
    Language.create(english_name: 'Serbian', native_name: 'serbe', iso639_2_code: 'srp'),
    Language.create(english_name: 'Serer', native_name: 'sérère', iso639_2_code: 'srr'),
    Language.create(english_name: 'Nilo-Saharan languages', native_name: 'nilo-sahariennes, langues', iso639_2_code: 'ssa'),
    Language.create(english_name: 'Swati', native_name: 'swati', iso639_2_code: 'ssw'),
    Language.create(english_name: 'Sukuma', native_name: 'sukuma', iso639_2_code: 'suk'),
    Language.create(english_name: 'Sundanese', native_name: 'soundanais', iso639_2_code: 'sun'),
    Language.create(english_name: 'Susu', native_name: 'soussou', iso639_2_code: 'sus'),
    Language.create(english_name: 'Sumerian', native_name: 'sumérien', iso639_2_code: 'sux'),
    Language.create(english_name: 'Swahili', native_name: 'swahili', iso639_2_code: 'swa'),
    Language.create(english_name: 'Swedish', native_name: 'suédois', iso639_2_code: 'swe'),
    Language.create(english_name: 'Classical Syriac', native_name: 'syriaque classique', iso639_2_code: 'syc'),
    Language.create(english_name: 'Syriac', native_name: 'syriaque', iso639_2_code: 'syr'),
    Language.create(english_name: 'Tahitian', native_name: 'tahitien', iso639_2_code: 'tah'),
    Language.create(english_name: 'Tai languages', native_name: 'tai, langues', iso639_2_code: 'tai'),
    Language.create(english_name: 'Tamil', native_name: 'tamoul', iso639_2_code: 'tam'),
    Language.create(english_name: 'Tatar', native_name: 'tatar', iso639_2_code: 'tat'),
    Language.create(english_name: 'Telugu', native_name: 'télougou', iso639_2_code: 'tel'),
    Language.create(english_name: 'Timne', native_name: 'temne', iso639_2_code: 'tem'),
    Language.create(english_name: 'Tereno', native_name: 'tereno', iso639_2_code: 'ter'),
    Language.create(english_name: 'Tetum', native_name: 'tetum', iso639_2_code: 'tet'),
    Language.create(english_name: 'Tajik', native_name: 'tadjik', iso639_2_code: 'tgk'),
    Language.create(english_name: 'Tagalog', native_name: 'tagalog', iso639_2_code: 'tgl'),
    Language.create(english_name: 'Thai', native_name: 'thaï', iso639_2_code: 'tha'),
    Language.create(english_name: 'Tibetan', native_name: 'tibétain', iso639_2_code: 'tib'),
    Language.create(english_name: 'Tigre', native_name: 'tigré', iso639_2_code: 'tig'),
    Language.create(english_name: 'Tigrinya', native_name: 'tigrigna', iso639_2_code: 'tir'),
    Language.create(english_name: 'Tiv', native_name: 'tiv', iso639_2_code: 'tiv'),
    Language.create(english_name: 'Tokelau', native_name: 'tokelau', iso639_2_code: 'tkl'),
    Language.create(english_name: 'Klingon; tlhIngan-Hol', native_name: 'klingon', iso639_2_code: 'tlh'),
    Language.create(english_name: 'Tlingit', native_name: 'tlingit', iso639_2_code: 'tli'),
    Language.create(english_name: 'Tamashek', native_name: 'tamacheq', iso639_2_code: 'tmh'),
    Language.create(english_name: 'Tonga (Nyasa)', native_name: 'tonga (Nyasa)', iso639_2_code: 'tog'),
    Language.create(english_name: 'Tonga (Tonga Islands)', native_name: 'tongan (Îles Tonga)', iso639_2_code: 'ton'),
    Language.create(english_name: 'Tok Pisin', native_name: 'tok pisin', iso639_2_code: 'tpi'),
    Language.create(english_name: 'Tsimshian', native_name: 'tsimshian', iso639_2_code: 'tsi'),
    Language.create(english_name: 'Tswana', native_name: 'tswana', iso639_2_code: 'tsn'),
    Language.create(english_name: 'Tsonga', native_name: 'tsonga', iso639_2_code: 'tso'),
    Language.create(english_name: 'Turkmen', native_name: 'turkmène', iso639_2_code: 'tuk'),
    Language.create(english_name: 'Tumbuka', native_name: 'tumbuka', iso639_2_code: 'tum'),
    Language.create(english_name: 'Tupi languages', native_name: 'tupi, langues', iso639_2_code: 'tup'),
    Language.create(english_name: 'Turkish', native_name: 'turc', iso639_2_code: 'tur'),
    Language.create(english_name: 'Altaic languages', native_name: 'altaïques, langues', iso639_2_code: 'tut'),
    Language.create(english_name: 'Tuvalu', native_name: 'tuvalu', iso639_2_code: 'tvl'),
    Language.create(english_name: 'Twi', native_name: 'twi', iso639_2_code: 'twi'),
    Language.create(english_name: 'Tuvinian', native_name: 'touva', iso639_2_code: 'tyv'),
    Language.create(english_name: 'Udmurt', native_name: 'oudmourte', iso639_2_code: 'udm'),
    Language.create(english_name: 'Ugaritic', native_name: 'ougaritique', iso639_2_code: 'uga'),
    Language.create(english_name: 'Uighur; Uyghur', native_name: 'ouïgour', iso639_2_code: 'uig'),
    Language.create(english_name: 'Ukrainian', native_name: 'ukrainien', iso639_2_code: 'ukr'),
    Language.create(english_name: 'Umbundu', native_name: 'umbundu', iso639_2_code: 'umb'),
    Language.create(english_name: 'Undetermined', native_name: 'indéterminée', iso639_2_code: 'und'),
    Language.create(english_name: 'Urdu', native_name: 'ourdou', iso639_2_code: 'urd'),
    Language.create(english_name: 'Uzbek', native_name: 'ouszbek', iso639_2_code: 'uzb'),
    Language.create(english_name: 'Vai', native_name: 'vaï', iso639_2_code: 'vai'),
    Language.create(english_name: 'Venda', native_name: 'venda', iso639_2_code: 'ven'),
    Language.create(english_name: 'Vietnamese', native_name: 'vietnamien', iso639_2_code: 'vie'),
    Language.create(english_name: 'Volapük', native_name: 'volapük', iso639_2_code: 'vol'),
    Language.create(english_name: 'Votic', native_name: 'vote', iso639_2_code: 'vot'),
    Language.create(english_name: 'Wakashan languages', native_name: 'wakashanes, langues', iso639_2_code: 'wak'),
    Language.create(english_name: 'Walamo', native_name: 'walamo', iso639_2_code: 'wal'),
    Language.create(english_name: 'Waray', native_name: 'waray', iso639_2_code: 'war'),
    Language.create(english_name: 'Washo', native_name: 'washo', iso639_2_code: 'was'),
    Language.create(english_name: 'Welsh', native_name: 'gallois', iso639_2_code: 'wel'),
    Language.create(english_name: 'Sorbian languages', native_name: 'sorabes, langues', iso639_2_code: 'wen'),
    Language.create(english_name: 'Walloon', native_name: 'wallon', iso639_2_code: 'wln'),
    Language.create(english_name: 'Wolof', native_name: 'wolof', iso639_2_code: 'wol'),
    Language.create(english_name: 'Kalmyk; Oirat', native_name: 'kalmouk; oïrat', iso639_2_code: 'xal'),
    Language.create(english_name: 'Xhosa', native_name: 'xhosa', iso639_2_code: 'xho'),
    Language.create(english_name: 'Yao', native_name: 'yao', iso639_2_code: 'yao'),
    Language.create(english_name: 'Yapese', native_name: 'yapois', iso639_2_code: 'yap'),
    Language.create(english_name: 'Yiddish', native_name: 'yiddish', iso639_2_code: 'yid'),
    Language.create(english_name: 'Yoruba', native_name: 'yoruba', iso639_2_code: 'yor'),
    Language.create(english_name: 'Yupik languages', native_name: 'yupik, langues', iso639_2_code: 'ypk'),
    Language.create(english_name: 'Zapotec', native_name: 'zapotèque', iso639_2_code: 'zap'),
    Language.create(english_name: 'Blissymbols; Blissymbolics; Bliss', native_name: 'symboles Bliss; Bliss', iso639_2_code: 'zbl'),
    Language.create(english_name: 'Zenaga', native_name: 'zenaga', iso639_2_code: 'zen'),
    Language.create(english_name: 'Standard Moroccan Tamazight', native_name: 'amazighe standard marocain', iso639_2_code: 'zgh'),
    Language.create(english_name: 'Zhuang; Chuang', native_name: 'zhuang; chuang', iso639_2_code: 'zha'),
    Language.create(english_name: 'Zande languages', native_name: 'zandé, langues', iso639_2_code: 'znd'),
    Language.create(english_name: 'Zulu', native_name: 'zoulou', iso639_2_code: 'zul'),
    Language.create(english_name: 'Zuni', native_name: 'zuni', iso639_2_code: 'zun'),
    Language.create(english_name: 'No linguistic content; Not applicable', native_name: 'pas de contenu linguistique; non applicable', iso639_2_code: 'zxx'),
    Language.create(english_name: 'Zaza; Dimili; Dimli; Kirdki; Kirmanjki; Zazaki', native_name: 'zaza; dimili; dimli; kirdki; kirmanjki; zazaki', iso639_2_code: 'zza')
]

xls = Roo::Spreadsheet.open('db/seed_data/assessment_questions.xlsx')

# Formats
sheet = xls.sheet('Format Scores')
sheet.each_with_index do |row, i|
  if i > 0 # skip header row
    name = parent = nil
    (2..5).reverse_each do |col|
      if name.blank? and !row[col].blank?
        name = row[col]
        if col > 2 # find its parent FID by iterating backwards
          (0..i).reverse_each do |j|
            if sheet.row(j)[col].blank?
              parent = Format.find_by_fid(sheet.row(j)[1])
              break
            end
          end
        else
          parent = nil
        end
      end
    end
    unless name.blank?
      Format.create!(fid: row[1],
                     name: name,
                     format_class: FormatClass::class_for_name(row[0]),
                     parent: parent,
                     score: row[6])
    end
  end
end

# Format Vector Groups & Ink/Media Types
FormatVectorGroup.create!(name: 'Other')
xls.sheet('InkMedia Scores').each_with_index do |row, i|
  if i > 0 # skip header row
    group_name = row[2] || 'Other'
    group = FormatVectorGroup.find_by_name(group_name)
    group ||= FormatVectorGroup.create!(name: group_name)
    FormatInkMediaType.create!(name: row[0], score: row[4],
                               format_vector_group: group)
  end
end

# Format Support Types
xls.sheet('Support Scores').each_with_index do |row, i|
  if i > 0 # skip header row
    FormatSupportType.create!(name: row[0], score: row[4])
  end
end

# Assessments
assessments = [
    Assessment.create!(name: 'Resource Assessment', key: 'resource'),
    Assessment.create!(name: 'Location Assessment', key: 'location'),
    Assessment.create!(name: 'Institution Assessment', key: 'institution')
]

# Assessment sections
sections = {}
command = CreateAssessmentSectionCommand.new(
    { name: 'Use / Access', index: 0, weight: 0.05,
      description: 'The following questions concern the level of use/handling '\
      'of the object(s).',
      assessment: assessments[0] }, nil, '127.0.0.1')
command.execute
sections[:use_access] = command.object

command = CreateAssessmentSectionCommand.new(
    { name: 'Storage / Container', index: 1, weight: 0.05,
      description: 'The following questions concern the appropriateness of '\
      'storage, housing, and labeling.',
      assessment: assessments[0] }, nil, '127.0.0.1')
command.execute
sections[:storage_container] = command.object

command = CreateAssessmentSectionCommand.new(
    { name: 'Condition', index: 2, weight: 0.4,
      description: 'The following questions concern the physical state of the '\
      'resource, and to what degree this impacts its content.',
      assessment: assessments[0] }, nil, '127.0.0.1')
command.execute
sections[:condition] = command.object

# Assessment questions
aq_sheets = %w(Resource-Paper-Unbound Resource-Photo Resource-AV Resource-Paper-Bound)
#aq_sheets = %w(Resource-Paper-Bound)
aq_sheets.each do |sheet|
  xls.sheet(sheet).each_with_index do |row, index|
    if index > 0 and !row[7].blank? # skip header & trailing rows
      params = {
          qid: row[6].to_i,
          name: row[7].strip,
          question_type: (!row[12].blank? and row[12].downcase == 'checkboxes') ?
              AssessmentQuestionType::CHECKBOX : AssessmentQuestionType::RADIO,
          index: index,
          weight: row[9].to_f,
          help_text: row[8].strip
      }
      case row[5][0..2].strip.downcase
        when 'use'
          params[:assessment_section] = sections[:use_access]
        when 'sto'
          params[:assessment_section] = sections[:storage_container]
        else
          params[:assessment_section] = sections[:condition]
      end

      unless row[10].blank? or row[10].to_s.include?('TBD') or row[11].blank?
        params[:parent] = AssessmentQuestion.find_by_qid(row[10].to_i)
        params[:enabling_assessment_question_options] = []
        row[11].split(';').map{ |x| x.strip }.each do |dep|
          eaqo = params[:parent].assessment_question_options.where(name: dep)[0]
          if eaqo
            params[:enabling_assessment_question_options] << eaqo
          else
            puts 'AQO error: QID ' + row[10].to_s + ': ' + dep
          end
        end
      end

      params[:formats] = Format.where('id IN (?)',
                                      row[4].to_s.split(';').map{ |f| f.strip.to_i })

      command = CreateAssessmentQuestionCommand.new(params, nil, '127.0.0.1')
      command.execute

      command.object.assessment_question_options << AssessmentQuestionOption.new(
          name: row[13], index: 0, value: row[14]) if row[13] and row[14]
      command.object.assessment_question_options << AssessmentQuestionOption.new(
          name: row[15], index: 1, value: row[16]) if row[15] and row[16]
      command.object.assessment_question_options << AssessmentQuestionOption.new(
          name: row[17], index: 2, value: row[18]) if row[17] and row[18]
      command.object.assessment_question_options << AssessmentQuestionOption.new(
          name: row[19], index: 3, value: row[20]) if row[19] and row[20]
      command.object.assessment_question_options << AssessmentQuestionOption.new(
          name: row[21], index: 4, value: row[22]) if row[21] and row[22]
      command.object.save!
    end
  end
end

# Formats in Format ID Guide
xls = Roo::Spreadsheet.open('db/seed_data/formats.xlsx')
sheet = xls.sheet('Formats')
sheet.each_with_index do |row, i|
  if i > 0 # skip header row
    FormatInfo.create!(
        format_class: FormatClass::class_for_name(row[0]),
        format_category: row[1], name: row[2], anchor: row[3],
        images: row[4], image_captions: row[5],
        image_alts: row[6], synonyms: row[7], dates: row[8],
        common_sizes: row[9], description: row[10],
        composition: row[11], deterioration: row[12],
        risk_level: row[13], playback: row[14],
        background: row[15], storage_environment: row[16],
        storage_enclosure: row[17], storage_orientation: row[18],
        handling_care: row[19], cd_standard_specifications: row[20])
  end
end

# Admin role
admin_role = Role.create!(name: 'Administrator', is_admin: true)

# Normal role
normal_role = Role.create!(name: 'User', is_admin: false)

# Admin user
command = CreateUserCommand.new(
    { username: 'admin', email: 'admin@example.org',
      first_name: 'Admin', last_name: 'Admin',
      password: 'password', password_confirmation: 'password',
      confirmed: true, enabled: true }, '127.0.0.1', false)
command.execute
admin_user = command.object
admin_user.role = admin_role
admin_user.save!

# From here, we seed the database differently depending on the environment.
case Rails.env

  when 'development'
    # Institutions
    institution_commands = [
        CreateInstitutionCommand.new( # TODO: add this in production
            { name: 'University of Illinois at Urbana-Champaign',
              address1: '1408 W. Gregory Dr.',
              address2: nil,
              city: 'Urbana',
              state: 'IL',
              postal_code: 61801,
              country: 'United States of America',
              url: 'http://www.library.illinois.edu/',
              email: 'test@example.org',
              language: languages[122],
              description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1'),
        CreateInstitutionCommand.new(
            { name: 'West Southeast Directional State University',
              address1: '1 Directional Drive',
              address2: nil,
              city: 'Podunk',
              state: 'IL',
              postal_code: 12345,
              country: 'United States of America',
              url: 'http://example.org/',
              email: 'test@example.org',
              description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1'),
        CreateInstitutionCommand.new(
            { name: 'Hamburger University',
              address1: '21 Hamburger Place',
              address2: nil,
              city: 'Des Moines',
              state: 'IA',
              postal_code: 12345,
              country: 'United States of America',
              url: 'http://example.org/',
              email: 'test@example.org',
              description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1'),
        CreateInstitutionCommand.new(
            { name: 'San Quentin Prison University',
              address1: '5435 Prison Ct.',
              address2: nil,
              city: 'San Quentin',
              state: 'CA',
              postal_code: 90210,
              country: 'United States of America',
              url: 'http://example.org/',
              email: 'test@example.org',
              description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1'),
        CreateInstitutionCommand.new(
            { name: 'Barnum & Bailey Clown College',
              address1: 'Circus Tent C',
              address2: '53 Trapeze Road',
              city: 'Los Angeles',
              state: 'CA',
              postal_code: 99999,
              country: 'United States of America',
              url: 'http://example.org/',
              email: 'test@example.org',
              description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1'),
        CreateInstitutionCommand.new(
            { name: 'Hogwarts School of Witchcraft & Wizardry',
              address1: '123 Magical St.',
              address2: nil,
              city: 'Hogsmeade',
              state: 'N/A',
              postal_code: 99999,
              country: 'Hogsmeade',
              url: 'http://example.org/',
              email: 'test@example.org',
              description: 'Lorem ipsum dolor sit amet' }, nil, '127.0.0.1')
    ]

    institutions = institution_commands.map{ |command| command.execute; command.object }
    admin_user.institution = institutions[0]
    admin_user.save!

    # Normal user
    command = CreateUserCommand.new(
        { username: 'normal', email: 'normal@example.org',
          first_name: 'Norm', last_name: 'McNormal',
          password: 'password', password_confirmation: 'password',
          institution: institutions[0], role: normal_role,
          confirmed: true, enabled: true }, '127.0.0.1', false)
    command.execute
    normal_user = command.object

    # Unaffiliated user
    command = CreateUserCommand.new(
        { username: 'unaffiliated', email: 'unaffiliated@example.org',
          first_name: 'Clara', last_name: 'NoInstitution',
          password: 'password', password_confirmation: 'password',
          institution: nil, role: normal_role,
          confirmed: true, enabled: true }, '127.0.0.1', false)
    command.execute
    unaffiliated_user = command.object

    # Unconfirmed user
    command = CreateUserCommand.new(
        { username: 'unconfirmed', email: 'unconfirmed@example.org',
          first_name: 'Sally', last_name: 'NoConfirmy',
          password: 'password', password_confirmation: 'password',
          institution: institutions[1], role: normal_role,
          confirmed: false, enabled: false }, '127.0.0.1', false)
    command.execute
    unconfirmed_user = command.object

    # Disabled user
    command = CreateUserCommand.new(
        { username: 'disabled', email: 'disabled@example.org',
          first_name: 'Johnny', last_name: 'CantDoNothin',
          password: 'password', password_confirmation: 'password',
          institution: institutions[1], role: normal_role,
          confirmed: true, enabled: false }, '127.0.0.1', false)
    command.execute
    disabled_user = command.object

    # Repositories
    repository_commands = [
        CreateRepositoryCommand.new(institutions[0],
            { name: 'Sample Repository' }, nil, '127.0.0.1'),
        CreateRepositoryCommand.new(institutions[0],
            { name: 'Another Sample Repository' }, nil, '127.0.0.1')
    ]

    repositories = repository_commands.map{ |command| command.execute; command.object }

    # Locations
    location_commands = [
        CreateLocationCommand.new(repositories[0],
            { name: 'Secret Location',
              description: 'Sample description' }, nil, '127.0.0.1'),
        CreateLocationCommand.new(repositories[0],
            { name: 'Even More Secret Location',
              description: 'Sample description' }, nil, '127.0.0.1'),
        CreateLocationCommand.new(repositories[0],
            { name: 'Attic',
              description: 'Sample description' }, nil, '127.0.0.1'),
    ]

    locations = location_commands.map{ |command| command.execute; command.object }

    locations.each do |location|
      location.temperature_range = TemperatureRange.create!(
          min_temp_f: 0, max_temp_f: 100, score: 1)
      location.save!
    end

    # Resources
    resource_commands = []
    resource_commands << CreateResourceCommand.new(locations[0],
        { name: 'Magna Carta',
          resource_type: ResourceType::ITEM,
          format: Format.find_by_fid(7),
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 1,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[0],
        { name: 'Dead Sea Scrolls',
          resource_type: ResourceType::ITEM,
          format: Format.find_by_fid(18),
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 1,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[0],
        { name: 'Sears Catalog Collection',
          resource_type: ResourceType::COLLECTION,
          user: admin_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          significance: 0,
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[2],
        { name: 'Cat Fancy Collection',
          resource_type: ResourceType::COLLECTION,
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[2],
        { name: 'Issue 1',
          resource_type: ResourceType::ITEM,
          user: admin_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[2],
        { name: 'Issue 2',
          resource_type: ResourceType::ITEM,
          user: disabled_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[2],
        { name: 'Special Editions',
          resource_type: ResourceType::COLLECTION,
          user: admin_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[2],
        { name: '1972 Presidential Election Special Issue',
          resource_type: ResourceType::ITEM,
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')
    resource_commands << CreateResourceCommand.new(locations[2],
        { name: 'Napoleon Bonaparte Letters Collection',
          resource_type: ResourceType::COLLECTION,
          user: normal_user,
          description: 'Sample description',
          local_identifier: 'sample_local_id',
          rights: 'Sample rights' }, nil, '127.0.0.1')

    resources = resource_commands.map{ |command| command.execute; command.object }

    resources[1].assessment_question_responses.each do |response|
      response.assessment_question_option =
        response.assessment_question.assessment_question_options[0]
    end
    resources[1].save!

    resources[4].parent = resources[3]
    resources[5].parent = resources[3]
    resources[6].parent = resources[3]
    resources[7].parent = resources[3]
    resources[8].parent = resources[3]
    resources.select{ |r| r.save! }

    # Dates
    ResourceDate.create!(resource: resources[0],
                         date_type: DateType::SINGLE,
                         year: 1215)
    ResourceDate.create!(resource: resources[1],
                         date_type: DateType::BULK,
                         begin_year: 30,
                         end_year: 50)
    ResourceDate.create!(resource: resources[2],
                         date_type: DateType::SPAN,
                         begin_year: 1920,
                         end_year: 1990)
    ResourceDate.create!(resource: resources[3],
                         date_type: DateType::BULK,
                         begin_year: 1980,
                         end_year: 1992)
    ResourceDate.create!(resource: resources[4],
                         date_type: DateType::SINGLE,
                         year: 843)
    ResourceDate.create!(resource: resources[5],
                         date_type: DateType::SINGLE,
                         year: 1856)
    ResourceDate.create!(resource: resources[6],
                         date_type: DateType::SPAN,
                         begin_year: 1960,
                         end_year: 2000)
    ResourceDate.create!(resource: resources[7],
                         date_type: DateType::SINGLE,
                         year: 1960)
    ResourceDate.create!(resource: resources[8],
                         date_type: DateType::SINGLE,
                         year: 1961)

    # Extents
    extents = []
    for i in 0..resources.length / 2
      extents << Extent.create!(name: 'Sample extent',
                                resource: resources[i])
    end
    for i in 0..resources.length / 3
      extents << Extent.create!(name: 'Another sample extent',
                                resource: resources[i])
    end

    # Creators
    creators = []
    for i in 0..resources.length - 1
        creators << Creator.create!(name: 'Sample creator',
                                    creator_type: i.odd? ? CreatorType::PERSON : CreatorType::COMPANY,
                                    resource: resources[i])
    end

    # Notes
    notes = []
    for i in 0..resources.length - 1
      notes << ResourceNote.create!(value: 'Sample note 1',
                                  resource: resources[i])
      notes << ResourceNote.create!(value: 'Sample note 2',
                                    resource: resources[i])
    end

    # Subjects
    subjects = []
    for i in 0..resources.length - 1
      subjects << Subject.create!(name: 'Sample subject',
                                  resource: resources[i])
    end
=begin
    # Assessment question responses
    responses = [
      AssessmentQuestionResponse.create!(
          resource: resources[0],
          assessment_question: questions[0],
          assessment_question_option: options[0]),
      AssessmentQuestionResponse.create!(
          resource: resources[0],
          assessment_question: questions[1],
          assessment_question_option: options[5]),
      AssessmentQuestionResponse.create!(
          resource: resources[0],
          assessment_question: questions[2],
          assessment_question_option: options[8]),
      AssessmentQuestionResponse.create!(
          resource: resources[0],
          assessment_question: questions[3],
          assessment_question_option: options[12]),
      AssessmentQuestionResponse.create!(
          resource: resources[0],
          assessment_question: questions[4],
          assessment_question_option: options[13]),
      AssessmentQuestionResponse.create!(
          resource: resources[0],
          assessment_question: questions[5],
          assessment_question_option: options[15])
    ]
    resources[0].assessment_percent_complete = 1
    resources[0].save!
=end
    # Format temperature ranges
    Format.all do |format|
        TemperatureRange.create!(min_temp_f: nil, max_temp_f: 32, score: 1,
                                 format: format)
        TemperatureRange.create!(min_temp_f: 33, max_temp_f: 54, score: 0.67,
                                 format: format)
        TemperatureRange.create!(min_temp_f: 55, max_temp_f: 72, score: 0.33,
                                 format: format)
        TemperatureRange.create!(min_temp_f: 73, max_temp_f: nil, score: 0,
                                 format: format)
    end

    # Events
    Event.create!(description: 'This event was just created',
                  event_level: EventLevel::DEBUG,
                  user: normal_user,
                  address: '127.0.0.1',
                  created_at: Time.mktime(2014, 4, 12))
    Event.create!(description: 'Made queso dip, but ran out of chips before '\
    'the queso was consumed, so had to buy more chips, but then didn\'t have '\
    'enough queso',
                  event_level: EventLevel::INFO,
                  user: admin_user,
                  address: '10.252.52.5',
                  created_at: Time.mktime(2014, 2, 6))
    Event.create!(description: 'Gazed into the abyss',
                  event_level: EventLevel::NOTICE,
                  user: disabled_user,
                  address: '10.252.52.5',
                  created_at: Time.mktime(2013, 11, 10, 2, 5, 10))
    Event.create!(description: 'Abyss gazed back',
                  event_level: EventLevel::NOTICE,
                  user: disabled_user,
                  address: '10.252.52.5',
                  created_at: Time.mktime(2013, 11, 10, 2, 5, 11))
    Event.create!(description: 'Meta-Ambulation has pulled ahead in Pedometer Challenge',
                  event_level: EventLevel::WARNING,
                  address: '127.0.0.1',
                  created_at: Time.mktime(2014, 3, 26))
    Event.create!(description: 'Godzilla has appeared in Tokyo Harbor',
                  event_level: EventLevel::ERROR,
                  user: admin_user,
                  address: '10.5.2.6',
                  created_at: Time.mktime(2014, 5, 8))
    Event.create!(description: 'Skynet has become self-aware',
                  event_level: EventLevel::CRITICAL,
                  address: '127.0.0.1',
                  created_at: Time.mktime(1997, 8, 12))
    Event.create!(description: 'Ran out of toilet paper',
                  event_level: EventLevel::ALERT,
                  address: '127.0.0.1',
                  created_at: Time.mktime(2013, 6, 19))

    (0..250).each do
      Event.create!(description: 'Sample event',
                    event_level: EventLevel::DEBUG,
                    address: '127.0.0.1',
                    created_at: Time.mktime(2012, 12, 12))
    end

  when 'production'

end
