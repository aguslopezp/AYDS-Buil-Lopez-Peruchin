require_relative '../models/question'
require_relative '../models/option'
require_relative '../models/item'

Question.create(description: '¿Cuál es el animal más rápido del mundo?', detail: 'El halcón peregrino en picada, cuando caza efectúa un ataque en picado puede alcanzar más de 300 km/h.', level: 1)
Option.create(description: 'El halcón peregrino', isCorrect: true, question_id: 1)
Option.create(description: 'El guepardo', isCorrect: false, question_id: 1)
Option.create(description: 'El antílope', isCorrect: false, question_id: 1)
Option.create(description: 'El tigre siberiano', isCorrect: false, question_id: 1)

Question.create(description: '¿Qué pájaro pone el huevo más pequeño?', detail: 'Los huevos del colibrí son casi del tamaño de una pastilla de tic tac, pueden estar entre los 8 y 10 mm.', level: 1)
Option.create(description: 'El colibrí', isCorrect: true, question_id: 2)
Option.create(description: 'El chipe azul', isCorrect: false, question_id: 2)
Option.create(description: 'El jilguero', isCorrect: false, question_id: 2)
Option.create(description: 'La paloma', isCorrect: false, question_id: 2)

Question.create(description: '¿Cuál es la edad promedio de un león sin estar en cautiverio?', detail: 'Un león, en estado salvaje, puede vivir en promedio entre 12 y 16 años. En cautiverio pueden llegar a la edad de 25 años.', level: 1)
Option.create(description: 'Entre 6 y 9 años', isCorrect: false, question_id: 3)
Option.create(description: 'Entre 12 y 16 años', isCorrect: true, question_id: 3)
Option.create(description: 'Entre 15 y 20 años', isCorrect: false, question_id: 3)
Option.create(description: 'Entre 20 y 25 años', isCorrect: false, question_id: 3)

Question.create(description: '¿Qué mamifero tiene la mordida más poderosa?', detail: 'La mordida del hipopótamo es la más fuerte de todos los mamíferos, siendo capaz de generar un PSI de 1821.', level: 1)
Option.create(description: 'El hipopotamo', isCorrect: true, question_id: 4)
Option.create(description: 'El león', isCorrect: false, question_id: 4)
Option.create(description: 'El gorila', isCorrect: false, question_id: 4)
Option.create(description: 'La ballena azul', isCorrect: false, question_id: 4)

Question.create(description: '¿Qué criatura tiene una lengua que puede medir la longitud de su cuerpo?', detail: 'El camaleón es capaz de extender la lengua hasta dos veces del tamaño de su cuerpo.', level: 2)
Option.create(description: 'La rana', isCorrect: false, question_id: 5)
Option.create(description: 'El oso hormiguero', isCorrect: false, question_id: 5)
Option.create(description: 'La mosca', isCorrect: false, question_id: 5)
Option.create(description: 'El camaleon', isCorrect: true, question_id: 5)

Question.create(description: '¿Cuál es el pariente vivo más cercano al T-rex?', detail: 'Se demostró que la gallina común y el avestruz comparten más rasgos genéticos con el Tyrannosaurus rex que los reptiles.', level: 2)
Option.create(description: 'El tigre', isCorrect: false, question_id: 6)
Option.create(description: 'El oso polar', isCorrect: false, question_id: 6)
Option.create(description: 'La gallina', isCorrect: true, question_id: 6)
Option.create(description: 'El zorro', isCorrect: false, question_id: 6)

Question.create(description: '¿Dónde almacenan las nutrias marinas la comida adicional en sus cuerpos?', detail: 'Las nutrias poseen una piel suelta y flexible, que pueden estirar y utilizar como una especie de bolsa o bolsita para llevar comida', level: 2)
Option.create(description: 'Un bolsillo de piel en sus axilas', isCorrect: true, question_id: 7)
Option.create(description: 'Su boca', isCorrect: false, question_id: 7)
Option.create(description: 'Su estómago', isCorrect: false, question_id: 7)
Option.create(description: 'Sus patas', isCorrect: false, question_id: 7)

Question.create(description: '¿Cuál es el animal mas vengativo del mundo?', detail: 'La investigación ha encontrado que los tigres buscarán vengarse de aquellos que los han molestado.
Naturalistas han vivido muchas situaciones en donde tigres se han aferrado a un gran sentimiento de rencor durante más de 48hs antes de atacar y matar a cazadores que previamente habían intentado cazarlos.
', level: 2)
Option.create(description: 'El tiburón blanco', isCorrect: false, question_id: 8)
Option.create(description: 'El tigre', isCorrect: true, question_id: 8)
Option.create(description: 'Las orcas', isCorrect: false, question_id: 8)
Option.create(description: 'El oso negro', isCorrect: false, question_id: 8)

Question.create(description: '¿De qué color es la piel de un oso polar?', detail: 'Curiosamente, el pelaje del oso polar no tiene pigmento blanco; de hecho, la piel de un oso polar es negra  (mira su nariz) y sus pelos son huecos. Cada cabello dispersa y refleja la luz visible, esto hace que parezcan de color blanco, aunque no lo son.', level: 3)
Option.create(description: 'Marrón', isCorrect: false, question_id: 9)
Option.create(description: 'Blanca', isCorrect: false, question_id: 9)
Option.create(description: 'Rosa', isCorrect: false, question_id: 9)
Option.create(description: 'Negra', isCorrect: true, question_id: 9)

Question.create(description: '¿Qué pájaro tiene ojos más grandes que su cerebro?', detail: 'Siendo el avestruz el ave más grande del mundo, tiene un ojo tan grande como el colibrí abeja (el ave más pequeña del mundo). Eso es cinco veces más grande que el ojo humano. Los ojos grandes ayudan al avestruz a ver con gran detalle y a detectar a los depredadores.', level: 3)
Option.create(description: 'Gorrión', isCorrect: false, question_id: 10)
Option.create(description: 'Aguila', isCorrect: false, question_id: 10)
Option.create(description: 'Avestruz', isCorrect: true, question_id: 10)
Option.create(description: 'Cóndor', isCorrect: false, question_id: 10)

Question.create(description: '¿Qué suele regalarle un pingüino macho a una hembra para conquistarla?', detail: 'Los pingüinos en lugar del habitual anillo de compromiso, entregan una piedra a la hembra de su grupo con la que esperan construir un nido y aparearse.
Estas piedras las utilizan para cubrir el suelo sobre el que construyen sus nidos, de forma de mantener los huevos aislados de la nieve.
Cuando vuelven junto a la hembra, llevan las piedras que recogieron a los pies de su pareja, como un gesto natural de cortejo.
', level: 3)
Option.create(description: 'Una rama', isCorrect: false, question_id: 11)
Option.create(description: 'Una piedra', isCorrect: true, question_id: 11)
Option.create(description: 'Una bola de nieve', isCorrect: false, question_id: 11)
Option.create(description: 'Una flor', isCorrect: false, question_id: 11)

Question.create(description: '¿Cuál es el tipo de energía más contaminante?', detail: 'El carbón y el petróleo son los mayores culpables del efecto invernadero y del cambio climático, provocando no solo la contaminación del aire, sino también de la tierra y del agua.', level: 3)
Option.create(description: 'El gas', isCorrect: false, question_id: 12)
Option.create(description: 'El carbón y el petróleo', isCorrect: true, question_id: 12)
Option.create(description: 'La nuclear', isCorrect: false, question_id: 12)
Option.create(description: 'La hidroeléctrica', isCorrect: false, question_id: 12)

# Question.create(description: '¿?', detail: '')
# Option.create(description: '', isCorrect: false, question_id: 12)
# Option.create(description: '', isCorrect: true, question_id: 12)
# Option.create(description: '', isCorrect: false, question_id: 12)
# Option.create(description: '', isCorrect: false, question_id: 12)

Item.create(name: 'arceR', section: 'hoja', description: 'Arce Rojo', price: 15)
Item.create(name: 'canada', section: 'hoja', description: 'Canada Brown', price: 15)
Item.create(name: 'golden', section: 'hoja', description: 'Golden', price: 15)
Item.create(name: 'ocean', section: 'hoja', description: 'Ocean', price: 15)
Item.create(name: 'sunset', section: 'hoja', description: 'Sunset', price: 15)
Item.create(name: 'roble', section: 'hoja', description: 'Roble', price: 15)
Item.create(name: 'forest', section: 'fondo', description: 'Forest', price: 15)
Item.create(name: 'paradise', section: 'fondo', description: 'Paradise', price: 15)
Item.create(name: 'sabana', section: 'fondo', description: 'Sabanna', price: 15)
Item.create(name: 'jungle', section: 'fondo', description: 'Jungle', price: 15)
