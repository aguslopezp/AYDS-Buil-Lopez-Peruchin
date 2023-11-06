const getLevel = document.getElementById("level_selected").getAttribute('value');
const level = parseInt(getLevel, 10);

let secondsRemaining = 30;
if (level === 2) {
  secondsRemaining = 20;
}
if (level === 3) {
  secondsRemaining = 10;
}

// Función para actualizar el contador de tiempo en la página
function updateTimer() {
  document.getElementById("timer").textContent = `Tiempo restante: ${secondsRemaining}s`;
}

// Función para reducir el tiempo y redirigir cuando se agota
function countdown() {
  updateTimer();
  secondsRemaining--;

  if (secondsRemaining < 0) {
    // El tiempo se ha agotado, redirigir al usuario a /timeout
    document.querySelector('#game-form input[name="timeout"]').value = 'true'; 
    document.getElementById("game-form").submit();
  } else {
    // Programa una llamada recursiva para actualizar el contador cada segundo
    setTimeout(countdown, 1000);
  }
}

// Inicia el contador cuando la página está lista
document.addEventListener("DOMContentLoaded", function () {
  countdown();
});


// Obtén una lista de todos los botones de radio (opciones) por su nombre
const optionButtons = document.querySelectorAll('input[type="radio"][name="selected_option_id"]');

// Obtén el botón de "Responder" por su ID
const submitButton = document.getElementById('submit-button');

// Agrega un controlador de eventos para cada botón de radio
optionButtons.forEach(function (optionButton) {
  optionButton.addEventListener('change', function () {
    // Verifica si al menos una opción ha sido seleccionada
    const anyOptionSelected = [...optionButtons].some(function (button) {
      return button.checked;
    });

    // Habilita o deshabilita el botón de "Responder" según si se ha seleccionado alguna opción
    submitButton.disabled = !anyOptionSelected;
  });
});

/*
  El usuario al hacer click en el boton aumentar tiempo por 20s, si es que tiene suficientes monedas
  estas seran decrementadas por el precio de aumentar el tiempo, y el tiempo restatnte para responder
  la pregunta aumentara en 20s.
*/
const addTimeButton = document.getElementById('add-time-button'); // Botón de agregar tiempo
const additionalTime = 20;

// funcion que se ejecuta cuando se hace click en el boton
addTimeButton.addEventListener('click', function () {
  // se realiza una solicitud AJAX al servidor para decrementar monedas si estas son suficientes
  fetch('/buyMoreTime', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  })
    .then(response => response.json())  // obtengo la respuesta del servidor como JSON
    .then(data => {
      if (data.success) { // si habia suficientes monedas para comprar mas tiempo
        secondsRemaining += additionalTime;
        updateTimer();
        // Actualiza las monedas en la vista game
        document.getElementById('coin-count').textContent = `coins: ${data.updatedCoins}`; // obtengo el elemento HTML con id coin-count
      } else {
        alert('No tienes suficientes monedas para comprar mas tiempo.');
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
});

/*
  El usuario al hacer click en el boton remove-options-button, si es que tiene suficientes monedas,
  estas seran decrementadas por el precio de la accion, y dos preguntas opciones seran eliminadas, 
  quedando unicamente dos, una correcta y la otra incorrecta.
*/
const removeIncorrect = document.getElementById('remove-options-button'); 

removeIncorrect.addEventListener('click', function () {     
  const optionElements = document.querySelectorAll('.option'); // obtengo los elementos de opción en mi vista 
  let hiddenCount = 0;

  for (const option of optionElements) {
    if (option.style.display === 'none') {
      hiddenCount++;
    }
  }
  console.log("Hidden count " + hiddenCount);

  if (hiddenCount == 2) {
    alert('Ya compraste esta ayuda, no se puede volver a comprar.');
  }
  else {
    fetch('/incorrectOptions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    })
      .then(response => response.json())  
      .then(data => {
        if (data.success) {
          document.getElementById('coin-count').textContent = `coins: ${data.updatedCoins}`;
          console.log("nuevas monedas " + data.updatedCoins);


          const incorrectOptionsId = data.incorrect_options // arreglo con los id (int) de las opciones incorrectas que recibi de la bd
          console.log("opciones incorrectas desde bd: " + incorrectOptionsId);
                    
          let removedCount = 0; // Contador de opciones eliminadas
          let index = 0;

          while (removedCount < 2 && index < 4) {
            const optionIdHtml = optionElements[index].querySelector('input').value; // obtengo su id (este esta guardado en el campo value de el objeto html option)
            if (incorrectOptionsId[0] == optionIdHtml || incorrectOptionsId[1] == optionIdHtml || incorrectOptionsId[2] == optionIdHtml) {
              console.log("se cumple, se hace el display none")
              removedCount++;
              optionElements[index].style.display = "none";
            }
            index++;
          }
            

        } else {
          alert('No tienes suficientes monedas para comprar esta ayuda.');
        }
      })
      .catch(error => {
        console.error('Error:', error);
      });
  }

});
