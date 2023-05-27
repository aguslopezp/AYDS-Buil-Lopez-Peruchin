require_relative '../models/question'
require_relative '../models/option'

Question.create(description: '¿Cuál es el animal más rápido del mundo?')
Option.create(description: 'El halcón peregrino', isCorrect: true, question_id: 1)
Option.create(description: 'El guepardo', isCorrect: false, question_id: 1)
Option.create(description: 'El antílope', isCorrect: false, question_id: 1)
Option.create(description: 'El tigre siberiano', isCorrect: false, question_id: 1)

Question.create(description: '¿Qué pájaro pone el huevo más pequeño?')
Option.create(description: 'El colibrí', isCorrect: true, question_id: 2)
Option.create(description: 'El chipe azul', isCorrect: false, question_id: 2)
Option.create(description: 'El jilguero', isCorrect: false, question_id: 2)
Option.create(description: 'La paloma', isCorrect: false, question_id: 2)

Question.create(description: '¿Cómo se puede determinar la edad de un león?')
Option.create(description: 'Mediante sus garras', isCorrect: false, question_id: 3)
Option.create(description: 'Mediante su nariz', isCorrect: true, question_id: 3)
Option.create(description: 'Mediante su cola', isCorrect: false, question_id: 3)
Option.create(description: 'Mediante su pelo', isCorrect: false, question_id: 3)

Question.create(description: '¿Qué mamifero tiene la mordida más poderosa?')
Option.create(description: 'El hipopotamo', isCorrect: true, question_id: 4)
Option.create(description: 'El león', isCorrect: false, question_id: 4)
Option.create(description: 'El gorila', isCorrect: false, question_id: 4)
Option.create(description: 'La ballena azul', isCorrect: false, question_id: 4)

Question.create(description: '¿Qué criatura tiene una lengua que puede medir la longitud de su cuerpo?')
Option.create(description: 'La rana', isCorrect: false, question_id: 5)
Option.create(description: 'El oso hormiguero', isCorrect: false, question_id: 5)
Option.create(description: 'La mosca', isCorrect: false, question_id: 5)
Option.create(description: 'El camaleon', isCorrect: true, question_id: 5)

Question.create(description: '¿Cuál es el pariente vivo más cercano al T-rex?')
Option.create(description: 'El tigre', isCorrect: false, question_id: 6)
Option.create(description: 'El oso polar', isCorrect: false, question_id: 6)
Option.create(description: 'La gallina', isCorrect: true, question_id: 6)
Option.create(description: 'El zorro', isCorrect: false, question_id: 6)

Question.create(description: '¿Dónde almacenan las nutrias marinas la comida adicional en sus cuerpos?')
Option.create(description: 'Un bolsillo de piel en sus axilas', isCorrect: true, question_id: 7)
Option.create(description: 'Su boca', isCorrect: false, question_id: 7)
Option.create(description: 'Su estómago', isCorrect: false, question_id: 7)
Option.create(description: 'Sus patas', isCorrect: false, question_id: 7)

Question.create(description: '¿En qué parte del cuerpo están las papilas gustativas de un cangrejo?')
Option.create(description: 'En su lengua', isCorrect: false, question_id: 8)
Option.create(description: 'En sus pies', isCorrect: true, question_id: 8)
Option.create(description: 'En sus pinzas', isCorrect: false, question_id: 8)
Option.create(description: 'En su caparazón', isCorrect: false, question_id: 8)

Question.create(description: '¿De qué color es la piel de un oso polar?')
Option.create(description: 'Marrón', isCorrect: false, question_id: 9)
Option.create(description: 'Blanca', isCorrect: false, question_id: 9)
Option.create(description: 'Rosa', isCorrect: false, question_id: 9)
Option.create(description: 'Negra', isCorrect: true, question_id: 9)

Question.create(description: '¿Qué pájaro tiene ojos más grandes que su cerebro?')
Option.create(description: 'Gorrión', isCorrect: false, question_id: 10)
Option.create(description: 'Aguila', isCorrect: false, question_id: 10)
Option.create(description: 'Avestruz', isCorrect: true, question_id: 10)
Option.create(description: 'Cóndor', isCorrect: false, question_id: 10)

Question.create(description: '¿Qué suele regalarle un pingüino macho a una hembra para conquistarla?')
Option.create(description: 'Una rama', isCorrect: false, question_id: 11)
Option.create(description: 'Una piedra', isCorrect: true, question_id: 11)
Option.create(description: 'Una bola de nieve', isCorrect: false, question_id: 11)
Option.create(description: 'Una flor', isCorrect: false, question_id: 11)

#Question.create(description: '¿?', asked: false)
#Option.create(description: '', isCorrect: false, question_id: 12)
#Option.create(description: '', isCorrect: true, question_id: 12)
#Option.create(description: '', isCorrect: false, question_id: 12)
#Option.create(description: '', isCorrect: false, question_id: 12)